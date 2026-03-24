# Smart Logo Maker - Flutter App

A Flutter-based logo design application enabling users to create, customize, and save professional logos with a canvas-based editor, drag-and-drop elements, and Supabase backend integration.

## Features

- 🎨 Canvas-based logo editor with drag-and-drop elements
- 🎨 Real-time customization (colors, gradients, fonts, effects)
- 💾 Save and manage designs in the cloud
- 🔐 Google OAuth and email authentication
- 📱 Cross-platform (Android & iOS)
- 🎨 SVG logo templates from external API
- 🖼️ Background images and textures
- 📱 Responsive design for various screen sizes

## Getting Started

### Prerequisites
- Flutter SDK (>=3.5.4)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for platform-specific builds)
- Supabase account for backend services

### Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd logo-app-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment**
   ```bash
   # Copy development environment template
   cp .env.development .env.local
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Production Setup

For production deployment, follow these guides:

- **[PRODUCTION_SETUP.md](PRODUCTION_SETUP.md)** - Complete guide for environment setup and deployment
- **[RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)** - Step-by-step checklist for app store releases
- **build-production.sh** - Automated build script for production releases

### Quick Start for Production

1. **Configure environment**:
   ```bash
   cp .env.production.template .env.production
   # Edit .env.production with your production credentials
   ```

2. **Set up Android signing** (if building for Android):
   ```bash
   # Generate keystore
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   
   # Copy template and configure
   cp android/key.properties.template android/key.properties
   # Edit android/key.properties with your values
   ```

3. **Build for production**:
   ```bash
   ./build-production.sh
   ```

## Security Notes

- Never commit `.env.production` or `android/key.properties`
- These files contain sensitive credentials
- Use CI/CD environment variables for automated builds
- Rotate keys regularly

## Project Structure

```
lib/
├── config/              # Configuration files
│   └── environment.dart # Environment configuration
├── components/          # Reusable UI components
├── screens/            # Full-page screens
├── services/           # Business logic & APIs
├── provider/           # State management
├── models/             # Data structures
└── utils/              # Utility functions
    └── app_logger.dart # Production-safe logging
```

## Documentation

- [Production Setup Guide](PRODUCTION_SETUP.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
- [GitHub Copilot Instructions](.github/copilot-instructions.md)

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Google Fonts](https://fonts.google.com/)
