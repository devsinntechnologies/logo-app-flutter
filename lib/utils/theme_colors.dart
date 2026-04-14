import 'package:flutter/material.dart';

class ThemeColors {
  static const darkSecondaryColor = Color(0xFF0D0F20);
  static const darkPrimaryColor = Color(0xFF16182D);
  static const orange = Color(0xFF0D0F20);
  static const pink = Color(0xFFCB3E74);
  static const purple = Color(0xFFA744A2);
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
      Color(0xFFA744A2), // End color
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // New Dashboard Gradients
  static const LinearGradient mainCardGradient = LinearGradient(
    colors: [
      Color(0xFFFF6B21), // Orange
      Color(0xFFE91E63), // Pink
      Color(0xFF9C27B0), // Purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient continueGradient = LinearGradient(
    colors: [
      Color(0xFFFF6516), // Orange
      Color(0xFFD73ABA), // Pink
      Color(0xFFA628EB), // Purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient templatesGradient = LinearGradient(
    colors: [Color(0xFF00C3BF), Color(0xff00C478)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient customizeGradient = LinearGradient(
    colors: [Color(0xFFF335AA), Color(0xFFFC2A74)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient myLogosGradient = LinearGradient(
    colors: [Color(0xFFA02CFF), Color(0xFF7C2AF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient historyGradient = LinearGradient(
    colors: [Color(0xFFFFAC00), Color(0xFFFF4A1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Gradients
  static const LinearGradient retailGradient = LinearGradient(
    colors: [Color(0xFFFFF7B00), Color(0xFFFF6200), Color(0xFFFD402A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient foodGradient = LinearGradient(
    colors: [Color(0xFFFFA000), Color(0xFFFF6800), Color(0xFFFD3E2C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient healthGradient = LinearGradient(
    colors: [Color(0xFFFFA55AC), Color(0xFFF73298), Color(0xFFFD296E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient creativeGradient = LinearGradient(
    colors: [Color(0xFFEB36D1), Color(0xffF5339D), Color(0xFFC137D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient technologyGradient = LinearGradient(
    colors: [Color(0xFFA333FF), Color(0xFF9317FA), Color(0xFF7130F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient professionalGradient = LinearGradient(
    colors: [Color(0xFF3E68FF), Color(0xFF5637F6), Color(0xFF7E2AF9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient fitnessGradient = LinearGradient(
    colors: [Color(0xFF00D376), Color(0xFF00BA7D), Color(0xFF00A086)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient musicGradient = LinearGradient(
    colors: [Color(0xFFCE66FF), Color(0xFFE441FA), Color(0xFFF036B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient photographyGradient = LinearGradient(
    colors: [Color(0xFF00CDDE), Color(0xFF00BE9E), Color(0xFF00C669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient travelGradient = LinearGradient(
    colors: [Color(0xFF08A2FF), Color(0xFF377BFF), Color(0xFF516CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient fashionGradient = LinearGradient(
    colors: [Color(0xFFFE528B), Color(0xFFF534A1), Color(0xFFE633E2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cafeGradient = LinearGradient(
    colors: [Color(0xFFED9300), Color(0xffD48400), Color(0xFFE96400)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient realGradient = LinearGradient(
    colors: [Color(0xFF00CACA), Color(0xff00BAD9), Color(0xFF158FFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gameGradient = LinearGradient(
    colors: [Color(0xFF9341FF), Color(0xff9A0FF9), Color(0xFFB500EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient educationGradient = LinearGradient(
    colors: [Color(0xFF2DACF2), Color(0xff00B9D4), Color(0xFF00BAC1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient ecoGradient = LinearGradient(
    colors: [Color(0xFF00B45C), Color(0xff009866), Color(0xFF00977E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
