//
//  CloudModels.swift
//  laMyl
//
//  Data models for Supabase sync
//

import Foundation

// MARK: - User Profile

struct CloudProfile: Codable, Identifiable {
    let id: UUID
    var createdAt: Date?
    var updatedAt: Date?
    var displayName: String?
    var isAnonymous: Bool
    var revenuecatUserId: String?
    var deviceId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case displayName = "display_name"
        case isAnonymous = "is_anonymous"
        case revenuecatUserId = "revenuecat_user_id"
        case deviceId = "device_id"
    }

    init(id: UUID, displayName: String? = nil, isAnonymous: Bool = true,
         revenuecatUserId: String? = nil, deviceId: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.isAnonymous = isAnonymous
        self.revenuecatUserId = revenuecatUserId
        self.deviceId = deviceId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - User Settings

struct CloudSettings: Codable, Identifiable {
    var id: UUID?
    let userId: UUID
    var volume: Float
    var isEnabled: Bool
    var lowVolumeBoost: Bool
    var launchAtLogin: Bool
    var selectedSound: String
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case volume
        case isEnabled = "is_enabled"
        case lowVolumeBoost = "low_volume_boost"
        case launchAtLogin = "launch_at_login"
        case selectedSound = "selected_sound"
        case updatedAt = "updated_at"
    }

    init(userId: UUID, volume: Float = 0.7, isEnabled: Bool = true,
         lowVolumeBoost: Bool = false, launchAtLogin: Bool = false,
         selectedSound: String = "default") {
        self.userId = userId
        self.volume = volume
        self.isEnabled = isEnabled
        self.lowVolumeBoost = lowVolumeBoost
        self.launchAtLogin = launchAtLogin
        self.selectedSound = selectedSound
        self.updatedAt = Date()
    }

    /// Create from local SettingsManager
    static func fromLocal(userId: UUID, settings: SettingsManager) -> CloudSettings {
        CloudSettings(
            userId: userId,
            volume: settings.volume,
            isEnabled: settings.isEnabled,
            lowVolumeBoost: settings.lowVolumeBoost,
            launchAtLogin: settings.launchAtLogin,
            selectedSound: settings.selectedSound
        )
    }

    /// Apply to local SettingsManager
    func applyToLocal(_ settings: SettingsManager) {
        settings.volume = volume
        settings.isEnabled = isEnabled
        settings.lowVolumeBoost = lowVolumeBoost
        settings.launchAtLogin = launchAtLogin
        settings.selectedSound = selectedSound
    }
}

// MARK: - Key Statistics

struct CloudKeyStats: Codable, Identifiable {
    var id: UUID?
    let userId: UUID
    var totalKeys: Int64
    var dailyKeys: [String: Int]  // "2024-01-15": 1234
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case totalKeys = "total_keys"
        case dailyKeys = "daily_keys"
        case updatedAt = "updated_at"
    }

    init(userId: UUID, totalKeys: Int64 = 0, dailyKeys: [String: Int] = [:]) {
        self.userId = userId
        self.totalKeys = totalKeys
        self.dailyKeys = dailyKeys
        self.updatedAt = Date()
    }

    /// Get today's date key
    static var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    /// Add keys to today's count
    mutating func addKeys(_ count: Int) {
        totalKeys += Int64(count)
        let today = Self.todayKey
        dailyKeys[today, default: 0] += count
        updatedAt = Date()
    }
}

// MARK: - Custom Sounds

struct CloudCustomSound: Codable, Identifiable {
    var id: UUID?
    let userId: UUID
    var name: String
    var description: String?
    var isFavorite: Bool
    var soundData: SoundConfig?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case description
        case isFavorite = "is_favorite"
        case soundData = "sound_data"
        case createdAt = "created_at"
    }

    init(userId: UUID, name: String, description: String? = nil,
         isFavorite: Bool = false, soundData: SoundConfig? = nil) {
        self.userId = userId
        self.name = name
        self.description = description
        self.isFavorite = isFavorite
        self.soundData = soundData
        self.createdAt = Date()
    }
}

/// Sound configuration stored as JSONB
struct SoundConfig: Codable {
    var keySounds: [String]      // File names
    var spaceSound: String?
    var enterSound: String?
    var backspaceSound: String?
    var pitchVariation: Float?   // 0.0 - 1.0
    var volumeVariation: Float?  // 0.0 - 1.0
}

// MARK: - Sync Metadata

struct SyncMetadata: Codable {
    var lastSyncAt: Date?
    var lastSettingsSync: Date?
    var lastKeyStatsSync: Date?
    var pendingChanges: Bool

    static var `default`: SyncMetadata {
        SyncMetadata(
            lastSyncAt: nil,
            lastSettingsSync: nil,
            lastKeyStatsSync: nil,
            pendingChanges: false
        )
    }
}
