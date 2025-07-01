# Tutti 🎵

Your AI-powered music companion for smart sheet music recommendations and comprehensive music practice tools.

## Features

### 🎼 Smart Sheet Music Recommendations
- AI-powered suggestions based on your skill level, preferences, and practice history
- Personalized recommendations with match percentages
- Filter by genre, difficulty, and rating
- Preview and add to library functionality

### 🎛️ Music Tools Hub
- **Tuning**: Precise instrument tuning with visual feedback
- **Intonation Checker**: Real-time pitch accuracy analysis with visual graphs
- **Metronome**: Digital metronome with customizable tempo and time signatures
- **Recording Library**: Record and organize practice sessions

### 👤 User Experience
- **Authentication**: Supabase-powered login and signup
- **Onboarding**: Comprehensive musical profile setup
  - Instrument selection
  - Skill level assessment
  - Genre preferences
  - Practice frequency
  - Musical goals
- **Dark Theme**: Beautiful dark mode interface
- **Bottom Navigation**: Easy access to Home, Library, and Settings

## Tech Stack

- **Framework**: Flutter
- **Authentication**: Supabase (commented out for MVP)
- **State Management**: Provider
- **UI**: Google Fonts, Material Design 3
- **Local Storage**: SharedPreferences

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── providers/
│   └── auth_provider.dart             # Authentication state management
├── screens/
│   ├── splash_screen.dart             # Loading screen
│   ├── auth/
│   │   ├── login_screen.dart          # User login
│   │   └── signup_screen.dart         # User registration
│   ├── onboarding/
│   │   └── onboarding_modal.dart      # Musical profile setup
│   ├── main/
│   │   ├── main_layout.dart           # Bottom navigation layout
│   │   ├── dashboard_screen.dart      # Feature cards dashboard
│   │   ├── library_screen.dart        # Sheet music & recordings
│   │   └── settings_screen.dart       # App settings
│   └── features/
│       ├── sheet_music_screen.dart    # AI recommendations
│       ├── tuning_screen.dart         # Instrument tuning
│       ├── intonation_screen.dart     # Pitch analysis
│       ├── metronome_screen.dart      # Digital metronome
│       └── recording_library_screen.dart # Practice recordings
└── assets/
    └── tonic.jpg                     # App logo
```

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- iOS Simulator or Android Emulator (or physical device)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tuttiai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **For iOS development** (optional)
   ```bash
   sudo gem install cocoapods
   cd ios && pod install
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## MVP Features

This is an MVP (Minimum Viable Product) version with the following characteristics:

- **Authentication**: Local storage simulation (Supabase integration commented out)
- **AI Recommendations**: Mock data with realistic examples
- **Audio Features**: Visual feedback only (no actual audio processing)
- **File Operations**: UI mockups (no actual file handling)

### To Enable Full Features

1. **Supabase Setup**:
   - Uncomment Supabase initialization in `main.dart`
   - Add your Supabase URL and anon key
   - Uncomment API calls in `auth_provider.dart`

2. **Audio Processing**:
   - Integrate audio recording libraries
   - Add microphone permissions
   - Implement actual frequency detection

3. **File Management**:
   - Enable actual file picker functionality
   - Add cloud storage integration
   - Implement PDF sheet music viewing

## App Flow

1. **Splash Screen**: Shows Tutti logo while loading
2. **Authentication**: Login or signup with email/password
3. **Onboarding** (new users): 6-step musical profile setup
4. **Dashboard**: Feature cards for all music tools
5. **Navigation**: Bottom bar with Home, Library, Settings

## Design System

- **Primary Color**: Indigo (`#6366F1`)
- **Background**: Dark theme (`#0F0F23`, `#1E1E3F`)
- **Typography**: Google Fonts Inter
- **Components**: Material Design 3 with custom theming

## Development Notes

- All API calls are currently mocked for MVP demonstration
- Visual animations and feedback are fully implemented
- Responsive design for various screen sizes
- Proper error handling and loading states
- Clean architecture with separation of concerns

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

---

**Tutti** - Making music practice smarter, one note at a time! 🎼✨
