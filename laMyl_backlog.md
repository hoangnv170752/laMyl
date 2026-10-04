# laMyl — Product Backlog

> **laMyl**  
> *sounds good. feels better.*

## 1. Product Vision

laMyl là một ứng dụng âm thanh dành cho người làm việc trên máy tính, lấy cảm hứng từ trải nghiệm **gõ bàn phím cơ**.

Thay vì chỉ mô phỏng tiếng keyboard, laMyl hướng tới việc tạo ra một **âm thanh làm việc dễ chịu**, giúp người dùng cảm thấy tập trung, thư giãn và có cảm hứng hơn.

### Core idea

> **Make every keystroke feel better.**

### Product direction

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

# 2. Target Users

## Primary

- Developer / Programmer
- Designer
- Writer
- Student
- Content creator
- Remote worker
- Mechanical keyboard enthusiast
- Người thích ASMR / typing sounds

## User needs

- Muốn nghe tiếng keyboard cơ học khi dùng laptop.
- Muốn tiếng gõ rõ nhưng không cần bật loa Mac quá lớn.
- Muốn lựa chọn giữa nhiều loại switch / keyboard sound.
- Muốn âm thanh dễ chịu khi làm việc trong thời gian dài.
- Muốn tạo không gian âm thanh riêng cho từng trạng thái làm việc.

---

# 3. MVP Scope

## MVP Goal

Người dùng có thể:

1. Mở laMyl.
2. Chọn một keyboard sound.
3. Gõ bất kỳ đâu trên Mac.
4. laMyl phát âm thanh tương ứng với từng phím.
5. Điều chỉnh volume.
6. Sử dụng **Low Volume Boost** để nghe rõ ở mức volume hệ thống thấp.
7. Bật/tắt nhanh laMyl từ menu bar.
8. Chọn preset âm thanh.

### MVP must feel

- Instant
- Lightweight
- Minimal
- Calm
- Premium
- Không gây phân tâm

---

# 4. Product Backlog

## Epic 01 — macOS Foundation

### P0 — MVP

- [ ] Tạo macOS application project.
- [ ] Thiết lập app lifecycle.
- [ ] Thiết lập Menu Bar app.
- [ ] Không yêu cầu mở một cửa sổ chính liên tục.
- [ ] App có thể chạy background.
- [ ] App có thể Start / Stop.
- [ ] App có thể Quit hoàn toàn.
- [ ] Thiết lập permission cần thiết để nhận biết keyboard input.
- [ ] Xử lý keyboard event toàn hệ thống.
- [ ] Không block hoặc thay đổi keyboard input gốc.
- [ ] Không gửi nội dung phím người dùng ra ngoài app.

### Acceptance Criteria

- App chạy ổn định khi sử dụng các app khác.
- Keyboard vẫn hoạt động bình thường.
- Không làm tăng CPU bất thường.
- Có thể bật/tắt sound mà không restart app.

---

# Epic 02 — Keyboard Sound Engine

## P0 — MVP

- [ ] Xây dựng Audio Engine.
- [ ] Load audio samples vào memory.
- [ ] Preload các sample thường dùng.
- [ ] Mapping key → sound.
- [ ] Hỗ trợ press sound.
- [ ] Hỗ trợ release sound nếu cần.
- [ ] Random variation giữa các lần gõ.
- [ ] Random pitch variation rất nhẹ.
- [ ] Random volume variation.
- [ ] Tránh âm thanh bị lặp quá rõ.
- [ ] Xử lý nhiều key event liên tục.
- [ ] Voice pooling để tránh audio overlap quá mức.
- [ ] Giới hạn số audio voices đồng thời.

### P1

- [ ] Velocity-sensitive sound.
- [ ] Key-specific sound.
- [ ] Spacebar sound riêng.
- [ ] Enter sound riêng.
- [ ] Backspace sound riêng.
- [ ] Modifier key sound riêng.
- [ ] Different sound cho mouse click.

---

# Epic 03 — Keyboard Sound Library

## P0 — MVP

Tối thiểu 5–8 sound profiles.

### Suggested profiles

