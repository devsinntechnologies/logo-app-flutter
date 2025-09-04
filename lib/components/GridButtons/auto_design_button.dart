import 'package:flutter/material.dart';
import 'package:logo_app_flutter/screens/design_input_screen.dart';

class AutoDesignButton extends StatelessWidget {
  const AutoDesignButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DesignInputScreen()),
        );
      },
      child: Center(
        child: Container(
          height: 120, // ✔️ This sets the height
          width: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF5FD3F3),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                spreadRadius: 3,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // optional
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/icons/wandd.png',
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(height: 20),
                  const Text(
                    'Auto Design',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
