import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/logo_design_provider.dart';
import '../components/design_style/font_style_card.dart';
import '../components/design_style/color_scheme_card.dart';
import '../utils/theme_colors.dart';

class DesignStyleScreen extends StatelessWidget {
  const DesignStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            ),
          ),
        ),
        title: const Text(
          'Design Style',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF5722), Color(0xFFE91E63), Color(0xFF9C27B0)],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<LogoDesignProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Customize your logo style',
                  style: TextStyle(
                    color: Color(0xFF4A4A6A),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

                // Font Style Section
                _buildSectionTitle('Font Style', Icons.text_fields_rounded, const Color(0xFFFF5252)),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: provider.fontStyles.length,
                  itemBuilder: (context, index) {
                    final item = provider.fontStyles[index];
                    return FontStyleCard(
                      name: item['name'],
                      textStyle: item['style'],
                      isSelected: provider.selectedFontIndex == index,
                      onTap: () => provider.setFont(index),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Color Scheme Section
                _buildSectionTitle('Color Scheme', Icons.color_lens_rounded, const Color(0xFF7C4DFF)),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: provider.colorPalettes.length,
                  itemBuilder: (context, index) {
                    final item = provider.colorPalettes[index];
                    return ColorSchemeCard(
                      name: item['name'],
                      colors: item['colors'],
                      isSelected: provider.selectedPaletteIndex == index,
                      onTap: () => provider.setPalette(index),
                    );
                  },
                ),

                const SizedBox(height: 50),

                // Final Action Button
                GestureDetector(
                  onTap: () {
                    // Final Generation Step
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating your master logo...')),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: ThemeColors.mainCardGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE91E63).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Generate Logos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF4A4A6A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
