# Smart Logo Maker - AI Coding Assistant Instructions

## Project Overview
A Flutter-based logo design application enabling users to create, customize, and save professional logos. The app features a canvas-based editor with drag-and-drop elements, real-time customization, and Supabase backend integration.

## Architecture & Key Patterns

### State Management
- **Provider pattern**: Primary state management via `provider` package
- **SelectedColorProvider** (`lib/provider/selected_color_provider.dart`): Central state for colors, gradients, backgrounds, and element styling
  - Manages per-element color overrides with `_overrideColors` map
  - Tracks manual color changes via `_isElementColorOverridden`
  - Handles checkerboard visibility and background images
- Use `notifyListeners()` after state mutations to trigger UI updates

### Core Data Models
- **LogoStateData** (`lib/models/logo_state_data.dart`): Comprehensive logo state including:
  - `CustomTextElement`: Text with position, rotation, opacity, outline, and styling
  - `BackgroundState`: Color, gradient, image path, and checkerboard settings
  - Elements support layering via `layerIndex` and visibility toggling
- Always use `.copyWith()` for immutable updates to state objects

### Canvas & Rendering
- **LogoCanvas** (`lib/components/logo_canvas.dart`): Primary editing surface (837 lines)
  - Handles element selection, dragging, rotation, and resizing via callback pattern
  - Grid overlay with highlighting for alignment
  - Export functionality via `isExportingNotifier` with high-res rendering (pixelRatio: 3)
- **EditableElementWrapper**: Wraps canvas elements with interaction handlers
- **GridPainter**: Custom painter for alignment grid visualization

### Backend Integration
- **Supabase** initialization in `main.dart` with hardcoded credentials (prod URL visible)
- **AuthService** (`lib/services/auth_service.dart`): Google OAuth and email auth
  - OAuth redirect: `io.supabase.flutter://callback`
  - Always call `signOut()` before `signInWithPassword()` for clean sessions
- **LogoService** (`lib/services/logo_service.dart`): External API integration
  - Fetches SVG logos from `logoai.com/api/getAllInfo` with complex industry/design parameters
  - Parses SVG source code from `icon_normal.source_code` field
- **CanvasUploadService** (`lib/screens/canvas_upload_service.dart`): Captures canvas as PNG
  - Uses `RenderRepaintBoundary.toImage()` for high-quality exports
  - Uploads to Supabase storage bucket `logos/`

## Project Structure

```
lib/
├── main.dart              # Entry point, Supabase init, auth stream
├── components/            # Reusable UI components
│   ├── logo_canvas.dart   # Main canvas widget
│   ├── editable_element_wrapper.dart
│   ├── GridButtons/       # Home screen navigation buttons
│   └── logoBottomNavbarItems/  # Canvas bottom toolbar widgets
├── screens/               # Full-page screens
│   ├── home_screen.dart   # Main landing with grid navigation
│   ├── canvas_upload_service.dart  # Rendering & upload logic
│   ├── color_screen.dart  # Color picker & customization
│   └── my_design_screen.dart  # Saved designs gallery
├── services/              # Business logic & external APIs
├── provider/              # Global state management
├── models/                # Data structures
└── fragments/             # Partial UI widgets (fonts, templates)
```

## Development Workflows

### Running the App
```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build for Android
flutter build apk --release

# Generate launcher icons
flutter pub run flutter_launcher_icons
```

### Common Tasks
- **Adding new canvas elements**: Extend `LogoStateData` with element type, update `LogoCanvas` rendering logic, add to `elementOrder` list
- **Modifying colors**: Work through `SelectedColorProvider`, use `setOverrideColorForElement()` for element-specific colors
- **External API changes**: Update `LogoService.fetchLogoSVGs()` request payload or parsing logic
- **Auth flows**: Modify `AuthService` and listen to `_supabase.auth.onAuthStateChange` in `main.dart`

### Asset Management
Assets organized by type in `assets/` directories (see `pubspec.yaml` lines 93-99):
- `texture_images/`, `logo_images/`, `icons/`, `svgs/`, `bg_images/`, `effects_images/`, `videos/`
- Always add new asset directories to `pubspec.yaml` before referencing

## Critical Conventions

### UI Patterns
- **Theme**: Google Fonts (Poppins) applied globally via `GoogleFonts.poppinsTextTheme()`
- **Custom gradient**: `ThemeColors.customGradient` for consistent branding (see drawer header in `home_screen.dart`)
- **Responsive sizing**: Check `MediaQuery.of(context).size.height > 500` for layout adaptations
- **Navigation**: Grid-based home screen with custom styled buttons (`GridButtons/` components)

### Code Style
- Use `const` constructors for immutable widgets
- Callback pattern for parent-child communication (e.g., `onElementTap`, `onElementPanUpdate`)
- Descriptive variable names with underscores for private members (`_selectedColor`, `_supabase`)
- Comments for major sections (see `// ---------------- GOOGLE SIGN IN ----------------` in `AuthService`)

### Testing & Debugging
- Prints used for debugging (e.g., `print("SIGNING UP USER WITH EMAIL: $email")`)
- Widget tests in `test/widget_test.dart` (default Flutter template)
- Use `debugShowCheckedModeBanner: false` in MaterialApp

## Common Pitfalls
- **Supabase auth**: Always check `_supabase.auth.currentSession` before authenticated operations
- **Canvas exports**: Ensure `endOfFrame` awaited before calling `toImage()` to capture complete render
- **Provider updates**: Forgetting `notifyListeners()` causes stale UI
- **SVG parsing**: logoai.com API responses may have null `icon_normal.source_code`, always null-check
- **Color overrides**: Distinguish between default colors and user-set overrides using `_isElementColorOverridden` map

## Key Files to Reference
- [lib/main.dart](lib/main.dart) - App initialization, auth streams, providers
- [lib/components/logo_canvas.dart](lib/components/logo_canvas.dart) - Canvas rendering & interaction logic
- [lib/models/logo_state_data.dart](lib/models/logo_state_data.dart) - Core data structures
- [lib/provider/selected_color_provider.dart](lib/provider/selected_color_provider.dart) - Global color/style state
- [pubspec.yaml](pubspec.yaml) - Dependencies & asset declarations
