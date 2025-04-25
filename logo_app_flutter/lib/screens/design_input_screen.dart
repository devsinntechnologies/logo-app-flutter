import 'package:flutter/material.dart';

class DesignInputScreen extends StatefulWidget {
  const DesignInputScreen({super.key});

  @override
  State<DesignInputScreen> createState() => _DesignInputScreenState();
}

class _DesignInputScreenState extends State<DesignInputScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Design Input Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go to Auto Design'),
            ),
          ],
        ),
      ),
    );
  }
}
