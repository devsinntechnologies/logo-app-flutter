import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/auto_design_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            'Auto Design Module',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 80),
          const AutoDesignButton(),
        ],
      ),
    );
  }
}
