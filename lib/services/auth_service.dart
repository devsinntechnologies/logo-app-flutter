import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logo_app_flutter/config/environment.dart';
import 'package:logo_app_flutter/utils/app_logger.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // ---------------- GOOGLE SIGN IN ----------------
  Future<void> signInWithGoogle() async {
    try {
      // AppLogger.info("Starting Google Sign-In (Browser flow)", tag: "AuthService");

      // We use the browser-based flow as primary to ensure success across all devices
      // and avoid "Error 10" alerts caused by native configuration issues.
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://callback',
      );

      /* 
      // NATIVE FALLBACK (Currently disabled to avoid double-alerts)
      final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: Environment.googleWebClientId);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken,
        );
      }
      */

      AppLogger.success("Google Sign-In initiated", tag: "AuthService");
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

  // ---------------- RESEND VERIFICATION ----------------
  Future<void> resendVerification(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      AppLogger.error("Failed to resend verification",
          tag: "AuthService", error: e);
      rethrow;
    }
  }
}
