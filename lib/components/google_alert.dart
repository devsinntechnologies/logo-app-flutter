import 'package:flutter/material.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/screens/log_in_screen.dart';
import 'package:logo_app_flutter/screens/sign_up_screen.dart';
import 'package:logo_app_flutter/provider/auth_provider.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:provider/provider.dart';

void showCustomGoogleDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[100],
        title: Column(
  children: [
    const SizedBox(height: 10),

    /// 🔵 LOGIN BUTTON
    _authButton(
      context,
      text: S.of(context).login,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
    ),

    const SizedBox(height: 16),

    /// 🟢 SIGNUP BUTTON
    _authButton(
      context,
      text: S.of(context).signup,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      },
    ),

    const SizedBox(height: 20),

    /// DIVIDER
    Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            S.of(context).or,
            style: TextStyle(
              fontSize: _responsiveFont(context, 14),
              color: Colors.grey[600],
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    ),

    const SizedBox(height: 20),

    /// GOOGLE BUTTON
    _googleButton(context),
  ],
)
      );
    },
  );
}
Widget _authButton(
  BuildContext context, {
  required String text,
  required VoidCallback onTap,
}) {
  final isSmall = MediaQuery.of(context).size.width < 360;

  return InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSmall ? 10 : 14,
      ),
      decoration: BoxDecoration(
        gradient: ThemeColors.yellowOrangePink,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: _responsiveFont(context, 16),
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
Widget _googleButton(BuildContext context) {
  final isSmall = MediaQuery.of(context).size.width < 360;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: isSmall ? 10 : 12,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.grey),
    ),
    child: GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        try {
          await context.read<AuthProvider>().signInWithGoogle();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Google Sign-In failed: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/icons/google.png",
            height: isSmall ? 18 : 20,
          ),
          const SizedBox(width: 10),

          Flexible(
            child: Text(
              S.of(context).SignInWithGoogle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: _responsiveFont(context, 12),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
double _responsiveFont(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  if (width < 360) return size - 2;
  if (width < 400) return size - 1;
  return size;
}