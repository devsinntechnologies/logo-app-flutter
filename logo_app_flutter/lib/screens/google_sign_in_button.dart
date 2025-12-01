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
          child: Row(
            children: [
              
              ShaderMask(
              shaderCallback: (bounds) =>
              ThemeColors.textGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: Text(
              "Login in",style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold
                ),
              ),
               ),
              SizedBox(width: 5),
              Icon(Icons.arrow_forward, color: ThemeColors.purple),

            ],
          ),
        );
    // IconButton(
    //   // icon: Icon(Icons.login_outlined),
    //   // icon: Image.asset('assets/icons/google.png', height: 40),

    //   onPressed: _signInWithGoogle,

    // );
  }
}