- [ ] Soft Linear
- [ ] Deep Thock
- [ ] Creamy
- [ ] Tactile
- [ ] Clicky
- [ ] Silent
- [ ] Typewriter
- [ ] Retro

### Mỗi profile

- [ ] Name
- [ ] Short description
- [ ] Preview button
- [ ] Audio samples
- [ ] Default volume
- [ ] Character / mood

### P1

- [ ] Gateron-style Linear
- [ ] Cherry-style Brown
- [ ] Blue Click
- [ ] Holy Panda-style Tactile
- [ ] Cream switch
- [ ] Topre-style
- [ ] Buckling Spring
- [ ] Low-profile keyboard

> Lưu ý: nếu sử dụng tên/thương hiệu/sound recording của bên thứ ba, cần kiểm tra quyền sử dụng và licensing trước khi phát hành.

---

# Epic 04 — Low Volume Boost

## P0 — Key Differentiator

Mục tiêu:

> **Âm thanh keyboard vẫn rõ, dày và dễ nghe khi system volume của Mac ở mức thấp.**

### Audio processing

- [ ] Input gain control.
- [ ] Loudness normalization.
- [ ] Gentle compression.
- [ ] Transient enhancement.
- [ ] EQ cho speech/keyboard presence.
- [ ] Warmth control.
- [ ] Thock enhancement.
- [ ] Limiter chống clipping.
- [ ] Auto gain compensation.

### UI

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

### Acceptance Criteria

- Không clipping.
- Không tạo distortion khó chịu.
- Không làm tiếng phím quá chói.
- Có thể nghe rõ ở system volume thấp.
- Không gây fatigue khi sử dụng lâu.

---

# Epic 05 — Main Menu Bar UI

## P0

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

### Tasks

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

# Epic 06 — Sound Preview

## P0

- [ ] Preview button cho từng sound.
- [ ] Preview không cần keyboard event.
- [ ] Preview sample ngắn.
- [ ] Preview nhiều phím liên tiếp.
- [ ] Preview loop tùy chọn.

## P1

- [ ] Compare 2 sounds.
- [ ] A/B testing.
- [ ] Visual waveform.
- [ ] Spectrogram.

---

# Epic 07 — Settings

## P0

### General

- [ ] Launch at login.
- [ ] Start sound automatically.
- [ ] Enable / disable keyboard sounds.
- [ ] Default sound.
- [ ] Default volume.

### Audio

- [ ] Volume.
- [ ] Low Volume Boost.
- [ ] Clarity.
- [ ] Warmth.
- [ ] Thock.
- [ ] Max simultaneous sounds.

### Privacy

- [ ] Explain keyboard monitoring.
- [ ] Explain that key content is not recorded.
- [ ] Explain that no keystrokes are stored.
- [ ] Explain that no text is transmitted.

---

# Epic 08 — Global Keyboard Shortcuts

## P1

- [ ] Toggle sound.
- [ ] Next sound.
- [ ] Previous sound.
- [ ] Volume up.
- [ ] Volume down.
- [ ] Pause / resume.

### Suggested defaults

```text
⌥ + Space       Toggle sound
⌥ + ↑           Volume up
⌥ + ↓           Volume down
⌥ + ←           Previous sound
⌥ + →           Next sound
```

Shortcut mapping should be configurable.

---

# Epic 09 — Presets / Mood

## P1 — Post MVP

Introduce the idea:

> **How do you want to feel?**

### Presets

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

# Epic 10 — Ambient Sounds

## P1

- [ ] Rain
- [ ] Café
- [ ] Fireplace
- [ ] Library
- [ ] Office
- [ ] Night city
- [ ] Forest
- [ ] Ocean

### Mixer

```text
Keyboard       70%
Rain           20%
Cafe           10%
```

---

# Epic 11 — Focus Timer

## P2

- [ ] 25-minute timer.
- [ ] 50-minute timer.
- [ ] Custom timer.
- [ ] Break timer.
- [ ] Session history.
- [ ] Start sound with timer.
- [ ] Automatically stop sound at end of session.

---

