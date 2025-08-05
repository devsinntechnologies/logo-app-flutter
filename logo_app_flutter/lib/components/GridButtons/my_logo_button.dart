import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyLogoButton extends StatelessWidget {
  const MyLogoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SnackBar snackBar = const SnackBar(
          content: Text('My Logo button pressed!'),
          duration: Duration(microseconds: 100),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Center(
        child: Container(
          height: 120, // ✔️ This sets the height
          width: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // color: const Color(0xFF5FD3F3),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 187, 153, 255), // light purple
                Color.fromARGB(255, 141, 101, 226), // deep purple
              ],
            ),
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
                    'assets/icons/gallery.png',
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'My Logo',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
