/// Environment configuration for the app
/// This file should be kept in version control with placeholder values
/// Actual production values should be set via environment variables or secure storage
class Environment {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sobkonycxgkklpmxpphn.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvYmtvbnljeGdra2xwbXhwcGhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NjY2NDAsImV4cCI6MjA3OTU0MjY0MH0.oGf4XMlK73KrVVE1EULXMoZlwN4kf5gWUdz5sKZaGcw',
  );

  // AdMob Configuration
  // Test device IDs - only used in debug/development mode
  static const List<String> testDeviceIds = String.fromEnvironment('TEST_DEVICE_IDS') != ''
      ? [String.fromEnvironment('TEST_DEVICE_IDS')]
      : [];

  // App Configuration
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  static const bool enableDebugLogs = bool.fromEnvironment(
    'DEBUG_LOGS',
    defaultValue: !isProduction,
  );

  // Validate configuration
  static void validate() {
    assert(supabaseUrl.isNotEmpty, 'Supabase URL is required');
    assert(supabaseAnonKey.isNotEmpty, 'Supabase Anon Key is required');

    if (isProduction) {
      // In production, ensure we're not using test devices
      assert(
        testDeviceIds.isEmpty,
        'Test device IDs should not be configured in production',
      );
    }
  }

  // Print configuration (safe for production - doesn't expose secrets)
  static void printConfig() {
    if (enableDebugLogs) {
      print('🔧 Environment Configuration:');
      print('   - Mode: ${isProduction ? "PRODUCTION" : "DEVELOPMENT"}');
      print('   - Supabase URL: ${supabaseUrl.substring(0, 30)}...');
      print('   - Debug Logs: $enableDebugLogs');
      print('   - Test Devices: ${testDeviceIds.length}');
    }
  }
}
