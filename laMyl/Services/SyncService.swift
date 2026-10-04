//
//  SyncService.swift
//  laMyl
//
//  Orchestrates data synchronization between local and cloud
//  Only available for Pro users
//

import Foundation
import Combine

// MARK: - Sync Status

enum SyncStatus: Equatable {
    case idle
    case syncing
    case success
    case error(String)
    case offline
    case notPro  // User needs Pro to sync

    var isSyncing: Bool {
        if case .syncing = self { return true }
        return false
    }
}

// MARK: - Sync Service

@MainActor
class SyncService: ObservableObject {
    static let shared = SyncService()

    @Published private(set) var status: SyncStatus = .idle
    @Published private(set) var lastSyncTime: Date?
    @Published var isSyncEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isSyncEnabled, forKey: "laMyl.syncEnabled")
            if isSyncEnabled && canSync {
                Task { await initialSync() }
            }
        }
    }

    private let supabase = SupabaseManager.shared
    private let revenueCat = RevenueCatManager.shared
    private var cancellables = Set<AnyCancellable>()

    // Debounce timers
    private var settingsSyncTimer: Timer?
    private var keyStatsSyncTimer: Timer?

    // Local cache for pending changes
    private var pendingSettingsSync = false
    private var pendingKeyStatsCount: Int = 0
    private var hasPerformedInitialSync = false

    /// Check if user can sync (Pro + enabled)
    var canSync: Bool {
        revenueCat.isPro && isSyncEnabled
    }

    private init() {
        isSyncEnabled = UserDefaults.standard.object(forKey: "laMyl.syncEnabled") as? Bool ?? true
        setupObservers()
    }

    // MARK: - Setup

    private func setupObservers() {
        // Observe Pro status changes - sync when user upgrades
        revenueCat.$subscriptionStatus
            .dropFirst()
            .removeDuplicates { $0.isActive == $1.isActive }
            .sink { [weak self] status in
                guard let self = self else { return }
                if status.isActive && self.isSyncEnabled && !self.hasPerformedInitialSync {
                    print("[SyncService] User upgraded to Pro, starting sync...")
                    Task {
                        await self.initialSync()
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Initial Sync

    /// Perform initial sync when user has Pro
    func initialSync() async {
        guard canSync else {
            status = revenueCat.isPro ? .idle : .notPro
            return
        }

        guard !hasPerformedInitialSync else { return }

        status = .syncing
        print("[SyncService] Starting initial sync...")

        do {
            // Create or get user in Supabase
            let userId = try await supabase.getOrCreateUser()
            print("[SyncService] User created/found: \(userId)")

            // Fetch cloud settings
            if let cloudSettings = try await supabase.fetchSettings() {
                // Cloud has data, apply to local
                cloudSettings.applyToLocal(SettingsManager.shared)
                print("[SyncService] Applied cloud settings to local")
            } else {
                // No cloud data, push local settings
                await pushSettings()
                print("[SyncService] Pushed local settings to cloud")
            }

            // Fetch cloud key stats
            if let cloudStats = try await supabase.fetchKeyStats() {
                // Merge: take higher count
                let localCount = SettingsManager.shared.totalKeyCount
                if cloudStats.totalKeys > Int64(localCount) {
                    SettingsManager.shared.totalKeyCount = Int(cloudStats.totalKeys)
                    print("[SyncService] Applied cloud key stats: \(cloudStats.totalKeys)")
                } else {
                    print("[SyncService] Local key stats higher, keeping local")
                }
            }

            hasPerformedInitialSync = true
            status = .success
            lastSyncTime = Date()
            print("[SyncService] Initial sync completed successfully")

        } catch {
            status = .error(error.localizedDescription)
            print("[SyncService] Initial sync failed: \(error)")
        }
    }

    // MARK: - Settings Sync

    /// Schedule settings sync with debounce
    func scheduleSettingsSync() {
        guard canSync else { return }

        pendingSettingsSync = true

        // Cancel existing timer
        settingsSyncTimer?.invalidate()

        // Schedule new sync after debounce
        settingsSyncTimer = Timer.scheduledTimer(
            withTimeInterval: Config.settingsSyncDebounce,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.pushSettings()
            }
        }
    }

    /// Push local settings to cloud
    func pushSettings() async {
        guard canSync,
              let userId = supabase.authState.userId else { return }

        let settings = CloudSettings.fromLocal(userId: userId, settings: SettingsManager.shared)

        do {
            try await supabase.upsertSettings(settings)
            pendingSettingsSync = false
            lastSyncTime = Date()
            print("[SyncService] Settings pushed to cloud")
        } catch {
            print("[SyncService] Failed to push settings: \(error)")
        }
    }

    /// Pull settings from cloud
    func pullSettings() async {
        guard canSync else { return }

        do {
            if let cloudSettings = try await supabase.fetchSettings() {
                cloudSettings.applyToLocal(SettingsManager.shared)
                lastSyncTime = Date()
                print("[SyncService] Settings pulled from cloud")
            }
        } catch {
            print("[SyncService] Failed to pull settings: \(error)")
        }
    }

    // MARK: - Key Stats Sync

    /// Add keys to pending sync
    func addKeyCount(_ count: Int) {
        guard canSync else { return }

        pendingKeyStatsCount += count

        // Start periodic sync timer if not running
        if keyStatsSyncTimer == nil {
            keyStatsSyncTimer = Timer.scheduledTimer(
                withTimeInterval: Config.keyStatsSyncInterval,
                repeats: true
            ) { [weak self] _ in
                Task { @MainActor in
                    await self?.pushKeyStats()
                }
            }
        }
    }

    /// Push key stats to cloud
    func pushKeyStats() async {
        guard canSync,
              let userId = supabase.authState.userId,
              pendingKeyStatsCount > 0 else { return }

        let countToSync = pendingKeyStatsCount
        pendingKeyStatsCount = 0

        var stats = CloudKeyStats(userId: userId)
        stats.addKeys(countToSync)

        do {
            try await supabase.upsertKeyStats(stats)
            print("[SyncService] Key stats pushed: +\(countToSync)")
        } catch {
            // Re-add to pending if failed
            pendingKeyStatsCount += countToSync
            print("[SyncService] Failed to push key stats: \(error)")
        }
    }

    // MARK: - Manual Sync

    /// Force full sync
    func forceSync() async {
        guard canSync else {
            status = .notPro
            return
        }

        status = .syncing

        // Push any pending changes first
        await pushSettings()
        await pushKeyStats()

        // Then pull latest from cloud
        await pullSettings()

        status = .success
        lastSyncTime = Date()
    }

    // MARK: - App Lifecycle

    /// Called when app is about to terminate
    func syncBeforeTerminate() {
        guard canSync else { return }

        // Save pending data locally for next launch
        if pendingSettingsSync {
            UserDefaults.standard.set(true, forKey: "laMyl.pendingSettingsSync")
        }

        if pendingKeyStatsCount > 0 {
            let existing = UserDefaults.standard.integer(forKey: "laMyl.pendingKeyStats")
            UserDefaults.standard.set(existing + pendingKeyStatsCount, forKey: "laMyl.pendingKeyStats")
        }
    }

    /// Called when app launches
    func checkPendingSync() async {
        guard canSync else { return }

        let pendingSettings = UserDefaults.standard.bool(forKey: "laMyl.pendingSettingsSync")
        let pendingStats = UserDefaults.standard.integer(forKey: "laMyl.pendingKeyStats")

        if pendingSettings {
            await pushSettings()
            UserDefaults.standard.removeObject(forKey: "laMyl.pendingSettingsSync")
        }

        if pendingStats > 0 {
            pendingKeyStatsCount = pendingStats
            await pushKeyStats()
            UserDefaults.standard.removeObject(forKey: "laMyl.pendingKeyStats")
        }
    }

    /// Reset sync state (for testing)
    func resetSyncState() {
        hasPerformedInitialSync = false
        status = .idle
        lastSyncTime = nil
    }
}
