//
//  SubscriptionView.swift
//  laMyl
//
//  Subscription management UI with RevenueCat Paywall and Customer Center
//

import SwiftUI
import RevenueCat
import RevenueCatUI

// MARK: - Subscription View

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var revenueCat = RevenueCatManager.shared
    @State private var showPaywall = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var isRestoring = false

    var body: some View {
        VStack(spacing: 16) {
            // Close button
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Header
            subscriptionHeader

            Divider()

            // Status Section
            statusSection

            // Action Buttons
            actionButtons

            Spacer()
        }
        .padding(20)
        .frame(width: 360, height: 420)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .onPurchaseCompleted { _ in
                    showPaywall = false
                }
                .onRestoreCompleted { _ in
                    showPaywall = false
                }
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage)
        }
    }

    // MARK: - Header

    private var subscriptionHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: revenueCat.isPro ? "crown.fill" : "crown")
                .font(.system(size: 40))
                .foregroundStyle(
                    revenueCat.isPro
                        ? LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
                )

            Text(revenueCat.isPro ? "laMyl Pro" : "laMyl Free")
                .font(.title2)
                .fontWeight(.bold)

            Text(revenueCat.subscriptionStatus.displayName)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Status Section

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if revenueCat.isPro {
                proFeaturesSection
            } else {
                freeLimitationsSection
            }
        }
        .padding(.vertical, 8)
    }

    private var proFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pro Features Active")
                .font(.headline)
                .foregroundColor(.green)

            FeatureRow(icon: "checkmark.circle.fill", text: "All sound packs", isActive: true)
            FeatureRow(icon: "checkmark.circle.fill", text: "Cloud sync enabled", isActive: true)
            FeatureRow(icon: "checkmark.circle.fill", text: "Custom sound import", isActive: true)
            FeatureRow(icon: "checkmark.circle.fill", text: "Priority support", isActive: true)
        }
    }

    private var freeLimitationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upgrade to Pro")
                .font(.headline)

            FeatureRow(icon: "lock.fill", text: "Unlock all sound packs", isActive: false)
            FeatureRow(icon: "lock.fill", text: "Enable cloud sync", isActive: false)
            FeatureRow(icon: "lock.fill", text: "Import custom sounds", isActive: false)
            FeatureRow(icon: "lock.fill", text: "Get priority support", isActive: false)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !revenueCat.isPro {
                // Upgrade button
                Button(action: { showPaywall = true }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Upgrade to Pro")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                // Restore purchases
                Button(action: restorePurchases) {
                    HStack {
                        if isRestoring {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Restore Purchases")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .disabled(isRestoring)
            }
        }
    }

    // MARK: - Actions

    private func restorePurchases() {
        isRestoring = true
        Task {
            do {
                _ = try await revenueCat.restorePurchases()
                if revenueCat.isPro {
                    restoreMessage = "Your purchases have been restored successfully!"
                } else {
                    restoreMessage = "No previous purchases found for this account."
                }
            } catch {
                restoreMessage = "Failed to restore purchases: \(error.localizedDescription)"
            }
            isRestoring = false
            showRestoreAlert = true
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(isActive ? .green : .gray)
                .font(.subheadline)

            Text(text)
                .font(.subheadline)
                .foregroundColor(isActive ? .primary : .secondary)

            Spacer()
        }
    }
}

// MARK: - Compact Subscription Status (for MenuBarView)

struct SubscriptionStatusView: View {
    @StateObject private var revenueCat = RevenueCatManager.shared
    @State private var showPaywall = false
    @State private var showSubscriptionView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: revenueCat.isPro ? "crown.fill" : "crown")
                    .foregroundColor(revenueCat.isPro ? .orange : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(revenueCat.isPro ? "Pro" : "Free")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(statusText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if revenueCat.isPro {
                    Button("Manage") {
                        showSubscriptionView = true
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                } else {
                    Button("Upgrade") {
                        showPaywall = true
                    }
                    .font(.caption)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.orange)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.laMylLavender.opacity(0.1))
        .cornerRadius(8)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .onPurchaseCompleted { _ in
                    showPaywall = false
                }
        }
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
        }
    }

    private var statusText: String {
        switch revenueCat.subscriptionStatus {
        case .unknown:
            return "Loading..."
        case .notSubscribed:
            return "Upgrade for all features"
        case .subscribed(let expiration, _):
            if let exp = expiration {
                let days = Calendar.current.dateComponents([.day], from: Date(), to: exp).day ?? 0
                if days < 7 {
                    return "Renews in \(days) days"
                }
                return "Active"
            }
            return "Active"
        case .lifetime:
            return "Lifetime access"
        }
    }
}