# Epic 12 — Personalization

## P2

- [ ] Favorite sounds.
- [ ] Recently used sounds.
- [ ] Custom presets.
- [ ] Save mixer configuration.
- [ ] Rename presets.
- [ ] Import custom audio samples.
- [ ] Custom key mapping.

---

# Epic 13 — Sound Designer

## P2

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

# Epic 14 — Analytics / Telemetry

## MVP principle

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

# Epic 15 — Onboarding

## P1

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

# Epic 16 — Branding

## Brand

**laMyl**

### Tagline

> **sounds good. feels better.**

### Brand attributes

- Calm
- Modern
- Minimal
- Creative
- Premium
- Playful
- Personal

### Visual direction

- Minimal UI.
- Soft gradients.
- Dark mode first.
- Subtle animation.
- Rounded surfaces.
- Strong typography.
- Very little visual noise.

---

# Epic 17 — App Store Readiness

## P0

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

# 5. Technical Architecture

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

# 6. Recommended Technology

## Platform

**macOS**

## Language

**Swift**

## UI

**SwiftUI**

## System integration

- CGEvent / relevant macOS event APIs
- Accessibility / Input Monitoring permissions
- MenuBarExtra
- AppKit where required

## Audio

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

# 7. Performance Requirements

### Target

- CPU idle: very low.
- CPU during typing: negligible.
- Memory: ideally <100 MB for MVP.
- Audio latency: target <30 ms.
- No audible clicks/pops.
- No audio dropouts during fast typing.
- No noticeable input lag.

### Stress test

Simulate:

- 5 keys/sec.
- 10 keys/sec.
- 15+ keys/sec.
- Key combinations.
- Long continuous typing.
- Holding modifier keys.
- Switching applications rapidly.

---

# 8. MVP Definition of Done

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

# 9. Post-MVP Roadmap

## Version 0.1 — Prototype

- Keyboard event detection
- One sound
- Basic audio playback
- Menu bar

## Version 0.2 — MVP

- 5–8 sounds
- Sound selector
- Volume
- Low Volume Boost
- Settings
- Launch at login
- Privacy UX

## Version 0.3 — Experience

- Favorites
- Presets
- Better sound variation
- Keyboard-specific sounds
- Better onboarding
- Premium UI polish

## Version 0.5 — Soundscape

- Ambient sounds
- Mixer
- Mood presets
- Focus mode

## Version 1.0 — Productivity

- Focus timer
- Custom soundscape
- Custom presets
- Statistics
- Cloud sync if justified

---

# 10. Future Monetization

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

# 11. Product Principles

### 01 — Sound first

Audio quality is more important than feature count.

### 02 — Low distraction

laMyl should improve the working environment, not become another app demanding attention.

### 03 — Instant

The user should press a key and hear the sound immediately.

### 04 — Soft by default

Default sounds should be comfortable for long sessions.

### 05 — Privacy first

Keyboard events are sensitive.

> **laMyl reacts to your keys.  
> It never needs to know what you type.**

### 06 — Feel over specifications

Do not overwhelm normal users with switch specifications.

Instead of:

> 55g actuation / 2mm travel / 4mm bottom-out

Prefer:

> **Soft · Deep · Creamy**

Technical details can remain available for enthusiasts.

---

# 12. Core Differentiator

The key product opportunity is not:

> "Another mechanical keyboard sound app."

It is:

> **A better-sounding work environment at any volume.**

### laMyl promise

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

# 13. First Development Sprint

## Sprint 01 — Audio Proof of Concept

### Goal

Prove that the core interaction feels good.

### Tasks

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

### Success criteria

> **At 20–30% Mac volume, the keyboard should still sound clear, satisfying and natural.**

If this feels good, continue building the rest of laMyl.

---

# 14. Backlog Priority Legend

| Priority | Meaning |
|---|---|
| P0 | Required for MVP |
| P1 | Important after MVP |
| P2 | Future / advanced |
| P3 | Nice to have |

---

# 15. Product North Star

> **laMyl should make people want to keep typing.**

Not because they have to.

Because it **sounds good. feels better.**
