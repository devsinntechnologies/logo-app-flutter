import 'package:flutter/material.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
import 'package:logo_app_flutter/screens/dashboard_screen.dart';
import 'package:logo_app_flutter/screens/home_screen.dart';
import 'package:logo_app_flutter/screens/log_in_screen.dart';
import 'package:logo_app_flutter/screens/verify_email_screen.dart';
import 'package:logo_app_flutter/provider/auth_provider.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: firstNameController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: S.of(context).enterName,
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter first name'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Last Name
                  Text(
                    S.of(context).nameLast,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: lastNameController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: S.of(context).enterNameLast,
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter last name'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Email
                  Text(
                    S.of(context).email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: emailController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: S.of(context).enterEmail,
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      // if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      //     .hasMatch(value)) {
                      //   return 'Please enter a valid email';
                      // }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  Text(
                    S.of(context).password,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: passwordController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: S.of(context).enterPasswords,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password
                  Text(
                    S.of(context).passwordConfirm,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: confirmPasswordController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: S.of(context).confirmYourPassword,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please confirm password';
                      if (value != passwordController.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 38),

                  InkWell(
                    onTap: authProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();
                              final firstName = firstNameController.text.trim();
                              final lastName = lastNameController.text.trim();

                              final response =
                                  await authProvider.signUpWithEmail(
                                email: email,
                                password: password,
                                firstName: firstName,
                                lastName: lastName,
                              );

                              if (response != null && response.user != null) {
                                if (mounted) {
                                  if (response.session == null) {
                                    // Verification required
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VerifyEmailScreen(email: email),
                                      ),
                                    );
                                  } else {
                                    // Session active (verified)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Account created successfully!")),
                                    );
                                    // AuthWrapper will handle the transition, 
                                    // but we can also pop or navigate to Dashboard
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const DashboardScreen()),
                                      (route) => false,
                                    );
                                  }
                                }
                              } else if (authProvider.errorMessage != null) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(authProvider.errorMessage!)),
                                  );
                                }
                              }
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                S.of(context).signup,
                                style: const TextStyle(
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
        ));
  }
}
