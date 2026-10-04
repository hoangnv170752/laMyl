//
//  SettingsManager.swift
//  laMyl
//
//  Persists user settings using UserDefaults with cloud sync support
//

import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    // Keys
    private enum Keys {
        static let volume = "laMyl.volume"
        static let isEnabled = "laMyl.isEnabled"
        static let lowVolumeBoost = "laMyl.lowVolumeBoost"
        static let launchAtLogin = "laMyl.launchAtLogin"
        static let selectedSound = "laMyl.selectedSound"
        static let totalKeyCount = "laMyl.totalKeyCount"
    }

    // Flag to prevent sync loops when applying cloud settings
    private var isApplyingCloudSettings = false

    // MARK: - Settings

    @Published var volume: Float {
        didSet {
            defaults.set(volume, forKey: Keys.volume)
            triggerSyncIfNeeded()
        }
    }

    @Published var isEnabled: Bool {
        didSet {
            defaults.set(isEnabled, forKey: Keys.isEnabled)
            triggerSyncIfNeeded()
        }
    }

    @Published var lowVolumeBoost: Bool {
        didSet {
            defaults.set(lowVolumeBoost, forKey: Keys.lowVolumeBoost)
            triggerSyncIfNeeded()
        }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            triggerSyncIfNeeded()
            // TODO: Actually configure launch at login using SMAppService
        }
    }

    @Published var selectedSound: String {
        didSet {
            defaults.set(selectedSound, forKey: Keys.selectedSound)
            triggerSyncIfNeeded()
        }
    }

    @Published var totalKeyCount: Int {
        didSet {
            defaults.set(totalKeyCount, forKey: Keys.totalKeyCount)
            // Don't trigger sync for key count - handled separately by SyncService
        }
    }

    // MARK: - Init

    private init() {
        // Load saved settings or use defaults
        self.volume = defaults.object(forKey: Keys.volume) as? Float ?? 0.7
        self.isEnabled = defaults.object(forKey: Keys.isEnabled) as? Bool ?? true
        self.lowVolumeBoost = defaults.object(forKey: Keys.lowVolumeBoost) as? Bool ?? false
        self.launchAtLogin = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
        self.selectedSound = defaults.string(forKey: Keys.selectedSound) ?? "default"
        self.totalKeyCount = defaults.integer(forKey: Keys.totalKeyCount)
    }

    // MARK: - Cloud Sync

    /// Called when settings change to trigger cloud sync
    private func triggerSyncIfNeeded() {
        guard !isApplyingCloudSettings else { return }
        SyncService.shared.scheduleSettingsSync()
    }

    /// Apply settings from cloud (prevents sync loop)
    func applyFromCloud(volume: Float? = nil, isEnabled: Bool? = nil,
                        lowVolumeBoost: Bool? = nil, launchAtLogin: Bool? = nil,
                        selectedSound: String? = nil) {
        isApplyingCloudSettings = true
        defer { isApplyingCloudSettings = false }

        if let volume = volume { self.volume = volume }
        if let isEnabled = isEnabled { self.isEnabled = isEnabled }
        if let lowVolumeBoost = lowVolumeBoost { self.lowVolumeBoost = lowVolumeBoost }
        if let launchAtLogin = launchAtLogin { self.launchAtLogin = launchAtLogin }
        if let selectedSound = selectedSound { self.selectedSound = selectedSound }
    }

    // MARK: - Reset

    func resetToDefaults() {
        volume = 0.7
        isEnabled = true
        lowVolumeBoost = false
        launchAtLogin = false
        selectedSound = "default"
    }
}
