import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logo_app_flutter/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<AuthResponse?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      _setLoading(false);
      return response;
    } on AuthException catch (e) {
      _setError(_mapAuthException(e));
      _setLoading(false);
      return null;
    } catch (e) {
      _setError("An unexpected error occurred. Please try again.");
      _setLoading(false);
      return null;
    }
  }

  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _authService.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      _setLoading(false);
      return response;
    } on AuthException catch (e) {
      _setError(_mapAuthException(e));
      _setLoading(false);
      return null;
    } catch (e) {
      _setError("An unexpected error occurred. Please try again.");
      _setLoading(false);
      return null;
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.signInWithGoogle();
      _setLoading(false);
    } catch (e) {
      _setError("Google Sign-In failed. Please try again.");
      _setLoading(false);
    }
  }

  String _mapAuthException(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return "Incorrect email or password. Please try again.";
    } else if (message.contains('email not confirmed')) {
      return "Please confirm your email address before logging in.";
    } else if (message.contains('already registered') || message.contains('user already exists')) {
      return "This email is already in use. Please log in instead.";
    } else if (message.contains('password should be') || message.contains('weak password')) {
      return "Password is too weak. Please choose a stronger one.";
    } else if (message.contains('network') || message.contains('connect')) {
      return "Network error. Please check your internet connection.";
    }
    return e.message;
  }
}
