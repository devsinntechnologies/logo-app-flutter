import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logo_app_flutter/provider/intro_provider.dart';
import 'package:logo_app_flutter/screens/dashboard_screen.dart';

class IntroAnimationScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const IntroAnimationScreen({super.key, required this.onComplete});

  @override
  State<IntroAnimationScreen> createState() => _IntroAnimationScreenState();
}

class _IntroAnimationScreenState extends State<IntroAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-3.0, 0.0), // Start from far LEFT
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Use Provider to handle sequence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final introProvider = context.read<IntroProvider>();
      introProvider.startSequence(
        onStageTwo: () => _controller.forward(),
        onComplete: () {
          if (mounted) {
            widget.onComplete();
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9C27B0), // Match theme base
      body: Consumer<IntroProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // STAGE 1 & 2 BASE: The full screen image Home1.png
              Positioned.fill(
                child: Image.asset(
                  'assets/images/Home1.png',
                  fit: BoxFit.cover,
                ),
              ),

              // STAGE 2 LAYER: The gradient and animated bulb
              if (provider.showStageTwo)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF6B21), // Orange
                          Color(0xFFE91E63), // Pink
                          Color(0xFF9C27B0), // Purple
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            // Sliding Bulb Icon with Bounce (FROM LEFT)
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _opacityAnimation,
                                child: Image.asset(
                                  'assets/logo_images/bulb.png',
                                  width: 400,
                                  height: 400,
                                ),
                              ),
                            ),
                            const Spacer(flex: 2),
                            // AI Footer Text
                            FadeTransition(
                              opacity: _textOpacityAnimation,
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 60.0),
                                child: Center(
                                  child: Text(
                                    'AI Powered Design Studio',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
