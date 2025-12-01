import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://callback',
      );
    } catch (e) {
      print('Error during Google sign in: $e');
      // Add more detailed error handling
      if (e is AuthException) {
        print('Auth error: ${e.message}');
      }
    }
  }
}