import 'package:flutter/material.dart';

class ThemeColors {
  static const darkSecondaryColor = Color(0xFF0D0F20);
  static const darkPrimaryColor = Color(0xFF16182D);
  static const orange = Color(0xFF0D0F20);
  static const pink = Color(0xFFCB3E74);
  static const purple =Color(0xFFA744A2);
  static const lightPurple = Color(0xFFA157A7);
  static const blue = 0xFF0D0F20;
  static const yellow = 0xFF16182D;

   static const LinearGradient textGradient = LinearGradient(
    colors: [
      Color(0xFFCB3E74), // Start color
      Color(0xFFA744A2), // End color
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient customGradient = LinearGradient(
    colors: [
      Color(0xFF16182D), // Start color
      Color(0xFF0D0F20), // End color
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient orangePinkPurple = LinearGradient(
    colors: [
      Color(0xFFF29E74), // Start color
      Color(0xFFDF6C87),
      Color(0xFFA744A2), // End color
       // End color
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient greenBlue = LinearGradient(
    colors: [
      Color(0xFF7EC084), 
      Color(0xFF4FA2A4),
      Color(0xFF3A78B4), 
       
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient yellowOrangePink = LinearGradient(
    colors: [
      Color(0xFFF6BF76), // Start color
      Color(0xFFED8667), 
      Color(0xFFCB3E74), // End color

    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
    static const LinearGradient yellowOrangePurple = LinearGradient(
    colors: [
      Color(0xFFF6BF76), // Start color
      Color(0xFFED8667), 
     Color(0xFFA744A2),  // End color

    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
