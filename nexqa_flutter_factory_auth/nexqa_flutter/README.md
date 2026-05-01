# NexQA — Flutter

AI-powered quality assurance app built with Flutter.

## Features
- Camera capture for product inspection
- AI defect detection (simulated with confidence scoring)
- Pass / Reject workflow
- Dashboard with defect bar chart and pass rate
- History for passed and rejected products
- Dark / Light / System theme switching (persisted)
- Glassmorphism UI with BackdropFilter blur

## Setup

### Prerequisites
- Flutter SDK 3.x ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio or Xcode

### Steps

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build release APK (Android)
flutter build apk --release

# Build release IPA (iOS — requires Xcode on macOS)
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_colors.dart       # Dark / Light color palettes
├── models/
│   └── product.dart          # Product data model
├── providers/
│   ├── app_provider.dart     # Inspection history state
│   └── theme_provider.dart   # Theme preference state
├── widgets/
│   └── glass_card.dart       # Reusable glassmorphism card
└── screens/
    ├── home_screen.dart
    ├── camera_screen.dart
    ├── analysis_screen.dart
    ├── result_screen.dart
    ├── dashboard_screen.dart
    ├── history_screen.dart
    └── settings_screen.dart
```

## Dependencies
| Package | Purpose |
|---|---|
| `provider` | State management |
| `shared_preferences` | Persistent storage |
| `image_picker` | Camera / gallery access |
| `google_fonts` | Inter font family |
| `uuid` | Unique product IDs |
