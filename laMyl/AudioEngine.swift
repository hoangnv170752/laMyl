//
//  AudioEngine.swift
//  laMyl
//
//  Core audio engine for playing keyboard sounds
//

import AVFoundation
import Combine

class AudioEngine: ObservableObject {
    private var engine: AVAudioEngine
    private var players: [AVAudioPlayerNode] = []
    private var mixer: AVAudioMixerNode
    private var cancellables = Set<AnyCancellable>()

    // Sound buffers
    private var keySounds: [AVAudioPCMBuffer] = []
    private var spaceSound: AVAudioPCMBuffer?

    // Settings - synced with SettingsManager
    @Published var volume: Float {
        didSet {
            mixer.outputVolume = effectiveVolume
            SettingsManager.shared.volume = volume
        }
    }
    @Published var isEnabled: Bool {
        didSet {
            SettingsManager.shared.isEnabled = isEnabled
        }
    }
    @Published var lowVolumeBoost: Bool {
        didSet {
            mixer.outputVolume = effectiveVolume
            SettingsManager.shared.lowVolumeBoost = lowVolumeBoost
        }
    }

    private var effectiveVolume: Float {
        lowVolumeBoost ? min(volume * 1.5, 1.0) : volume
    }

    // Voice pooling
    private let maxVoices = 8
    private var currentVoiceIndex = 0

    init() {
        // Load settings
        let settings = SettingsManager.shared
        self.volume = settings.volume
        self.isEnabled = settings.isEnabled
        self.lowVolumeBoost = settings.lowVolumeBoost

        engine = AVAudioEngine()
        mixer = engine.mainMixerNode

        setupPlayers()
        loadSounds()
        startEngine()
    }

    private func setupPlayers() {
        for _ in 0..<maxVoices {
            let player = AVAudioPlayerNode()
            engine.attach(player)
            engine.connect(player, to: mixer, format: nil)
            players.append(player)
        }
    }

    private func loadSounds() {
        // Load key sounds
        let keyFiles = ["key1", "key2", "key3"]
        for keyFile in keyFiles {
            if let buffer = loadAudioFile(named: keyFile) {
                keySounds.append(buffer)
            }
        }

        // Load space sound
        spaceSound = loadAudioFile(named: "space1")

        print("[AudioEngine] Loaded \(keySounds.count) key sounds, space: \(spaceSound != nil)")
    }

    private func loadAudioFile(named name: String) -> AVAudioPCMBuffer? {
        // Try to find in Resources folder first, then root bundle
        var url = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "Resources")
        if url == nil {
            url = Bundle.main.url(forResource: name, withExtension: "mp3")
        }

        guard let fileUrl = url else {
            print("[AudioEngine] Could not find \(name).mp3")
            return nil
        }

        do {
            let file = try AVAudioFile(forReading: fileUrl)
            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)

            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                return nil
            }

            try file.read(into: buffer)
            return buffer
        } catch {
            print("[AudioEngine] Error loading \(name): \(error)")
            return nil
        }
    }

    private func startEngine() {
        do {
            // On macOS, AVAudioEngine handles low latency automatically
            // Just start the engine directly
            try engine.start()
            mixer.outputVolume = effectiveVolume
            print("[AudioEngine] Started successfully")
        } catch {
            print("[AudioEngine] Failed to start: \(error)")
        }
    }

    func stop() {
        engine.stop()
    }

    // MARK: - Play sounds

    func playKeySound() {
        guard isEnabled, !keySounds.isEmpty else { return }

        // Random sound selection for variation
        let randomIndex = Int.random(in: 0..<keySounds.count)
        let buffer = keySounds[randomIndex]

        playBuffer(buffer, withVariation: true)
    }

    func playSpaceSound() {
        guard isEnabled, let buffer = spaceSound else {
            playKeySound() // Fallback to key sound
            return
        }

        playBuffer(buffer, withVariation: false)
    }

    func playEnterSound() {
        // Use space sound or key sound for now
        playSpaceSound()
    }

    private func playBuffer(_ buffer: AVAudioPCMBuffer, withVariation: Bool) {
        let player = players[currentVoiceIndex]
        currentVoiceIndex = (currentVoiceIndex + 1) % maxVoices

        // Stop if already playing
        if player.isPlaying {
            player.stop()
        }

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    // MARK: - Preview

    func playPreview() {
        playKeySound()

        // Play a sequence of sounds for preview
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.playKeySound()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.playKeySound()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.playSpaceSound()
        }
    }
}
