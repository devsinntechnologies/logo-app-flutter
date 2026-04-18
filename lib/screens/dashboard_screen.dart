import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logo_app_flutter/components/dashboard/dashboard_card.dart';
import 'package:logo_app_flutter/components/dashboard/feature_list_item.dart';
import 'package:logo_app_flutter/components/divider_container.dart';
import 'package:logo_app_flutter/screens/google_sign_in_button.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:logo_app_flutter/screens/category_selection_screen.dart';
import 'package:logo_app_flutter/screens/my_design_screen.dart';
import 'package:logo_app_flutter/screens/template_gallery_screen.dart';
import 'package:logo_app_flutter/screens/download_logo.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDF2F8), // Match figma background
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.only(top: 15, left: 0, right: 0, bottom: 0),
              color: Colors.transparent,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                          width:
                              48), // To balance the center text if login button is roughly 48-60w
                      Expanded(
                        child: Center(
                          child: Text(
                            'SMART LOGO MAKER',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const GoogleSignInButton(),
                      const SizedBox(width: 18),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Gradient Separator Line
                  const DividerContainer(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 26),
                      child: Column(
                        children: [
                          // Main Card
                          DashboardCard(
                            title: 'Create New Logo',
                            subtitle: 'AI-Powered Design',
                            icon: const Icon(Iconsax.magicpen),
                            gradient: ThemeColors.mainCardGradient,
                            isMain: true,
                            backgroundDecorations: [
                              Positioned(
                                right: -90,
                                top: -90,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -50,
                                bottom: -60,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                              ),
                            ],
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
                                childAspectRatio: 0.99,
                                children: [
                                  // DashboardCard(
                                  //   title: 'Templates',
                                  //   subtitle: 'Browse designs',
                                  //   icon: Image.asset(
                                  //     "assets/icons/d_star.png",
                                  //     height: 38,
                                  //     width: 38,
                                  //   ),
                                  //   gradient: ThemeColors.templatesGradient,
                                  //   backgroundDecorations: [
                                  //     Positioned(
                                  //       right: -50,
                                  //       bottom: -70,
                                  //       child: Container(
                                  //         width: 100,
                                  //         height: 100,
                                  //         decoration: BoxDecoration(
                                  //           shape: BoxShape.circle,
                                  //           color:
                                  //               Colors.white.withOpacity(0.12),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  //   onTap: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //           builder: (context) =>
                                  //               const TemplateGalleryScreen()),
                                  //     );
                                  //   },
                                  // ),
                               
                                  DashboardCard(
                                    title: 'Customize',
                                    subtitle: 'Make it yours',
                                    icon: Image.asset(
                                      "assets/images/palette1.png",
                                      height: 35,
                                      width: 35,
                                    ),
                                    gradient: ThemeColors.customizeGradient,
                                    backgroundDecorations: [
                                      Positioned(
                                        left: -70,
                                        top: -70,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.white.withOpacity(0.12),
                                          ),
                                        ),
                                      ),
                                    ],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const DownloadLogo(
                                                    svgLogo: "",
                                                    companyName: "",
                                                    sloganName: "")),
                                      );
                                    },
                                  ),
                                  DashboardCard(
                                    title: 'My Logos',
                                    subtitle: 'Your collection',
                                    icon: Image.asset(
                                      "assets/icons/pick.png",
                                      height: 26,
                                      width: 30,
                                      color: Colors.white,
                                    ),
                                    gradient: ThemeColors.myLogosGradient,
                                    backgroundDecorations: [
                                      Positioned(
                                        right: -50,
                                        top: -70,
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.white.withOpacity(0.12),
                                          ),
                                        ),
                                      ),
                                    ],
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //       builder: (context) =>
                                      //           MyDesignScreen(
                                      //               canvasKey: GlobalKey())),
                                      // );
                                    },
                                  ),
                                  // DashboardCard(
                                  //   title: 'History',
                                  //   subtitle: 'Recent designs',
                                  //   icon: Image.asset(
                                  //     "assets/images/history.png",
                                  //     height: 35,
                                  //     width: 39,
                                  //   ),
                                  //   gradient: ThemeColors.historyGradient,
                                  //   backgroundDecorations: [
                                  //     Positioned(
                                  //       left: -50,
                                  //       bottom: -75,
                                  //       child: Container(
                                  //         width: 100,
                                  //         height: 100,
                                  //         decoration: BoxDecoration(
                                  //           shape: BoxShape.circle,
                                  //           color:
                                  //               Colors.white.withOpacity(0.12),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  //   onTap: () {
                                  //     // Same as existing
                                  //   },
                                  // ),
                               
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 36),

                          // Bottom Section: AI-Powered Features
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
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
                                const SizedBox(height: 20),
                                const FeatureListItem(
                                  icon: Icon(Iconsax.magicpen),
                                  text: 'Instant logo generation with AI',
                                  iconBgColor: LinearGradient(colors: [
                                    Color(0xFFFE7359),
                                    Color(0xffF84490)
                                  ]),
                                ),
                                const FeatureListItem(
                                  icon: Icon(Icons.palette_outlined),
                                  text: 'Customizable colors and styles',
                                  iconBgColor: LinearGradient(colors: [
                                    Color(0xFF00D3D6),
                                    Color(0xff00CD84)
                                  ]),
                                ),
                                FeatureListItem(
                                  icon: Image.asset(
                                    "assets/images/ds_star.png",
                                    height: 30,
                                    width: 29,
                                  ),
                                  text: 'Professional quality designs',
                                  iconBgColor: LinearGradient(colors: [
                                    Color(0xFFCD28FB),
                                    Color(0xffAD1EFB)
                                  ]),
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
          ],
        ),
      ),
    );
  }
}
