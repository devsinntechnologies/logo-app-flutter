import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logo_app_flutter/generated/l10n.dart';
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

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset("assets/videos/splash_screen.mp4")
      ..initialize().then((_) {
        controller.play();
        controller.setLooping(false);

        controller.addListener(() {
          bool finished =
              controller.value.position >= controller.value.duration;
          if (finished) {
            navigateToHome();
          }
        });

        setState(() {
          isReady = true;
        });
      });
  }

  void navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 25, 45, 1),
      body: controller.value.isInitialized
          ? Stack(
              children: [
                // FULL SCREEN VIDEO WITH ZOOM
                Center(
                  child: Transform.scale(
                    scale: 2.3,
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: Text(
                      S.of(context).smartLogoMakerText,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
