import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logo_app_flutter/components/dashboard/dashboard_card.dart';
import 'package:logo_app_flutter/components/dashboard/feature_list_item.dart';
import 'package:logo_app_flutter/components/divider_container.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:logo_app_flutter/screens/category_selection_screen.dart';
import 'package:logo_app_flutter/screens/my_design_screen.dart';
import 'package:logo_app_flutter/screens/template_gallery_screen.dart';
import 'package:logo_app_flutter/screens/download_logo.dart';
import 'package:logo_app_flutter/screens/home_screen.dart';

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
                    DividerContainer(),
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
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85,
                          children: [
                            DashboardCard(
                              title: 'Templates',
                              subtitle: 'Browse designs',
                              icon: Icon(Icons.auto_awesome), // Exact star/spark icon
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
                              icon: Icon(Icons
                                  .palette_outlined), // Correct palette/brush icon
                              gradient: ThemeColors.customizeGradient,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DownloadLogo(
                                          svgLogo: "",
                                          companyName: "",
                                          sloganName: "")),
                                );
                              },
                            ),
                            DashboardCard(
                              title: 'My Logos',
                              subtitle: 'Your collection',
                              icon: Icon(Icons.image), // Correct gallery icon
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
                              icon: Icon(Icons.history),
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
                          FeatureListItem(
                            icon: Icon(Iconsax.magicpen),
                            text: 'Instant logo generation with AI',
                            iconBgColor: LinearGradient(
                                colors: [Color(0xFFFE7359), Color(0xffF84490)]),
                            // Color(0xFFFE7359),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Color(0xFFF3F3F3)),
                          ),
                          const FeatureListItem(
                              icon: Icon(Icons.palette_outlined),
                              text: 'Customizable colors and styles',
                              // iconBgColor: Color(0xFF00BFA5),
                              iconBgColor: LinearGradient(colors: [
                                Color(0xFF00D3D6),
                                Color(0xff00CD84)
                              ])),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Color(0xFFF3F3F3)),
                          ),
                          const FeatureListItem(
                              icon: Icon(Icons.auto_awesome),
                              text: 'Professional quality designs',
                              // iconBgColor: Color(0xFF9C27B0),\
                              iconBgColor: LinearGradient(colors: [
                                Color(0xFFCD28FB),
                                Color(0xffAD1EFB)
                              ])),
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
