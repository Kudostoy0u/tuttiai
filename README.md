# Tutti 🎶 – Your AI-Powered Music Companion

Tutti turns every practice session into a smart, data-driven experience. Whether you are a beginner or a concert-level performer, Tutti provides everything you need in one elegant, cross-platform app.

---

## ✨ Feature Highlights

| Category | What you get |
|----------|--------------|
| **Smart Recommendations** | • AI-curated sheet-music feed matching your instrument, skill level, genres & goals.<br>• Real-time match % and difficulty tags.<br>• Listen to professional recordings before downloading.<br>• One-tap *Add to Library* syncs charts across all devices. |
| **Tuner & Intonation** | • Ultra-precise tuner (< ±0.1 cent) with visual meter & reference tones.<br>• Automatic instrument presets and manual pitch entry.<br>• Intonation mode shows live cents-offset graph while you play. |
| **Metronome+** | • Tap-tempo, subdivisions, complex accent patterns, haptic & audio click.<br>• Pendulum animation for visual timing.<br>• Save favourite tempos by piece. |
| **Recording Analyzer** | • One-tap high-quality recording.<br>• Waveform & loudness display while you play.<br>• Automatic trimming, renaming, cloud-sync & share.<br>• Pitch/tempo analysis roadmap. |
| **Practice Log** | • Automatic streak tracking & weekly/hourly stats.<br>• Practice reminders with custom time.<br>• Export log to CSV/Google Sheets. |
| **Library** | • Organise sheet music, recordings & favourites in one place.<br>• Powerful filters & search.<br>• Offline caching & version history. |
| **Account & Sync** | • Secure email / social-login (Supabase Auth).<br>• Preferences, library & stats backed up in real-time.<br>• Multi-device hot-reload – pick up practice on any phone, tablet or desktop. |
| **Global Localisation** | • 7 languages shipped (EN, DE, ES, FR, IT, ZH, HI).<br>• Automatic locale detection & dynamic switching in Settings. |

---

## Screenshots
*(Insert up-to-date screenshots / GIFs here to visually showcase major features.)*

---

## Tech Stack

* **Flutter 3.19** – single code-base for iOS, Android, macOS, Windows & Web.
* **Supabase** – Auth, storage & Postgres-powered backend.
* **Provider + Riverpod** – clean state-management.
* **just_audio / record / pitch_detector_dart** – low-latency audio engine.
* **SharedPreferences** – instant local persistence.
* **Google Fonts + Material 3** – modern, accessible UI.

---

## Getting Started

```bash
# 1. Clone
$ git clone https://github.com/your-org/tutti.git && cd tuttiai

# 2. Install dependencies
$ flutter pub get

# 3. (Optionally) set Supabase env keys
$ cp .env.example .env && nano .env

# 4. Run on device / simulator
$ flutter run
```

### Build Targets

```bash
flutter build apk         # Android
flutter build ios         # iOS (Xcode required)
flutter build macos       # macOS desktop
flutter build windows     # Windows desktop
flutter build web         # PWAs & shareable links
```

---

## Contributing

1. Fork the repo & create a feature branch.
2. Follow Conventional Commits for clear history.
3. Run `flutter analyze` + unit tests before PR.
4. Submit pull request – every PR runs CI with multiple device simulators.

Looking for translations? Add a new language list to `_keyTranslations` in **`lib/services/localization_service.dart`**.

---

## Roadmap

- 🎤 Real-time pitch & rhythm scoring.
- 🧠 LLM-powered practice coach (feedback & suggestions).
- 📝 Automatic fingerings & bowings on imported scores.
- 🌐 Community sharing & peer feedback videos.

---

## License

Licensed under the MIT License – see `LICENSE` for details.

> *Tutti – practice smarter, play better.*