// MARK: - Paywall Trigger Modifier

extension View {
    /// Show paywall if user doesn't have the pro entitlement
    func requiresPro() -> some View {
        self.presentPaywallIfNeeded(
            requiredEntitlementIdentifier: Config.entitlementID
        ) { _ in
            print("Purchase completed")
        } restoreCompleted: { _ in
            print("Restore completed")
        }
    }
}

// MARK: - Custom Paywall View (Alternative to RevenueCat Paywall)

struct CustomPaywallView: View {
    @StateObject private var revenueCat = RevenueCatManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            paywallHeader

            // Packages
            packagesSection

            // Purchase Button
            purchaseButton

            // Terms
            termsSection
        }
        .padding(24)
        .frame(width: 400, height: 500)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
        .onAppear {
            // Select yearly by default (best value)
            selectedPackage = revenueCat.yearlyPackage ?? revenueCat.monthlyPackage
        }
    }

    private var paywallHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                )

            Text("Upgrade to laMyl Pro")
                .font(.title)
                .fontWeight(.bold)

            Text("Unlock all features and sound packs")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var packagesSection: some View {
        VStack(spacing: 12) {
            if let monthly = revenueCat.monthlyPackage {
                PackageOptionView(
                    package: monthly,
                    isSelected: selectedPackage?.identifier == monthly.identifier,
                    badge: nil
                ) {
                    selectedPackage = monthly
                }
            }

            if let yearly = revenueCat.yearlyPackage {
                PackageOptionView(
                    package: yearly,
                    isSelected: selectedPackage?.identifier == yearly.identifier,
                    badge: "Best Value"
                ) {
                    selectedPackage = yearly
                }
            }

            if let lifetime = revenueCat.lifetimePackage {
                PackageOptionView(
                    package: lifetime,
                    isSelected: selectedPackage?.identifier == lifetime.identifier,
                    badge: "One-Time"
                ) {
                    selectedPackage = lifetime
                }
            }
        }
    }

    private var purchaseButton: some View {
        VStack(spacing: 12) {
            Button(action: purchase) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Continue")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(selectedPackage == nil || isPurchasing)

            Button("Restore Purchases") {
                Task {
                    do {
                        _ = try await revenueCat.restorePurchases()
                        if revenueCat.isPro {
                            dismiss()
                        }
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }

    private var termsSection: some View {
        VStack(spacing: 4) {
            Text("Subscriptions auto-renew unless cancelled")
                .font(.caption2)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Button("Terms of Service") {
                    // Open terms URL
                }
                .font(.caption2)

                Button("Privacy Policy") {
                    // Open privacy URL
                }
                .font(.caption2)
            }
        }
    }

    private func purchase() {
        guard let package = selectedPackage else { return }

        isPurchasing = true
        Task {
            do {
                _ = try await revenueCat.purchase(package: package)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isPurchasing = false
        }
    }
}

// MARK: - Package Option View

struct PackageOptionView: View {
    let package: Package
    let isSelected: Bool
    let badge: String?
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(packageTitle)
                            .font(.headline)

                        if let badge = badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }

                    Text(packageDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(package.localizedPriceString)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(12)
            .background(isSelected ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private var packageTitle: String {
        if package.isLifetime {
            return "Lifetime"
        }

        switch package.packageType {
        case .monthly:
            return "Monthly"
        case .annual:
            return "Yearly"
        default:
            return package.identifier.capitalized
        }
    }

    private var packageDescription: String {
        if package.isLifetime {
            return "Pay once, own forever"
        }

        switch package.packageType {
        case .monthly:
            return "Billed monthly"
        case .annual:
            if let monthlyPrice = package.pricePerMonth {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = package.storeProduct.priceFormatter?.locale
                if let formatted = formatter.string(from: monthlyPrice as NSNumber) {
                    return "\(formatted)/month"
                }
            }
            return "Billed annually"
        default:
            return package.storeProduct.localizedDescription
        }
    }
}

// MARK: - Preview

#Preview("Subscription View") {
    SubscriptionView()
}

#Preview("Subscription Status") {
    SubscriptionStatusView()
        .frame(width: 300)
        .padding()
}
