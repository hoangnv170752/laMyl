//
//  RevenueCatManager.swift
//  laMyl
//
//  Manages RevenueCat SDK for in-app purchases and subscriptions
//

import Foundation
import RevenueCat
import Combine

// MARK: - Subscription Status

enum SubscriptionStatus: Equatable {
    case unknown
    case notSubscribed
    case subscribed(expirationDate: Date?, productId: String?)
    case lifetime

    var isActive: Bool {
        switch self {
        case .subscribed, .lifetime:
            return true
        default:
            return false
        }
    }

    var displayName: String {
        switch self {
        case .unknown:
            return "Loading..."
        case .notSubscribed:
            return "Free"
        case .subscribed(let expiration, _):
            if let exp = expiration {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Pro (until \(formatter.string(from: exp)))"
            }
            return "Pro"
        case .lifetime:
            return "Pro (Lifetime)"
        }
    }
}

// MARK: - Product Type

enum ProductType: String, CaseIterable {
    case monthly = "monthly"
    case yearly = "yearly"
    case lifetime = "lifetime"

    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    var description: String {
        switch self {
        case .monthly: return "Billed monthly"
        case .yearly: return "Billed annually"
        case .lifetime: return "One-time purchase"
        }
    }
}

// MARK: - RevenueCat Error

enum RevenueCatError: LocalizedError {
    case notConfigured
    case noOfferings
    case noProducts
    case purchaseFailed(String)
    case restoreFailed(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "RevenueCat is not configured"
        case .noOfferings:
            return "No offerings available"
        case .noProducts:
            return "No products available"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - RevenueCat Manager

@MainActor
class RevenueCatManager: NSObject, ObservableObject {
    static let shared = RevenueCatManager()

    // MARK: - Published Properties

    @Published private(set) var subscriptionStatus: SubscriptionStatus = .unknown
    @Published private(set) var customerInfo: CustomerInfo?
    @Published private(set) var offerings: Offerings?
    @Published private(set) var currentOffering: Offering?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: RevenueCatError?

    // Convenience computed properties
    var isPro: Bool {
        subscriptionStatus.isActive
    }

    var hasLifetime: Bool {
        if case .lifetime = subscriptionStatus {
            return true
        }
        return false
    }

    // MARK: - Products

    var monthlyPackage: Package? {
        currentOffering?.package(identifier: ProductType.monthly.rawValue)
            ?? currentOffering?.monthly
    }

    var yearlyPackage: Package? {
        currentOffering?.package(identifier: ProductType.yearly.rawValue)
            ?? currentOffering?.annual
    }

    var lifetimePackage: Package? {
        currentOffering?.package(identifier: ProductType.lifetime.rawValue)
            ?? currentOffering?.lifetime
    }

    var availablePackages: [Package] {
        currentOffering?.availablePackages ?? []
    }

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    // MARK: - Configuration

    /// Configure RevenueCat SDK - call this in AppDelegate
    func configure() {
        Purchases.logLevel = .debug // Set to .error in production

        Purchases.configure(withAPIKey: Config.revenueCatAPIKey)

        // Set delegate to receive customer info updates
        Purchases.shared.delegate = self

        // Fetch initial customer info
        Task {
            await refreshCustomerInfo()
            await fetchOfferings()
        }

        print("[RevenueCatManager] Configured with API key")
    }

    /// Configure with a specific app user ID (for linking with your auth system)
    func configure(appUserID: String?) {
        Purchases.logLevel = .debug

        if let userID = appUserID {
            Purchases.configure(withAPIKey: Config.revenueCatAPIKey, appUserID: userID)
        } else {
            Purchases.configure(withAPIKey: Config.revenueCatAPIKey)
        }

        Purchases.shared.delegate = self

        Task {
            await refreshCustomerInfo()
            await fetchOfferings()
        }

        print("[RevenueCatManager] Configured with user ID: \(appUserID ?? "anonymous")")
    }

    // MARK: - Customer Info

    /// Refresh customer info from RevenueCat
    func refreshCustomerInfo() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            await updateCustomerInfo(info)
        } catch {
            print("[RevenueCatManager] Failed to fetch customer info: \(error)")
            self.error = .unknown(error.localizedDescription)
        }
    }

    /// Update subscription status based on customer info
    private func updateCustomerInfo(_ info: CustomerInfo) async {
        self.customerInfo = info

        // Debug: Print all available entitlements
        print("[RevenueCatManager] === Customer Info Debug ===")
        print("[RevenueCatManager] App User ID: \(info.originalAppUserId)")
        print("[RevenueCatManager] Looking for entitlement: '\(Config.entitlementID)'")
        print("[RevenueCatManager] All entitlements: \(info.entitlements.all.keys)")

        for (key, entitlement) in info.entitlements.all {
            print("[RevenueCatManager] Entitlement '\(key)': isActive=\(entitlement.isActive), productId=\(entitlement.productIdentifier), expires=\(String(describing: entitlement.expirationDate))")
        }

        print("[RevenueCatManager] Active purchases: \(info.activeSubscriptions)")
        print("[RevenueCatManager] Non-subscriptions: \(info.nonSubscriptions.map { $0.productIdentifier })")
        print("[RevenueCatManager] ===========================")

        // Check for lamyl_pro entitlement
        if let entitlement = info.entitlements[Config.entitlementID], entitlement.isActive {
            // Check if it's a lifetime purchase (no expiration)
            if entitlement.expirationDate == nil {
                subscriptionStatus = .lifetime
                print("[RevenueCatManager] ✅ User has LIFETIME access")
            } else {
                subscriptionStatus = .subscribed(
                    expirationDate: entitlement.expirationDate,
                    productId: entitlement.productIdentifier
                )
                print("[RevenueCatManager] ✅ User has active subscription until \(String(describing: entitlement.expirationDate))")
            }
        } else {
            subscriptionStatus = .notSubscribed
            print("[RevenueCatManager] ❌ User does not have active entitlement '\(Config.entitlementID)'")

            // Additional debug: check if entitlement exists but is not active
            if let entitlement = info.entitlements[Config.entitlementID] {
                print("[RevenueCatManager] Entitlement exists but isActive=\(entitlement.isActive)")
            } else {
                print("[RevenueCatManager] Entitlement '\(Config.entitlementID)' not found in customer info")
            }
        }
    }

