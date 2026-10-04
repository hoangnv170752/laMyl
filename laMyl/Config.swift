//
//  Config.swift
//  laMyl
//
//  Configuration loaded from .env file
//

import Foundation

enum Config {
    // MARK: - Supabase

    /// Supabase project URL
    static var supabaseURL: URL {
        URL(string: Env.require("SUPABASE_URL"))!
    }

    /// Supabase publishable key (safe to include in client)
    static var supabasePublishableKey: String {
        Env.require("SUPABASE_PUBLISHABLE_KEY")
    }

    /// JWKS URL for token validation
    static var supabaseJWKSURL: URL {
        URL(string: Env.require("SUPABASE_JWKS_URL"))!
    }

    // MARK: - RevenueCat

    /// RevenueCat API key for iOS/macOS
    static var revenueCatAPIKey: String {
        Env.require("REVENUE_CAT_API_KEY")
    }

    /// RevenueCat entitlement identifier for pro features
    static var entitlementID: String {
        let id = Env.get("REVENUE_CAT_ENTITLEMENT_ID", default: "lamyl_pro")
        print("[Config] entitlementID = '\(id)'")
        return id
    }

    /// RevenueCat offering/catalog ID
    static var revenueCatOfferingID: String? {
        Env.get("REVENUE_CAT_CATALOG")
    }

    /// Product identifiers (must match App Store Connect and RevenueCat dashboard)
    enum ProductID {
        static let monthly = "monthly"
        static let yearly = "yearly"
        static let lifetime = "lifetime"
    }

    // MARK: - Sync Settings

    /// Debounce delay for settings sync (seconds)
    static let settingsSyncDebounce: TimeInterval = 2.0

    /// Interval for key stats sync (seconds)
    static let keyStatsSyncInterval: TimeInterval = 300 // 5 minutes

    // MARK: - App Info

    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
