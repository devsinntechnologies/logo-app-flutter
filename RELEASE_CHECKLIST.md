# Production Release Checklist

## Pre-Release Preparation

### 1. Environment Configuration
- [ ] Copy `.env.production.template` to `.env.production`
- [ ] Update production Supabase URL and anon key in `.env.production`
- [ ] Verify `.env.production` is in `.gitignore`
- [ ] Test environment configuration locally

### 2. Code Quality
- [ ] Remove all TODO comments from code
- [ ] Run `flutter analyze` and fix all issues
- [ ] Run `flutter test` and ensure all tests pass
- [ ] Review and update error handling
- [ ] Verify all sensitive data is removed (API keys, passwords, etc.)

### 3. Android Configuration
- [ ] Update `applicationId` in `android/app/build.gradle.kts`
  - ✅ Updated to: `com.devsinntechnologies.smartlogomaker`
- [ ] Create production keystore (see `android/key.properties.template`)
- [ ] Create `android/key.properties` with signing credentials
- [ ] Update app name in `android/app/src/main/AndroidManifest.xml`
- [ ] Add proper app permissions in AndroidManifest.xml
- [ ] Update app icon (use `flutter_launcher_icons`)

### 4. iOS Configuration
- [ ] Update Bundle Identifier in Xcode
  - ✅ Updated to: `com.devsinntechnologies.smartlogomaker`
- [ ] Configure signing in Xcode (Signing & Capabilities)
- [ ] Update Display Name in `ios/Runner/Info.plist`
- [ ] Add proper app permissions in Info.plist (camera, photo library, etc.)
- [ ] Update app icon (use `flutter_launcher_icons`)

### 5. App Metadata
- [ ] Update app version in `pubspec.yaml`
  - Version format: `major.minor.patch+buildNumber`
  - Example: `1.0.0+1` for first release
- [ ] Update app name/description in `pubspec.yaml`
- [ ] Review and update README.md

### 6. Third-Party Services
- [ ] Configure production AdMob app and ad units
  - Replace test ad unit IDs with production IDs
  - Update in respective screen files
- [ ] Set up production Supabase project
  - Enable Row Level Security (RLS) on all tables
  - Configure proper auth providers
  - Set up storage buckets with proper policies
- [ ] Configure Google Sign-In for production
  - Add SHA-1 fingerprint to Firebase console
  - Update OAuth consent screen

### 7. Testing
- [ ] Test on physical Android device in release mode
  - `flutter run --release`
- [ ] Test on physical iOS device in release mode
- [ ] Test all user flows (signup, login, save design, etc.)
- [ ] Test with production Supabase project
- [ ] Verify no debug logs appear in production build
- [ ] Test offline functionality
- [ ] Test on different screen sizes

### 8. Performance & Optimization
- [ ] Run `flutter build apk --analyze-size` to check app size
- [ ] Optimize image assets (compress if needed)
- [ ] Review and remove unused dependencies
- [ ] Enable code obfuscation if needed
  - `flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols`

## Build Commands

### Development Build
```bash
flutter run
```

### Production Android APK
```bash
flutter build apk --release \
  --dart-define=PRODUCTION=true \
  --dart-define=DEBUG_LOGS=false \
  --dart-define=SUPABASE_URL=your_production_url \
  --dart-define=SUPABASE_ANON_KEY=your_production_key
```

### Production Android App Bundle (for Play Store)
```bash
flutter build appbundle --release \
  --dart-define=PRODUCTION=true \
  --dart-define=DEBUG_LOGS=false \
  --dart-define=SUPABASE_URL=your_production_url \
  --dart-define=SUPABASE_ANON_KEY=your_production_key
```

### Production iOS Build
```bash
flutter build ios --release \
  --dart-define=PRODUCTION=true \
  --dart-define=DEBUG_LOGS=false \
  --dart-define=SUPABASE_URL=your_production_url \
  --dart-define=SUPABASE_ANON_KEY=your_production_key
```

## Post-Build Steps

### Android (Google Play)
- [ ] Test the signed APK/AAB on a physical device
- [ ] Prepare store listing assets
  - Screenshots (phone, tablet, TV if applicable)
  - Feature graphic (1024x500)
  - App icon (512x512)
  - Promotional video (optional)
- [ ] Write app description and metadata
- [ ] Set content rating questionnaire
- [ ] Upload to Play Console
- [ ] Submit for review

### iOS (App Store)
- [ ] Archive in Xcode (Product → Archive)
- [ ] Upload to App Store Connect
- [ ] Prepare store listing assets
  - Screenshots for all required device sizes
  - App icon
  - App preview video (optional)
- [ ] Write app description and metadata
- [ ] Set age rating
- [ ] Submit for review

## Security Checklist
- [ ] No hardcoded credentials in source code
- [ ] All API keys secured via environment variables
- [ ] Supabase RLS policies configured
- [ ] HTTPS only for all network requests
- [ ] Input validation on all user inputs
- [ ] Proper error handling without exposing sensitive info

## Compliance Checklist
- [ ] Privacy Policy URL configured
- [ ] Terms of Service URL configured
- [ ] GDPR compliance (if applicable)
- [ ] COPPA compliance (if targeting children)
- [ ] Data deletion mechanism implemented

## Rollback Plan
- [ ] Keep previous version APK/IPA backed up
- [ ] Document database schema changes
- [ ] Have rollback procedure documented
- [ ] Monitor crash reports after release

## Post-Release
- [ ] Monitor crash reports (Firebase Crashlytics recommended)
- [ ] Monitor user reviews
- [ ] Track key metrics (DAU, retention, etc.)
- [ ] Plan for maintenance updates
- [ ] Schedule security audits

---

## Quick Reference: File Locations

- **Android App ID**: `android/app/build.gradle.kts` (line ~29)
- **iOS Bundle ID**: `ios/Runner.xcodeproj/project.pbxproj`
- **App Version**: `pubspec.yaml` (line ~19)
- **Environment Config**: `lib/config/environment.dart`
- **Signing Config**: `android/key.properties` (create from template)
- **AdMob IDs**: Search for "ca-app-pub" in project files

## Support Resources

- Flutter Docs: https://docs.flutter.dev/deployment
- Google Play Console: https://play.google.com/console
- App Store Connect: https://appstoreconnect.apple.com
- Supabase Docs: https://supabase.com/docs
