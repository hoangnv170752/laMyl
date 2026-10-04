//
//  SupabaseManager.swift
//  laMyl
//
//  Manages Supabase client for cloud sync (self-managed users)
//

import Foundation
import Combine
import PostgREST

// MARK: - Auth State (simplified - no Supabase Auth)

enum AuthState: Equatable {
    case unknown
    case signedOut
    case signedIn(userId: UUID)

    var isSignedIn: Bool {
        if case .signedIn = self { return true }
        return false
    }

    var userId: UUID? {
        if case .signedIn(let id) = self { return id }
        return nil
    }
}

// MARK: - Supabase Manager

@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()

    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var isInitialized: Bool = false

    // PostgREST client
    private let client: PostgrestClient

    // UserDefaults keys
    private let userIdKey = "laMyl.supabase.userId"
    private let deviceIdKey = "laMyl.supabase.deviceId"

    // Device ID (persistent across sessions)
    private(set) var deviceId: String

    private init() {
        // Initialize PostgREST client with Supabase REST API endpoint
        let restURL = Config.supabaseURL.appendingPathComponent("rest/v1")
        self.client = PostgrestClient(
            url: restURL,
            headers: [
                "apikey": Config.supabasePublishableKey,
                "Authorization": "Bearer \(Config.supabasePublishableKey)"
            ],
            logger: nil
        )

        // Get or create device ID
        if let existingDeviceId = UserDefaults.standard.string(forKey: deviceIdKey) {
            self.deviceId = existingDeviceId
        } else {
            let newDeviceId = "device_\(UUID().uuidString)"
            UserDefaults.standard.set(newDeviceId, forKey: deviceIdKey)
            self.deviceId = newDeviceId
        }

        // Restore session
        restoreSession()
    }

    // MARK: - Session Management

    private func restoreSession() {
        if let userIdString = UserDefaults.standard.string(forKey: userIdKey),
           let userId = UUID(uuidString: userIdString) {
            authState = .signedIn(userId: userId)
            print("[SupabaseManager] Restored session: \(userId)")
        } else {
            authState = .signedOut
            print("[SupabaseManager] No session to restore")
        }
        isInitialized = true
    }

    private func saveSession(userId: UUID) {
        UserDefaults.standard.set(userId.uuidString, forKey: userIdKey)
        authState = .signedIn(userId: userId)
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
        authState = .signedOut
    }

    // MARK: - User Management

    /// Get or create user in Supabase using device ID
    func getOrCreateUser() async throws -> UUID {
        let revenueCatUserId = RevenueCatManager.shared.appUserID

        // Call the database function via RPC
        let response = try await client
            .rpc("get_or_create_user", params: [
                "p_device_id": deviceId,
                "p_revenuecat_user_id": revenueCatUserId
            ])
            .execute()

        // Parse UUID from response
        guard let jsonString = String(data: response.data, encoding: .utf8) else {
            throw SupabaseError.invalidResponse
        }

        // Response is a UUID string like "\"uuid-here\""
        let cleanedString = jsonString.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        guard let userId = UUID(uuidString: cleanedString) else {
            throw SupabaseError.invalidResponse
        }

        saveSession(userId: userId)

        print("[SupabaseManager] User ID: \(userId)")
        return userId
    }

    /// Sign out (clear local session)
    func signOut() {
        clearSession()
        print("[SupabaseManager] Signed out")
    }

    // MARK: - Settings Operations

    /// Fetch user settings from cloud
    func fetchSettings() async throws -> CloudSettings? {
        guard let userId = authState.userId else {
            throw SupabaseError.notSignedIn
        }

        let response: [CloudSettings] = try await client
            .from("user_settings")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        return response.first
    }

    /// Upsert user settings to cloud
    func upsertSettings(_ settings: CloudSettings) async throws {
        guard authState.isSignedIn else {
            throw SupabaseError.notSignedIn
        }

        try await client
            .from("user_settings")
            .upsert(settings, onConflict: "user_id")
            .execute()

        print("[SupabaseManager] Settings synced to cloud")
    }

    // MARK: - Key Stats Operations

    /// Fetch key stats from cloud
    func fetchKeyStats() async throws -> CloudKeyStats? {
        guard let userId = authState.userId else {
            throw SupabaseError.notSignedIn
        }

        let response: [CloudKeyStats] = try await client
            .from("key_stats")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        return response.first
    }

    /// Upsert key stats to cloud
    func upsertKeyStats(_ stats: CloudKeyStats) async throws {
        guard authState.isSignedIn else {
            throw SupabaseError.notSignedIn
        }

        try await client
            .from("key_stats")
            .upsert(stats, onConflict: "user_id")
            .execute()

        print("[SupabaseManager] Key stats synced to cloud")
    }

    /// Update key count (increment)
    func incrementKeyCount(_ count: Int) async throws {
        guard let userId = authState.userId else {
            throw SupabaseError.notSignedIn
        }

        let today = CloudKeyStats.todayKey

        // First fetch current stats
        if var stats = try await fetchKeyStats() {
            stats.totalKeys += Int64(count)
            stats.dailyKeys[today, default: 0] += count
            try await upsertKeyStats(stats)
        } else {
            // Create new stats
            var newStats = CloudKeyStats(userId: userId)
            newStats.addKeys(count)
            try await upsertKeyStats(newStats)
        }
    }

    // MARK: - Profile Operations

    /// Fetch user profile
    func fetchProfile() async throws -> CloudProfile? {
        guard let userId = authState.userId else {
            throw SupabaseError.notSignedIn
        }

        let response: [CloudProfile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .execute()
            .value

        return response.first
    }

    /// Update profile
    func updateProfile(_ profile: CloudProfile) async throws {
        guard authState.isSignedIn else {
            throw SupabaseError.notSignedIn
        }

        try await client
            .from("profiles")
            .update(profile)
            .eq("id", value: profile.id.uuidString)
            .execute()

        print("[SupabaseManager] Profile updated")
    }
}

// MARK: - Errors

enum SupabaseError: LocalizedError {
    case notSignedIn
    case invalidResponse
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Not signed in"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError:
            return "Network error"
        case .unknown(let message):
            return message
        }
    }
}
