//
//  MenuBarView.swift
//  laMyl
//
//  Menu bar popover UI
//

import SwiftUI
import RevenueCatUI

// Brand colors from logo
extension Color {
    static let laMylPeach = Color(red: 1.0, green: 0.69, blue: 0.53)      // #FFB088
    static let laMylLavender = Color(red: 0.61, green: 0.56, blue: 0.91)  // #9B8FE8
    static let laMylBlue = Color(red: 0.48, green: 0.64, blue: 0.91)      // #7BA3E8
}

struct MenuBarView: View {
    @ObservedObject var audioEngine: AudioEngine
    @ObservedObject var keyboardManager: KeyboardManager
    @StateObject private var supabase = SupabaseManager.shared
    @StateObject private var syncService = SyncService.shared
    @StateObject private var revenueCat = RevenueCatManager.shared

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerSection

                    // Key counter
                    keyCounterSection

                    Divider()

                    // Subscription status
                    SubscriptionStatusView()

                    Divider()

                    // Permission warning if needed
                    if !keyboardManager.hasAccessibilityPermission {
                        permissionWarning
                        Divider()
                    }

                    // Sound toggle
                    soundToggle

                    // Volume slider
                    volumeSection

                    // Low Volume Boost
                    lowVolumeBoostToggle

                    Divider()

                    // Sync section (Pro feature)
                    if revenueCat.isPro {
                        syncSection
                        Divider()
                    }

                    // Preview button
                    previewButton
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDisabled(false)

            Divider()

