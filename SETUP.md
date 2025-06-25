# Detailed Setup Guide for Propal

This guide provides step-by-step instructions for setting up the Propal AI Coding Assistant on your development environment.

## 📋 Prerequisites

### 1. Flutter Development Environment

- **Flutter SDK**: Version 3.3.0 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio** or **VS Code** with Flutter extensions
- **Git**: For version control

### 2. Platform-Specific Requirements

#### For Android Development:
- Android SDK (API level 21 or higher)
- Android Studio
- Android Emulator or physical device
- Java Development Kit (JDK) 8 or higher

#### For iOS Development (macOS only):
- Xcode 14.0 or higher
- iOS Simulator or physical device
- CocoaPods

### 3. API Access
- Google AI Studio account
- Active internet connection for API calls

## 🚀 Installation Steps

### Step 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/Atharva-Werulkar/propal.git

# Navigate to project directory
cd propal

# Verify Flutter installation
flutter doctor
```

### Step 2: Install Dependencies

```bash
# Get all Flutter dependencies
flutter pub get

# For iOS (macOS only)
cd ios && pod install && cd ..
```

### Step 3: Environment Configuration

#### Create Environment File
```bash
# Copy the example environment file
cp assets/creds/.env.example assets/creds/.env
```

#### Get Google AI API Key
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key
5. Edit `assets/creds/.env` and replace `your_google_ai_api_key_here` with your actual API key

```env
# assets/creds/.env
API_KEY=AIzaSyYourActualAPIKeyHere
```

### Step 4: Platform-Specific Configuration

#### Android Configuration

1. **Update Minimum SDK Version** (if needed)
   ```xml
   <!-- android/app/build.gradle -->
   android {
       compileSdkVersion 34
       defaultConfig {
           minSdkVersion 21
           targetSdkVersion 34
       }
   }
   ```

2. **Add Biometric Permissions**
   ```xml
   <!-- android/app/src/main/AndroidManifest.xml -->
   <uses-permission android:name="android.permission.USE_FINGERPRINT" />
   <uses-permission android:name="android.permission.USE_BIOMETRIC" />
   ```

#### iOS Configuration

1. **Update Deployment Target** (if needed)
   ```ruby
   # ios/Podfile
   platform :ios, '11.0'
   ```

2. **Add Biometric Permissions**
   ```xml
   <!-- ios/Runner/Info.plist -->
   <key>NSFaceIDUsageDescription</key>
   <string>This app uses Face ID for secure authentication</string>
   ```

### Step 5: Run the Application

```bash
# Check for any issues
flutter doctor

# Run on connected device/emulator
flutter run

# Or run in debug mode
flutter run --debug

# For release mode
flutter run --release
```

## 🛠️ Development Setup

### VS Code Extensions
- Flutter
- Dart
- Flutter Widget Snippets
- Bracket Pair Colorizer

### Android Studio Plugins
- Flutter
- Dart

### Recommended Settings

#### VS Code Settings (`.vscode/settings.json`)
```json
{
  "dart.flutterHotReloadOnSave": "always",
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

#### Launch Configuration (`.vscode/launch.json`)
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart"
    }
  ]
}
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. "flutter doctor" Shows Issues
```bash
# Update Flutter
flutter upgrade

# Clean and rebuild
flutter clean
flutter pub get
```

#### 2. API Key Not Working
- Verify the API key is correct
- Check if the API key has proper permissions
- Ensure the .env file is in the correct location: `assets/creds/.env`

#### 3. Biometric Authentication Not Working
- Ensure device has biometric capability
- Check app permissions
- Test on a physical device (biometrics may not work on emulators)

#### 4. Build Errors
```bash
# Clean build
flutter clean

# Remove pub cache
flutter pub cache repair

# Get dependencies again
flutter pub get

# Rebuild
flutter run
```

#### 5. iOS Build Issues
```bash
# Navigate to iOS directory
cd ios

# Clean CocoaPods
pod deintegrate
pod install

# Return to project root
cd ..

# Run Flutter
flutter run
```

## 📱 Testing

### Unit Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Integration Testing
```bash
# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 🚀 Building for Release

### Android APK
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS IPA
```bash
# Build for iOS
flutter build ios --release

# Or build IPA
flutter build ipa --release
```

## 📊 Performance Optimization

### Analysis
```bash
# Analyze app size
flutter build apk --analyze-size

# Profile performance
flutter run --profile
```

### Optimization Tips
- Use `const` constructors where possible
- Implement proper list view recycling
- Optimize image loading with `cached_network_image`
- Use `flutter_lints` for code quality

## 🔐 Security Considerations

### Environment Variables
- Never commit `.env` files to version control
- Use different API keys for development and production
- Rotate API keys regularly

### Data Security
- All user data is encrypted using `encrypt_shared_preferences`
- Biometric data is handled by the OS, not stored in the app
- Chat history is stored locally and encrypted

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Google AI Studio](https://makersuite.google.com/)
- [Flutter Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

## 🆘 Getting Help

If you encounter issues:
1. Check this setup guide
2. Review the main README.md
3. Search existing GitHub issues
4. Create a new issue with detailed information

---

Happy coding with Propal! 🚀
