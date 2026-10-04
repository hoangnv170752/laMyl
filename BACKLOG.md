# laMyl — Product Backlog

> **laMyl**
> *sounds good. feels better.*

## 1. Product Vision

laMyl is an audio application for computer users, inspired by the **mechanical keyboard** typing experience.

Rather than simply simulating keyboard sounds, laMyl aims to create a **pleasant working soundscape** that helps users feel focused, relaxed, and inspired.

### Core Idea

> **Make every keystroke feel better.**

### Product Direction

```text
Keyboard Sounds
      ↓
Sound Customization
      ↓
Mood / Atmosphere
      ↓
Focus & Productivity
```

---

## 2. Target Users

### Primary

- Developer / Programmer
- Designer
- Writer
- Student
- Content creator
- Remote worker
- Mechanical keyboard enthusiast
- ASMR / typing sounds lover

### User Needs

- Want to hear mechanical keyboard sounds when using a laptop.
- Want clear typing sounds without turning Mac speakers too loud.
- Want to choose between different switch / keyboard sound types.
- Want pleasant audio during long work sessions.
- Want to create a personal sound environment for different work states.

---

## 3. MVP Scope

### MVP Goal

Users can:

1. Open laMyl.
2. Select a keyboard sound.
3. Type anywhere on Mac.
4. laMyl plays corresponding sounds for each key.
5. Adjust volume.
6. Use **Low Volume Boost** to hear clearly at low system volume.
7. Quickly toggle laMyl from the menu bar.
8. Select sound presets.

### MVP Must Feel

- Instant
- Lightweight
- Minimal
- Calm
- Premium
- Non-distracting

---

## 4. Product Backlog

### Epic 01 — macOS Foundation

#### P0 — MVP

- [ ] Create macOS application project.
- [ ] Set up app lifecycle.
- [ ] Set up Menu Bar app.
- [ ] No requirement for a persistent main window.
- [ ] App can run in background.
- [ ] App can Start / Stop.
- [ ] App can Quit completely.
- [ ] Set up required permissions for keyboard input detection.
- [ ] Handle system-wide keyboard events.
- [ ] Do not block or modify original keyboard input.
- [ ] Do not send user keystroke content outside the app.

#### Acceptance Criteria

- App runs stably while using other apps.
- Keyboard works normally.
- No abnormal CPU usage.
- Can toggle sound without restarting app.

---

### Epic 02 — Keyboard Sound Engine

#### P0 — MVP

- [ ] Build Audio Engine.
- [ ] Load audio samples into memory.
- [ ] Preload frequently used samples.
- [ ] Map key → sound.
- [ ] Support press sound.
- [ ] Support release sound if needed.
- [ ] Random variation between keystrokes.
- [ ] Subtle random pitch variation.
- [ ] Random volume variation.
- [ ] Avoid obvious sound repetition.
- [ ] Handle multiple consecutive key events.
- [ ] Voice pooling to prevent excessive audio overlap.
- [ ] Limit simultaneous audio voices.

#### P1

- [ ] Velocity-sensitive sound.
- [ ] Key-specific sound.
- [ ] Separate spacebar sound.
- [ ] Separate enter sound.
- [ ] Separate backspace sound.
- [ ] Separate modifier key sound.
- [ ] Different sound for mouse click.

---

### Epic 03 — Keyboard Sound Library

#### P0 — MVP

Minimum 5–8 sound profiles.

##### Suggested Profiles

- [ ] Soft Linear
- [ ] Deep Thock
- [ ] Creamy
- [ ] Tactile
- [ ] Clicky
- [ ] Silent
- [ ] Typewriter
- [ ] Retro

##### Each Profile Includes

- [ ] Name
- [ ] Short description
- [ ] Preview button
- [ ] Audio samples
- [ ] Default volume
- [ ] Character / mood

#### P1

- [ ] Gateron-style Linear
- [ ] Cherry-style Brown
- [ ] Blue Click
- [ ] Holy Panda-style Tactile
- [ ] Cream switch
- [ ] Topre-style
- [ ] Buckling Spring
- [ ] Low-profile keyboard

> Note: If using third-party names/brands/sound recordings, verify usage rights and licensing before release.

---

### Epic 04 — Low Volume Boost

#### P0 — Key Differentiator

Goal:

> **Keyboard audio remains clear, full, and pleasant even when Mac system volume is low.**

##### Audio Processing

- [ ] Input gain control.
- [ ] Loudness normalization.
- [ ] Gentle compression.
- [ ] Transient enhancement.
- [ ] EQ for speech/keyboard presence.
- [ ] Warmth control.
- [ ] Thock enhancement.
- [ ] Limiter to prevent clipping.
- [ ] Auto gain compensation.

