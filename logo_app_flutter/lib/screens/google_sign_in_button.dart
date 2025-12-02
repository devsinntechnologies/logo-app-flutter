import 'package:flutter/material.dart';
import 'package:logo_app_flutter/services/auth_service.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final AuthService authService = AuthService();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in successfully!')),
        );
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : GestureDetector(
          onTap: _signInWithGoogle,
          child: Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Container(
              decoration: BoxDecoration(
              gradient: ThemeColors.textGradient,
              borderRadius: BorderRadius.circular(8),
              ),
              child: 
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  "Login",style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                    ),
                  ),
              ),
            ),
          )
        );
    // IconButton(
    //   // icon: Icon(Icons.login_outlined),
    //   // icon: Image.asset('assets/icons/google.png', height: 40),

    //   onPressed: _signInWithGoogle,

    // );
  }
}