    // MARK: - Offerings

    /// Fetch available offerings
    func fetchOfferings() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            self.offerings = offerings

            // Use specific offering ID from config, or fall back to current
            if let offeringID = Config.revenueCatOfferingID,
               let specificOffering = offerings.offering(identifier: offeringID) {
                self.currentOffering = specificOffering
                print("[RevenueCatManager] Using offering from config: \(offeringID)")
            } else {
                self.currentOffering = offerings.current
            }

            if let current = currentOffering {
                print("[RevenueCatManager] Fetched offering: \(current.identifier)")
                print("[RevenueCatManager] Available packages: \(current.availablePackages.map { $0.identifier })")
            } else {
                print("[RevenueCatManager] No offering available")
                self.error = .noOfferings
            }
        } catch {
            print("[RevenueCatManager] Failed to fetch offerings: \(error)")
            self.error = .unknown(error.localizedDescription)
        }
    }

    // MARK: - Purchases

    /// Purchase a package
    func purchase(package: Package) async throws -> CustomerInfo {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            if !result.userCancelled {
                await updateCustomerInfo(result.customerInfo)
                print("[RevenueCatManager] Purchase successful: \(package.identifier)")
            }

            return result.customerInfo
        } catch {
            print("[RevenueCatManager] Purchase failed: \(error)")
            throw RevenueCatError.purchaseFailed(error.localizedDescription)
        }
    }

    /// Purchase monthly subscription
    func purchaseMonthly() async throws -> CustomerInfo {
        guard let package = monthlyPackage else {
            throw RevenueCatError.noProducts
        }
        return try await purchase(package: package)
    }

    /// Purchase yearly subscription
    func purchaseYearly() async throws -> CustomerInfo {
        guard let package = yearlyPackage else {
            throw RevenueCatError.noProducts
        }
        return try await purchase(package: package)
    }

    /// Purchase lifetime
    func purchaseLifetime() async throws -> CustomerInfo {
        guard let package = lifetimePackage else {
            throw RevenueCatError.noProducts
        }
        return try await purchase(package: package)
    }

    // MARK: - Restore Purchases

    /// Restore previous purchases
    func restorePurchases() async throws -> CustomerInfo {
        isLoading = true
        defer { isLoading = false }

        do {
            let info = try await Purchases.shared.restorePurchases()
            await updateCustomerInfo(info)
            print("[RevenueCatManager] Purchases restored")
            return info
        } catch {
            print("[RevenueCatManager] Restore failed: \(error)")
            throw RevenueCatError.restoreFailed(error.localizedDescription)
        }
    }

    // MARK: - User Management

    /// Log in a user (link with your auth system)
    func logIn(userID: String) async throws -> CustomerInfo {
        do {
            let (info, _) = try await Purchases.shared.logIn(userID)
            await updateCustomerInfo(info)
            print("[RevenueCatManager] User logged in: \(userID)")
            return info
        } catch {
            print("[RevenueCatManager] Login failed: \(error)")
            throw RevenueCatError.unknown(error.localizedDescription)
        }
    }

    /// Log out user (switch to anonymous)
    func logOut() async throws -> CustomerInfo {
        do {
            let info = try await Purchases.shared.logOut()
            await updateCustomerInfo(info)
            print("[RevenueCatManager] User logged out")
            return info
        } catch {
            print("[RevenueCatManager] Logout failed: \(error)")
            throw RevenueCatError.unknown(error.localizedDescription)
        }
    }

    /// Get current RevenueCat app user ID
    var appUserID: String {
        Purchases.shared.appUserID
    }

    /// Check if user is anonymous
    var isAnonymous: Bool {
        Purchases.shared.isAnonymous
    }

    // MARK: - Entitlement Checking

    /// Check if user has a specific entitlement
    func hasEntitlement(_ identifier: String) -> Bool {
        guard let info = customerInfo else { return false }
        return info.entitlements[identifier]?.isActive == true
    }

    /// Check if user has the pro entitlement
    func hasProEntitlement() -> Bool {
        hasEntitlement(Config.entitlementID)
    }
}

// MARK: - PurchasesDelegate

extension RevenueCatManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            await updateCustomerInfo(customerInfo)
            print("[RevenueCatManager] Received customer info update")
        }
    }
}

// MARK: - Helper Extensions

extension Package {
    /// Get localized price string
    var localizedPriceString: String {
        storeProduct.localizedPriceString
    }

    /// Get price per month for comparison
    var pricePerMonth: Decimal? {
        guard let period = storeProduct.subscriptionPeriod else { return nil }

        let price = storeProduct.price
        let months: Decimal

        switch period.unit {
        case .month:
            months = Decimal(period.value)
        case .year:
            months = Decimal(period.value * 12)
        case .week:
            months = Decimal(period.value) / 4
        case .day:
            months = Decimal(period.value) / 30
        @unknown default:
            return nil
        }

        return price / months
    }

    /// Check if this is a lifetime purchase
    var isLifetime: Bool {
        storeProduct.subscriptionPeriod == nil
    }
}