##### UI

```text
Volume
────────────●────

Low Volume Boost       ON

Clarity
───────●────────

Warmth
──────●─────────

Thock
────────●───────
```

##### Acceptance Criteria

- No clipping.
- No unpleasant distortion.
- No harsh key sounds.
- Clear audio at low system volume.
- No fatigue during extended use.

---

### Epic 05 — Main Menu Bar UI

#### P0

Menu Bar popup:

```text
laMyl

● Deep Thock
  Soft Linear
  Creamy
  Typewriter
  ...

Volume
────────────●──

Low Volume Boost     ON

────────────────────

Pause Sound
Settings
Quit laMyl
```

##### Tasks

- [ ] Menu bar icon.
- [ ] Popup panel.
- [ ] Current sound indicator.
- [ ] Sound selector.
- [ ] Volume slider.
- [ ] Play / Pause.
- [ ] Low Volume Boost toggle.
- [ ] Settings entry.
- [ ] Quit.

---

### Epic 06 — Sound Preview

#### P0

- [ ] Preview button for each sound.
- [ ] Preview without keyboard event.
- [ ] Short preview sample.
- [ ] Preview multiple consecutive keys.
- [ ] Optional preview loop.

#### P1

- [ ] Compare 2 sounds.
- [ ] A/B testing.
- [ ] Visual waveform.
- [ ] Spectrogram.

---

### Epic 07 — Settings

#### P0

##### General

- [ ] Launch at login.
- [ ] Start sound automatically.
- [ ] Enable / disable keyboard sounds.
- [ ] Default sound.
- [ ] Default volume.

##### Audio

- [ ] Volume.
- [ ] Low Volume Boost.
- [ ] Clarity.
- [ ] Warmth.
- [ ] Thock.
- [ ] Max simultaneous sounds.

##### Privacy

- [ ] Explain keyboard monitoring.
- [ ] Explain that key content is not recorded.
- [ ] Explain that no keystrokes are stored.
- [ ] Explain that no text is transmitted.

---

### Epic 08 — Global Keyboard Shortcuts

#### P1

- [ ] Toggle sound.
- [ ] Next sound.
- [ ] Previous sound.
- [ ] Volume up.
- [ ] Volume down.
- [ ] Pause / resume.

##### Suggested Defaults

```text
⌥ + Space       Toggle sound
⌥ + ↑           Volume up
⌥ + ↓           Volume down
⌥ + ←           Previous sound
⌥ + →           Next sound
```

Shortcut mapping should be configurable.

---

### Epic 08.1 — Multi-Language Support

#### P1

Support multiple languages for the entire app UI.

##### Supported Languages

- [ ] English (default)
- [ ] Vietnamese (Tiếng Việt)
- [ ] French (Français)
- [ ] Chinese (中文 - Simplified & Traditional)

##### Tasks

- [ ] Set up localization infrastructure (Localizable.strings).
- [ ] Create string catalogs for each language.
- [ ] Localize all UI text (menu bar, settings, onboarding).
- [ ] Localize sound profile names and descriptions.
- [ ] Localize error messages and alerts.
- [ ] Auto-detect system language preference.
- [ ] Allow manual language selection in Settings.
- [ ] Support right-to-left layouts if needed for future languages.
- [ ] Test all UI layouts with longer translated strings.

##### Settings UI

```text
Language
────────────────────
○ System Default
● English
○ Tiếng Việt
○ Français
○ 中文 (简体)
○ 中文 (繁體)
```

##### Acceptance Criteria

- App respects macOS system language by default.
- User can override language in Settings.
- All visible text is properly translated.
- UI does not break with longer translations.
- Language change applies immediately without restart.

---

### Epic 09 — Presets / Mood

#### P1 — Post MVP

Introduce the idea:

> **How do you want to feel?**

##### Presets

- [ ] Deep Focus
- [ ] Calm
- [ ] Cozy
- [ ] Creative
- [ ] Coding
- [ ] Writing
- [ ] Study
- [ ] Late Night

Example:

```text
Deep Focus

Keyboard
Deep Thock

Keyboard Volume
70%

Ambient
Rain

Ambient Volume
20%

Low Volume Boost
ON
```

---

### Epic 10 — Ambient Sounds

#### P1

- [ ] Rain
- [ ] Café
- [ ] Fireplace
- [ ] Library
- [ ] Office
- [ ] Night city
- [ ] Forest
- [ ] Ocean

##### Mixer

```text
Keyboard       70%
Rain           20%
Cafe           10%
```

---

### Epic 11 — Focus Timer