            // Footer actions (fixed at bottom)
            footerSection
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .frame(width: 320, height: 550)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("laMyl")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.laMylPeach, .laMylLavender, .laMylBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("sounds good. feels better.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Status indicator
            Circle()
                .fill(audioEngine.isEnabled ? Color.laMylBlue : Color.gray)
                .frame(width: 10, height: 10)
        }
    }

    // MARK: - Key Counter

    private var keyCounterSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Keys Pressed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(keyboardManager.keyCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.laMylPeach, .laMylLavender],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            Spacer()

            // Reset button
            Button(action: {
                keyboardManager.keyCount = 0
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Reset counter")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.laMylLavender.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Permission Warning

    private var permissionWarning: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Accessibility Permission Required")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            Text("laMyl needs permission to respond to your keyboard. Your keystrokes stay on your Mac.")
                .font(.caption2)
                .foregroundColor(.secondary)

            Button("Enable Keyboard Access") {
                keyboardManager.requestAccessibilityPermission()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(10)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Sound Toggle

    private var soundToggle: some View {
        Toggle(isOn: $audioEngine.isEnabled) {
            HStack(spacing: 10) {
                Image(systemName: audioEngine.isEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.body)
                    .foregroundColor(audioEngine.isEnabled ? .accentColor : .secondary)
                Text("Keyboard Sound")
                    .font(.body)
            }
        }
        .toggleStyle(.switch)
    }

    // MARK: - Volume

    private var volumeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Volume")
                    .font(.body)
                Spacer()
                Text("\(Int(audioEngine.volume * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Slider(value: $audioEngine.volume, in: 0...1)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Low Volume Boost

    private var lowVolumeBoostToggle: some View {
        Toggle(isOn: $audioEngine.lowVolumeBoost) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Low Volume Boost")
                    .font(.body)
                Text("Clearer sound at low system volume")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .toggleStyle(.switch)
    }

    // MARK: - Sync Section

    private var syncSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with sync icon
            HStack {
                Image(systemName: syncService.status.isSyncing ? "arrow.triangle.2.circlepath" : "icloud")
                    .font(.body)
                    .foregroundColor(syncService.isSyncEnabled ? .laMylBlue : .secondary)

                Text("Cloud Sync")
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                // Sync status badge
                syncStatusBadge
            }

            // Sync toggle
            Toggle(isOn: $syncService.isSyncEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Auto Sync")
                        .font(.subheadline)
                    Text("Sync settings across devices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .toggleStyle(.switch)

            // Account info card
            accountInfoView

            // Manual sync button
            if syncService.isSyncEnabled {
                Button(action: {
                    Task {
                        await syncService.forceSync()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Sync Now")
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(syncService.status.isSyncing)
            }
        }
        .padding(12)
        .background(Color.laMylBlue.opacity(0.05))
        .cornerRadius(12)
    }

    private var syncStatusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(syncStatusColor)
                .frame(width: 6, height: 6)
            Text(syncStatusText)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(syncStatusColor.opacity(0.1))
        .cornerRadius(10)
    }

    private var syncStatusColor: Color {
        switch syncService.status {
        case .idle, .success:
            return .green
        case .syncing:
            return .blue
        case .error:
            return .red
        case .offline:
            return .orange
        }
    }

    private var syncStatusText: String {
        switch syncService.status {
        case .idle:
            if let lastSync = syncService.lastSyncTime {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .abbreviated
                return formatter.localizedString(for: lastSync, relativeTo: Date())
            }
            return "Not synced"
        case .syncing:
            return "Syncing..."
        case .success:
            return "Synced"
        case .error:
            return "Error"
        case .offline:
            return "Offline"
        }
    }

    private var accountInfoView: some View {
        HStack(spacing: 10) {
            // Avatar
            ZStack {
                Circle()
                    .fill(accountAvatarColor.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: accountIconName)
                    .font(.system(size: 16))
                    .foregroundColor(accountAvatarColor)
            }

            // Account info
            VStack(alignment: .leading, spacing: 2) {
                Text(accountTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(accountSubtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Action button
            accountActionButton
        }
        .padding(10)
        .background(Color.laMylLavender.opacity(0.1))
        .cornerRadius(10)
    }

    private var accountIconName: String {
        switch supabase.authState {
        case .anonymous:
            return "person.crop.circle"
        case .authenticated:
            return "person.crop.circle.fill.badge.checkmark"
        case .signedOut, .unknown:
            return "person.crop.circle.badge.questionmark"
        }
    }

    private var accountAvatarColor: Color {
        switch supabase.authState {
        case .anonymous:
            return .orange
        case .authenticated:
            return .laMylBlue
        case .signedOut, .unknown:
            return .secondary
        }
    }

    private var accountTitle: String {
        switch supabase.authState {
        case .anonymous:
            return "Anonymous"
        case .authenticated(_, let email):
            return email ?? "Signed In"
        case .signedOut, .unknown:
            return "Not Connected"
        }
    }

    private var accountSubtitle: String {
        switch supabase.authState {
        case .anonymous:
            return "Sign in to sync across devices"
        case .authenticated:
            return "Settings synced"
        case .signedOut, .unknown:
            return "Connect to enable sync"
        }
    }

    @ViewBuilder
    private var accountActionButton: some View {
        switch supabase.authState {
        case .anonymous:
            Button("Upgrade") {
                // TODO: Show sign in sheet
            }
            .font(.caption)
            .buttonStyle(.borderedProminent)
            .tint(.laMylLavender)
            .controlSize(.small)

        case .authenticated:
            Menu {
                Button("Sign Out", role: .destructive) {
                    Task {
                        await supabase.signOut()
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .menuStyle(.borderlessButton)

        case .signedOut, .unknown:
            Button("Connect") {
                Task {
                    try? await supabase.signInAnonymously()
                }
            }
            .font(.caption)
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }

    // MARK: - Preview

    private var previewButton: some View {
        Button(action: {
            audioEngine.playPreview()
        }) {
            HStack {
                Image(systemName: "play.circle.fill")
                Text("Preview Sound")
            }
            .font(.body)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            Button(action: openSettings) {
                Text("Settings")
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)

            Spacer()

            Button(action: quitApp) {
                Text("Quit")
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .font(.subheadline)
    }

    private func openSettings() {
        // Open System Settings > Privacy > Accessibility
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    private func quitApp() {
        NSApp.terminate(nil)
    }
}

#Preview {
    MenuBarView(
        audioEngine: AudioEngine(),
        keyboardManager: KeyboardManager(audioEngine: AudioEngine())
    )
}
