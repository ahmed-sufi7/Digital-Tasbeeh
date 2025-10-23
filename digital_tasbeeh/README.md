# Digital Tasbeeh App

A modern digital tasbeeh app for counting dhikr and Islamic supplications, built with Flutter using iOS-style Cupertino design.

## Project Structure

```
lib/
├── constants/          # App-wide constants (colors, text styles)
├── models/            # Data models
├── screens/           # UI screens
├── widgets/           # Reusable UI components
├── services/          # Business logic services
├── providers/         # State management providers
├── utils/             # Utility functions
└── main.dart          # App entry point
```

## Features (Planned)

- **Digital Counter**: Tap-to-increment dhikr counting with haptic feedback
- **Progress Tracking**: Visual progress rings and round completion
- **Multiple Tasbeehs**: Manage different types of dhikr with custom counts
- **Statistics**: Charts and analytics for tracking spiritual progress
- **iOS-Style Design**: Beautiful Cupertino design with smooth animations
- **Accessibility**: Full screen reader support and high contrast modes
- **Firebase Integration**: Push notifications and analytics

## Dependencies

- `cupertino_icons`: iOS-style icons
- `provider`: State management
- `sqflite`: Local database storage
- `shared_preferences`: App settings persistence
- `firebase_core`: Firebase integration
- `firebase_messaging`: Push notifications
- `firebase_analytics`: Usage analytics
- `fl_chart`: Beautiful charts and graphs
- `flutter_local_notifications`: Local notifications

## Getting Started

1. Ensure Flutter is installed and configured
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Configure Firebase (replace placeholder google-services.json)
5. Run `flutter run` to start the app

## Firebase Setup

The project includes a placeholder `google-services.json` file. To enable Firebase features:

1. Create a new Firebase project at https://console.firebase.google.com
2. Add an Android app with package name `com.example.digital_tasbeeh`
3. Download the real `google-services.json` file
4. Replace the placeholder file in `android/app/google-services.json`

## Font Configuration

The app is configured to use SF Pro Display font family. The current setup includes placeholder font files. For production:

1. Obtain SF Pro Display font files from Apple
2. Replace placeholder files in the `fonts/` directory
3. The app will fallback to Roboto if SF Pro Display is not available

## Development Status

This is the initial project setup. The following tasks are planned:

- [ ] Core data models and database layer
- [ ] Counter business logic and state management
- [ ] Main counter UI component
- [ ] Action bar with controls
- [ ] Home screen layout
- [ ] Tasbeeh management interface
- [ ] Statistics and charts
- [ ] Audio and haptic feedback
- [ ] Theme system and accessibility
- [ ] Firebase services integration
- [ ] Settings and preferences
- [ ] App initialization and lifecycle
- [ ] Animations and visual polish
- [ ] Comprehensive testing

## License

This project is for educational and personal use.