#### P2

- [ ] 25-minute timer.
- [ ] 50-minute timer.
- [ ] Custom timer.
- [ ] Break timer.
- [ ] Session history.
- [ ] Start sound with timer.
- [ ] Automatically stop sound at end of session.

---

### Epic 12 — Personalization

#### P2

- [ ] Favorite sounds.
- [ ] Recently used sounds.
- [ ] Custom presets.
- [ ] Save mixer configuration.
- [ ] Rename presets.
- [ ] Import custom audio samples.
- [ ] Custom key mapping.

---

### Epic 13 — Sound Designer

#### P2

Advanced sound customization:

```text
Sample
↓
EQ
↓
Compression
↓
Transient
↓
Reverb
↓
Limiter
```

Features:

- [ ] EQ.
- [ ] Compressor.
- [ ] Reverb.
- [ ] Stereo width.
- [ ] Pitch.
- [ ] Attack.
- [ ] Release.
- [ ] Randomization.
- [ ] Save as custom sound.

---

### Epic 14 — Analytics / Telemetry

#### MVP Principle

**Do not collect keyboard content.**

Potential anonymous product analytics:

- [ ] App launched.
- [ ] Sound selected.
- [ ] Sound duration.
- [ ] Feature usage.
- [ ] Crash reports.

Never collect:

- [ ] Actual typed text.
- [ ] Passwords.
- [ ] Keyboard content.
- [ ] Key sequences that could reconstruct user input.

Analytics should be opt-in or clearly disclosed depending on implementation and applicable platform requirements.

---

### Epic 15 — Onboarding

#### P1

First launch:

```text
Welcome to laMyl

sounds good.
feels better.

Choose your sound.

[ Deep Thock ]

[ Soft Linear ]

[ Creamy ]

[ Typewriter ]

        Start
```

Then:

```text
laMyl needs permission
to respond to your keyboard.

Your keystrokes stay on your Mac.
laMyl does not record what you type.

[ Enable Keyboard Access ]
```

---

### Epic 16 — Branding

#### Brand

**laMyl**

##### Tagline

> **sounds good. feels better.**

##### Brand Attributes

- Calm
- Modern
- Minimal
- Creative
- Premium
- Playful
- Personal

##### Visual Direction

- Minimal UI.
- Soft gradients.
- Dark mode first.
- Subtle animation.
- Rounded surfaces.
- Strong typography.
- Very little visual noise.

---

### Epic 17 — App Store Readiness

#### P0

- [ ] App icon.
- [ ] App name.
- [ ] App description.
- [ ] Privacy policy.
- [ ] Permissions explanation.
- [ ] Accessibility / Input Monitoring explanation where applicable.
- [ ] Crash testing.
- [ ] Memory leak testing.
- [ ] CPU usage testing.
- [ ] Audio latency testing.
- [ ] Multiple Mac models testing.
- [ ] Apple Silicon testing.
- [ ] Intel Mac testing if supported.
- [ ] macOS version compatibility.
- [ ] Code signing.
- [ ] Hardened Runtime.
- [ ] Notarization.
- [ ] App Store sandbox requirements.
- [ ] App Store screenshots.
- [ ] Review notes.

---

## 5. Technical Architecture

Suggested architecture:

```text
┌─────────────────────────────┐
│          laMyl UI           │
│      SwiftUI / AppKit       │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       App State / Store      │
└──────────────┬──────────────┘
               │
       ┌───────┴────────┐
       ▼                ▼
Keyboard Manager    Settings
       │
       ▼
┌─────────────────────────────┐
│       Audio Engine          │
│                             │
│ Sample Manager              │
│ Voice Pool                  │
│ Mixer                       │
│ EQ                          │
│ Compressor                  │
│ Limiter                     │
│ Loudness Compensation       │
└──────────────┬──────────────┘
               │
               ▼
          Core Audio
```

---

## 6. Recommended Technology

### Platform

**macOS**

### Language

**Swift**

### UI

**SwiftUI**

### System Integration

- CGEvent / relevant macOS event APIs
- Accessibility / Input Monitoring permissions
- MenuBarExtra
- AppKit where required

### Audio

Prefer Apple's native audio stack:

- AVAudioEngine
- AVAudioPlayerNode
- AVAudioPCMBuffer
- AVAudioUnitEQ
- AVAudioUnitDynamicsProcessor
- AVAudioUnitReverb
- AVAudioUnitDistortion only if needed
- AVAudioMixerNode

Avoid unnecessary external dependencies for MVP.

---

## 7. Performance Requirements

### Target

