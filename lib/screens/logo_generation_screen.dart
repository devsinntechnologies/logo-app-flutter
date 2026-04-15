import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_app_flutter/screens/logo_results_screen.dart';
import 'package:logo_app_flutter/provider/business_info_provider.dart';
import 'package:logo_app_flutter/provider/logo_results_provider.dart';
import '../provider/logo_generation_provider.dart';

class LogoGenerationScreen extends StatefulWidget {
  const LogoGenerationScreen({super.key});

  @override
  State<LogoGenerationScreen> createState() => _LogoGenerationScreenState();
}

class _LogoGenerationScreenState extends State<LogoGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final businessInfo = context.read<BusinessInfoProvider>();
      context.read<LogoResultsProvider>().fetchLogos(
            businessInfo.businessName,
            businessInfo.slogan,
          );

      context.read<LogoGenerationProvider>().startSimulation(
        onComplete: () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LogoResultsScreen(),
              ),
            );
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: Consumer<LogoGenerationProvider>(
        builder: (context, provider, child) {
          final step = provider.steps[provider.currentStepIndex];

          return Stack(
            children: [
              // Bubbles Layer
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    final h = MediaQuery.of(context).size.height;
                    final w = MediaQuery.of(context).size.width;

                    Widget buildBubble(double xOffset, double size, Color c,
                        double speed, double delay) {
                      double t =
                          (_rotationController.value * speed + delay) % 1.0;
                      double y = h - (t * h * 0.8);
                      double opacity = math.sin(t * math.pi);
                      return Positioned(
                        left: (w / 2) + xOffset - (size / 2),
                        top: y,
                        child: Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: Container(
                            width: size,
                            height: size,
                            decoration:
                                BoxDecoration(shape: BoxShape.circle, color: c),
                          ),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        buildBubble(-50, 10,
                            Colors.purpleAccent.withOpacity(0.5), 0.7, 0.1),
                        buildBubble(40, 12, Colors.pinkAccent.withOpacity(0.6),
                            1.0, 0.4),
                        buildBubble(10, 8, Colors.orangeAccent.withOpacity(0.6),
                            1.2, 0.7),
                        buildBubble(-30, 14,
                            Colors.deepPurpleAccent.withOpacity(0.5), 0.8, 0.2),
                        buildBubble(
                            60, 9, Colors.pink.withOpacity(0.5), 1.1, 0.6),
                        buildBubble(-10, 11,
                            Colors.amberAccent.withOpacity(0.5), 0.9, 0.9),
                      ],
                    );
                  },
                ),
              ),

              Positioned.fill(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const Spacer(),
                      // Diamond Rotating Container
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationController.value * 2 * math.pi,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: step['colors'],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(45),
                                boxShadow: [
                                  BoxShadow(
                                    color: (step['colors'] as List<Color>)
                                        .first
                                        .withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  step['icon'],
                                  color: Colors.white,
                                  size: 70,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 50),

                      // Status Text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          step['title'],
                          key: ValueKey(step['title']),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFF06292),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Progress Bar Container
                      Stack(
                        children: [
                          // Background track
                          Container(
                            width: double.infinity,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          // Animated Fill
                          FractionallySizedBox(
                            widthFactor: provider.progress,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  // colors: [Colors.black, Colors.white]
                                  colors: [
                                    Color(0xFFFF5252),
                                    Color(0xFF7C4DFF)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Percentage Text
                      Text(
                        '${(provider.progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFF4A4A6A),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      // Bottom Indicator (3 pill/dots)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5252), Color(0xFF7C4DFF)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 25,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5252), Color(0xFF7C4DFF)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2))
                                ]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
