# Quick Start Guide - Visuales UCLV

## Prerequisites

1. **Flutter SDK** (>= 3.0.0)
   - Install from: https://docs.flutter.dev/get-started/install
   - Verify: `flutter --version`

2. **Android Studio** (for Android development)
   - Install from: https://developer.android.com/studio
   - Install Android SDK and tools

3. **VS Code** (recommended IDE)
   - Install Flutter and Dart extensions

## Setup

### 1. Clone and Install Dependencies

```bash
cd /workspaces/Visuales-
flutter pub get
```

### 2. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode (slower start, better performance)
flutter run --release
```

### 3. Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models_test.dart

# Run with coverage
flutter test --coverage
```

## Building for Production

### Android APK

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release

# Split APKs by ABI (smaller file sizes)
flutter build apk --split-per-abi

# Output location:
# build/app/outputs/flutter-apk/
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires macOS)

```bash
# Build for iOS
flutter build ios

# Output location:
# build/ios/iphoneos/
```

## Configuration

### Server URL

Edit `lib/config/constants.dart`:

```dart
static const String baseUrl = 'https://visuales.uclv.cu';
```

### App Version

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1  # version+build_number
```

### App Name

Edit `pubspec.yaml`:

```yaml
name: visuales_uclv
description: Buscador y gestor de descargas para Visuales UCLV
```

## Android Permissions

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Internet -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <!-- Storage (for downloads) -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    
    <!-- For Android 13+ -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
</manifest>
```

## Common Commands

```bash
# Check Flutter installation
flutter doctor

# Check for issues
flutter analyze

# Format code
dart format .

# Clean build
flutter clean
flutter pub get

# Run on specific device
flutter devices
flutter run -d <device_id>

# Build with verbose output
flutter build apk -v
```

## Troubleshooting

### Build Fails

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

### Dependency Issues

```bash
# Upgrade dependencies
flutter pub upgrade

# Get specific package
flutter pub add <package_name>
```

### Emulator Issues

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>
```

## Development Tips

### Hot Reload

While app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debug Mode

```dart
// Add debug prints
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Debug info: $value');
}
```

### Profile Performance

```bash
# Run in profile mode for performance testing
flutter run --profile
```

## Next Steps

1. ✅ Run `flutter pub get`
2. ✅ Run `flutter test` to verify setup
3. ✅ Run `flutter run` to test on device/emulator
4. ✅ Configure server URL in constants.dart
5. ✅ Build release APK for distribution

## Support

- Flutter Docs: https://docs.flutter.dev
- Dart Docs: https://dart.dev/guides
- Flutter Community: https://flutter.dev/community

---

**Happy Coding! 🚀**
