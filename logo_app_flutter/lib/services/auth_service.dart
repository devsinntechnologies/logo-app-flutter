import 'package:supabase_flutter/supabase_flutter.dart';

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
      print("Google Sign-In Error: $e");
    }
  }

  // ---------------- EMAIL SIGN UP ----------------
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    print("SIGNING UP USER WITH EMAIL: $email");
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    print("SIGNED UP USER: ${response.user}");

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
