# Environment Configuration Guide

This app supports environment-based configuration for production and development builds.

## Environment Variables

### Supabase Configuration
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key

### App Configuration
- `PRODUCTION`: Set to `true` for production builds (default: `false`)
- `DEBUG_LOGS`: Enable debug logging (default: opposite of PRODUCTION)
- `TEST_DEVICE_IDS`: Comma-separated test device IDs for AdMob (development only)

## Building for Different Environments

### Development Build
```bash
flutter run
```

### Production Build (Android)
```bash
flutter build apk --release \
  --dart-define=PRODUCTION=true \
  --dart-define=DEBUG_LOGS=false \
  --dart-define=SUPABASE_URL=your_production_url \
  --dart-define=SUPABASE_ANON_KEY=your_production_key
```

### Production Build (iOS)
```bash
flutter build ios --release \
  --dart-define=PRODUCTION=true \
  --dart-define=DEBUG_LOGS=false \
  --dart-define=SUPABASE_URL=your_production_url \
  --dart-define=SUPABASE_ANON_KEY=your_production_key
```

### Production Build (AAB for Play Store)
```bash
flutter build appbundle --release \
  --dart-define=PRODUCTION=true \
  --dart-define=DEBUG_LOGS=false \
  --dart-define=SUPABASE_URL=your_production_url \
  --dart-define=SUPABASE_ANON_KEY=your_production_key
```

## Using Environment Files (Recommended)

Create environment-specific files:

### `.env.development`
```
PRODUCTION=false
DEBUG_LOGS=true
TEST_DEVICE_IDS=DC255CC5EA7AC8D46B45CD0260ECECCC
SUPABASE_URL=https://sobkonycxgkklpmxpphn.supabase.co
SUPABASE_ANON_KEY=your_dev_key
```

### `.env.production`
```
PRODUCTION=true
DEBUG_LOGS=false
SUPABASE_URL=https://your-production-project.supabase.co
SUPABASE_ANON_KEY=your_production_key
```

**⚠️ IMPORTANT**: Add `.env.production` to `.gitignore` to protect production credentials!

## Security Best Practices

1. **Never commit production credentials** to version control
2. Use CI/CD environment variables for production builds
3. Rotate keys regularly
4. Use different Supabase projects for dev/staging/production
5. Enable Row Level Security (RLS) in Supabase for all tables

## Signing Configuration

### Android
You need to create a keystore for production releases:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

Add to `android/.gitignore`:
```
key.properties
*.jks
*.keystore
```

### iOS
Configure signing in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Select your Team and enable "Automatically manage signing"

## App Store Preparation

### Android (Google Play)
1. Update version in `pubspec.yaml`: `version: 1.0.0+1`
2. Build release AAB: `flutter build appbundle --release`
3. Upload to Google Play Console
4. Complete store listing with screenshots, descriptions, etc.

### iOS (App Store)
1. Update version in `pubspec.yaml`
2. Build archive: `flutter build ios --release`
3. Open Xcode and archive for distribution
4. Upload to App Store Connect
5. Submit for review

## Troubleshooting

### Build Fails with Environment Variables
- Ensure all required variables are set
- Check for typos in variable names
- Verify credentials are valid

### AdMob Not Working
- Ensure you've replaced test ad unit IDs with production IDs
- Verify AdMob app is registered in Firebase console
- Wait 24 hours after creating new ad units

### Supabase Connection Issues
- Verify URL and anon key are correct
- Check Supabase project is not paused
- Ensure RLS policies allow the operations you're attempting
