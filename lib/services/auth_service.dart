import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logo_app_flutter/utils/app_logger.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // ---------------- GOOGLE SIGN IN ----------------
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://callback',
      );
    } catch (e) {
      AppLogger.error("Google Sign-In failed", tag: "AuthService", error: e);
      rethrow;
    }
  }

  // ---------------- EMAIL SIGN UP ----------------
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    AppLogger.auth("Signing up user with email: $email");
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
      },
    );
    AppLogger.success("User signed up: ${response.user?.id}",
        tag: "AuthService");

    return response;
  }

  // ---------------- EMAIL LOGIN ----------------
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signOut();
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
}
