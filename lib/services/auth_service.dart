import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logo_app_flutter/utils/app_logger.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // ---------------- GOOGLE SIGN IN ----------------
  Future<void> signInWithGoogle() async {
    try {
      // 1. Configure Native Google Sign-In
      // Note: On Android, this usually works without IDs if correctly configured in Gradle/Google Cloud.
      // On iOS, you MUST add the Reversed Client ID to Info.plist.
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // 2. Trigger the native sign-in dialog
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      // 3. Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw 'No ID Token found from Google.';
      }

      // 4. Authenticate with Supabase
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      AppLogger.success("Google Sign-In successful", tag: "AuthService");
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
