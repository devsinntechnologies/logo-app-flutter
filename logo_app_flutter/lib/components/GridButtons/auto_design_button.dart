import 'package:flutter/material.dart';
import 'package:logo_app_flutter/screens/design_input_screen.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 220, 
            // width: 150,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: ThemeColors.orangePinkPurple,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: 3,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // optional
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/wandd.png',
                        width: 60,
                        // height: 40,
                      ),
                      SizedBox(height: 25),
                      const Text(
                        'Auto Design',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      const Icon(Icons.chevron_right, color: Colors.white,size: 42,),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
