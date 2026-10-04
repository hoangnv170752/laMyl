//
//  SettingsManager.swift
//  laMyl
//
//  Persists user settings using UserDefaults
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
    }

    // MARK: - Settings

    @Published var volume: Float {
        didSet {
            defaults.set(volume, forKey: Keys.volume)
        }
    }

    @Published var isEnabled: Bool {
        didSet {
            defaults.set(isEnabled, forKey: Keys.isEnabled)
        }
    }

    @Published var lowVolumeBoost: Bool {
        didSet {
            defaults.set(lowVolumeBoost, forKey: Keys.lowVolumeBoost)
        }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            // TODO: Actually configure launch at login using SMAppService
        }
    }

    @Published var selectedSound: String {
        didSet {
            defaults.set(selectedSound, forKey: Keys.selectedSound)
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
