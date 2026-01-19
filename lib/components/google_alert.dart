import 'package:flutter/material.dart';
import 'package:logo_app_flutter/screens/log_in_screen.dart';
import 'package:logo_app_flutter/screens/sign_up_screen.dart';
import 'package:logo_app_flutter/services/auth_service.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart'; // import your service

final AuthService _auth = AuthService(); // create service object

void showCustomGoogleDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[100],
        title: Column(
          children: [
            SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: ThemeColors.yellowOrangePink,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      offset: const Offset(4, 4),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(-4, -4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: ThemeColors.yellowOrangePink,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      offset: const Offset(4, 4),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(-4, -4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "OR",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await _auth.signInWithGoogle();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/google.png",
                    height: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Sign In with Google",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
