import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logo_app_flutter/screens/home_screen.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController controller;
  bool isReady = false;
  bool isVideoCompleted = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset("assets/videos/splash_screen.mp4")
      ..addListener(() {
        if (controller.value.position >= controller.value.duration &&
            controller.value.isInitialized &&
            controller.value.duration != Duration.zero) {
          // Prevent multiple navigations
          if (!isVideoCompleted) {
            isVideoCompleted = true;

            // Navigate to next screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          }
        }
      })
      ..initialize().then((_) {
        controller.play();
        controller.setLooping(false);

        setState(() {
          isReady = true;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromRGBO(24, 25, 45, 1),
      body: Stack(
        children: [
          Center(
            child: isReady
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Transform.scale(
                      scale: 2.3, // Increase this to zoom (1.0 = normal)
                      child: VideoPlayer(controller),
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
          Positioned(
              left: size.width * 0.30,
              bottom: 30,
              child: Text(
                "Smart Logo Maker",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
