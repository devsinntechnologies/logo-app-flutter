import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/divider_container.dart';
import 'package:provider/provider.dart';
import '../provider/business_info_provider.dart';
import '../provider/logo_design_provider.dart';
import 'package:logo_app_flutter/screens/logo_generation_screen.dart';
import '../components/design_style/font_style_card.dart';
import '../components/design_style/color_scheme_card.dart';
import '../utils/theme_colors.dart';

class DesignStyleScreen extends StatelessWidget {
  const DesignStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F5),
      appBar: AppBar(
        toolbarHeight: 80,
        // toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
                // height: 10,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  // shape: BoxShape.circle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset("assets/images/backarrow.png")
                // const
                //  Icon(Icons.arrow_back,
                //     color: Color(0xFF1F1F39), size: 25),
                ),
          ),
        ),
        title: const Text(
          'Design Style',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),

        // con.st SizedBox(height: 12),

        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2), child: DividerContainer()
            //  Container(
            //   height: 2,
            //   decoration: const BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [Color(0xFFFF2E94), Color(0xFFC32BAC)],
            //     ),
            //   ),
            // ),
            ),
      ),
      body: Consumer<LogoDesignProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Customize your logo style',
                        style: TextStyle(
                          color: Color(0xFF364153),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Font Style Section
                      _buildSectionTitle(
                          'Font Style',
                          // Icons.text_fields_rounded,
                          Image.asset("assets/images/text.png"),
                          [const Color(0xFFFF8904), const Color(0xFFF6339A)]),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: provider.fontStyles.length,
                        itemBuilder: (context, index) {
                          final item = provider.fontStyles[index];
                          return FontStyleCard(
                            name: item['name'],
                            textStyle: item['style'],
                            isSelected: provider.selectedFontIndex == index,
                            onTap: () {
                              provider.setFont(index);
                              // Sync to session provider
                              context.read<BusinessInfoProvider>().updateDesign(
                                (index + 1).toString(), 
                                context.read<BusinessInfoProvider>().selectedColorId
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Color Scheme Section
                      _buildSectionTitle(
                          'Color Scheme',
                          Image.asset(
                            "assets/images/palette.png",
                            height: 30,
                          ),
                          // Icons.color_lens_rounded,
                          [const Color(0xFFE12AFB), const Color(0xFF9810FA)]),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: provider.colorPalettes.length,
                        itemBuilder: (context, index) {
                          final item = provider.colorPalettes[index];
                          return ColorSchemeCard(
                            name: item['name'],
                            colors: item['colors'],
                            isSelected: provider.selectedPaletteIndex == index,
                            onTap: () {
                                provider.setPalette(index);
                                // Sync to session provider
                                context.read<BusinessInfoProvider>().updateDesign(
                                  context.read<BusinessInfoProvider>().selectedFontId,
                                  (index + 1).toString()
                                );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),

              // Final Action Button - Pinned at bottom
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogoGenerationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: ThemeColors.continueGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE91E63).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Glossy Bubble Top-Right
                        Positioned(
                          right: -20,
                          top: -10,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                        // Glossy Bubble Bottom-Left
                        Positioned(
                          left: -20,
                          bottom: -20,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Generate Logos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Widget icon, List<Color> colors) {
    return Row(
      children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: icon
            // Icon(icon, color: Colors.white, size: 22),
            ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E2939),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
