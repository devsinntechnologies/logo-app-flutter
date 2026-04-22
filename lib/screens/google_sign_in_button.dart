import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/google_alert.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/provider/auth_provider.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logo_app_flutter/screens/my_account_screen.dart';
import 'package:provider/provider.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    // Check initial auth state
    _isLoggedIn = _supabase.auth.currentSession != null;
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;

      if (mounted) {
        setState(() {
          _isLoggedIn = session != null;
        });
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            title: GestureDetector(
              onTap: () {
                _signInWithGoogle();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.2),
                      offset: const Offset(4, 4),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Theme.of(context).canvasColor.withOpacity(0.2),
                      offset: const Offset(-4, -4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/icons/google.png",
                      height: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Sign In with Google",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )

            // actions: [
            //   TextButton(
            //     onPressed: () => Navigator.pop(context),
            //     child: const Text(
            //       "Cancel",
            //       style: TextStyle(fontSize: 14, color: ThemeColors.purple),
            //     ),
            //   ),
            //   TextButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //       _signInWithGoogle();
            //     },
            //     child: const Text(
            //       "Add",
            //       style: TextStyle(fontSize: 14, color: ThemeColors.purple),
            //     ),
            //   ),
            // ],

            );
      },
    );
  }

  @override
  Widget build(BuildContext context) { 
    if (_isLoading) return const CircularProgressIndicator();

    // When logged out: show Login button. When logged in: show account icon.
    if (_isLoggedIn) {
      final user = _supabase.auth.currentUser;
      final avatarUrl =
          user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
      final avatarLabel = (user?.email != null && user!.email!.isNotEmpty)
          ? user.email![0].toUpperCase()
          : '';
      return IconButton(
        tooltip: 'My Account',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyAccountScreen()),
          );
        },
        icon: CircleAvatar(
          radius: 16,
          backgroundColor: ThemeColors.purple,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(avatarLabel, style: const TextStyle(color: Colors.white))
              : null,
        ),
      );
    }

    return GestureDetector(
      onTap: () => showCustomGoogleDialog(context),
      child: Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: ThemeColors.textGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: EdgeInsets.all(6.0),
            child: Text(
              S.of(context).login,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