- CPU idle: very low.
- CPU during typing: negligible.
- Memory: ideally <100 MB for MVP.
- Audio latency: target <30 ms.
- No audible clicks/pops.
- No audio dropouts during fast typing.
- No noticeable input lag.

### Stress Test

Simulate:

- 5 keys/sec.
- 10 keys/sec.
- 15+ keys/sec.
- Key combinations.
- Long continuous typing.
- Holding modifier keys.
- Switching applications rapidly.

---

## 8. MVP Definition of Done

The MVP is ready when:

- [ ] laMyl runs as a macOS menu bar app.
- [ ] User can grant required keyboard permission.
- [ ] User can type anywhere on Mac and hear keyboard sounds.
- [ ] At least 5 high-quality sound profiles exist.
- [ ] Audio latency feels instant.
- [ ] Sound does not interfere with keyboard input.
- [ ] Volume can be adjusted.
- [ ] Low Volume Boost works.
- [ ] App uses very little CPU.
- [ ] App can launch at login.
- [ ] App can be paused instantly.
- [ ] Basic settings work.
- [ ] Privacy messaging is clear.
- [ ] App survives long typing sessions without crashes.

---

## 9. Post-MVP Roadmap

### Version 0.1 — Prototype

- Keyboard event detection
- One sound
- Basic audio playback
- Menu bar

### Version 0.2 — MVP

- 5–8 sounds
- Sound selector
- Volume
- Low Volume Boost
- Settings
- Launch at login
- Privacy UX

### Version 0.3 — Experience

- Favorites
- Presets
- Better sound variation
- Keyboard-specific sounds
- Better onboarding
- Premium UI polish

### Version 0.5 — Soundscape

- Ambient sounds
- Mixer
- Mood presets
- Focus mode

### Version 1.0 — Productivity

- Focus timer
- Custom soundscape
- Custom presets
- Statistics
- Cloud sync if justified

---

## 10. Future Monetization

Potential model:

### Free

- 3–5 keyboard sounds
- Basic volume
- Basic Low Volume Boost

### Pro

- Full sound library
- Advanced audio controls
- Ambient sounds
- Custom presets
- Focus mode
- Custom sound import

Possible pricing:

- Monthly subscription
- Annual subscription
- One-time purchase

For this product, **one-time purchase or lifetime unlock should be seriously considered**, because the core utility does not necessarily justify a subscription.

---

## 11. Product Principles

### 01 — Sound First

Audio quality is more important than feature count.

### 02 — Low Distraction

laMyl should improve the working environment, not become another app demanding attention.

### 03 — Instant

The user should press a key and hear the sound immediately.

### 04 — Soft by Default

Default sounds should be comfortable for long sessions.

### 05 — Privacy First

Keyboard events are sensitive.

> **laMyl reacts to your keys.
> It never needs to know what you type.**

### 06 — Feel Over Specifications

Do not overwhelm normal users with switch specifications.

Instead of:

> 55g actuation / 2mm travel / 4mm bottom-out

Prefer:

> **Soft · Deep · Creamy**

Technical details can remain available for enthusiasts.

---

## 12. Core Differentiator

The key product opportunity is not:

> "Another mechanical keyboard sound app."

It is:

> **A better-sounding work environment at any volume.**

### laMyl Promise

> **sounds good. feels better.**

The ideal user experience:

```text
Open Mac
   ↓
Start working
   ↓
laMyl quietly comes alive
   ↓
Every keystroke sounds satisfying
   ↓
No need to turn the speakers up
   ↓
You stay in the flow
```

---

## 13. First Development Sprint

### Sprint 01 — Audio Proof of Concept

#### Goal

Prove that the core interaction feels good.

#### Tasks

- [ ] Create Swift macOS app.
- [ ] Add menu bar icon.
- [ ] Capture keyboard events.
- [ ] Play one high-quality keyboard sample.
- [ ] Measure input → audio latency.
- [ ] Implement voice pooling.
- [ ] Implement volume control.
- [ ] Implement basic limiter.
- [ ] Test fast typing.
- [ ] Test system volume at 10%, 20%, 30%.
- [ ] Test Low Volume Boost.
- [ ] Record demo video.

#### Success Criteria

> **At 20–30% Mac volume, the keyboard should still sound clear, satisfying and natural.**

If this feels good, continue building the rest of laMyl.

---

## 14. Backlog Priority Legend

| Priority | Meaning |
|---|---|
| P0 | Required for MVP |
| P1 | Important after MVP |
| P2 | Future / advanced |
| P3 | Nice to have |

---

## 15. Product North Star

> **laMyl should make people want to keep typing.**

Not because they have to.

Because it **sounds good. feels better.**
