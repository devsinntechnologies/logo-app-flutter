import 'package:flutter/material.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/screens/home_screen.dart';
import 'package:logo_app_flutter/screens/log_in_screen.dart';
import 'package:logo_app_flutter/services/auth_service.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // @override
  // void dispose() {
  //   firstNameController.dispose();
  //   lastNameController.dispose();
  //   emailController.dispose();
  //   passwordController.dispose();
  //   confirmPasswordController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // title: const Text('Sign Up'),
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).signup,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.purple),
              ),

              const SizedBox(height: 32),

              // First Name
              Text(
                S.of(context).name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: firstNameController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: S.of(context).enterName,
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Last Name
              Text(
                S.of(context).nameLast,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: lastNameController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: S.of(context).enterNameLast,
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email
              Text(
                S.of(context).email,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: emailController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: S.of(context).enterEmail,
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password
              Text(
                S.of(context).password,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: passwordController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: S.of(context).enterPasswords,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Confirm Password
              Text(
                S.of(context).passwordConfirm,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: confirmPasswordController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: S.of(context).confirmYourPassword,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 38),

              InkWell(
                onTap: () async {
                  final email = emailController.text;
                  // Debug logging removed for production
                  final password = passwordController.text;
                  final confirmPassword = confirmPasswordController.text;
                  final firstName = firstNameController.text;
                  final lastName = lastNameController.text;

                  if (password != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Passwords do not match")),
                    );
                    return;
                  }

                  try {
                    final auth = AuthService();
                    // Debug logging removed for production
                    final response = await auth.signUpWithEmail(
                      email: email,
                      password: password,
                      firstName: firstName,
                      lastName: lastName,
                    );

                    // if (response.user != null) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //         content: Text("Account created! Please log in.")),
                    //   );

                    //   Navigator.pushReplacement(
                    //     context,
                    //     MaterialPageRoute(builder: (_) => const LoginScreen()),
                    //   );
                    // }
                    if (response.user != null) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Sign up failed: $e")),
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: ThemeColors.orangePinkPurple,
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
                      S.of(context).signup,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      S.of(context).login,
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
