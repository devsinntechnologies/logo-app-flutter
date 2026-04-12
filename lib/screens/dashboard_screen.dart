import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logo_app_flutter/components/dashboard/dashboard_card.dart';
import 'package:logo_app_flutter/components/dashboard/feature_list_item.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:logo_app_flutter/screens/category_selection_screen.dart';
import 'package:logo_app_flutter/screens/my_design_screen.dart';
import 'package:logo_app_flutter/screens/template_gallery_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF), // Subtle lavender tint
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24, bottom: 0),
                color: Colors.white,
                child: Column(
                  children: [
                    const Text(
                      'Smart Logo Maker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Gradient Separator Line
                    Container(
                      height: 2.5,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF6B21),
                            Color(0xFFE91E63),
                            Color(0xFF9C27B0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                child: Column(
                  children: [
                    // Main Card
                    DashboardCard(
                      title: 'Create New Logo',
                      subtitle: 'AI-Powered Design',
                      icon: const Icon(Iconsax.magicpen),
                      gradient: ThemeColors.mainCardGradient,
                      isMain: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CategorySelectionScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Secondary Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.85,
                          children: [
                            DashboardCard(
                              title: 'Templates',
                              subtitle: 'Browse designs',
                              icon: const Icon(
                                  Iconsax.status_up), // Exact star/spark icon
                              gradient: ThemeColors.templatesGradient,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const TemplateGalleryScreen()),
                                );
                              },
                            ),
                            DashboardCard(
                              title: 'Customize',
                              subtitle: 'Make it yours',
                              icon: const Icon(Iconsax
                                  .brush_2), // Correct palette/brush icon
                              gradient: ThemeColors.customizeGradient,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyDesignScreen(
                                          canvasKey: GlobalKey())),
                                );
                              },
                            ),
                            DashboardCard(
                              title: 'My Logos',
                              subtitle: 'Your collection',
                              icon: const Icon(
                                  Iconsax.image), // Correct gallery icon
                              gradient: ThemeColors.myLogosGradient,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyDesignScreen(
                                          canvasKey: GlobalKey())),
                                );
                              },
                            ),
                            DashboardCard(
                              title: 'History',
                              subtitle: 'Recent designs',
                              icon: const Icon(Iconsax.clock),
                              gradient: ThemeColors.historyGradient,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CategorySelectionScreen()),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // Bottom Section: AI-Powered Features
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'AI-Powered Features',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 25),
                          const FeatureListItem(
                            icon: Icon(Iconsax.magicpen),
                            text: 'Instant logo generation with AI',
                            iconBgColor: Color(0xFFE91E63),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Color(0xFFF3F3F3)),
                          ),
                          const FeatureListItem(
                            icon: Icon(Iconsax.brush_2),
                            text: 'Customizable colors and styles',
                            iconBgColor: Color(0xFF00BFA5),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Color(0xFFF3F3F3)),
                          ),
                          const FeatureListItem(
                            icon: Icon(Iconsax.status_up),
                            text: 'Professional quality designs',
                            iconBgColor: Color(0xFF9C27B0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
