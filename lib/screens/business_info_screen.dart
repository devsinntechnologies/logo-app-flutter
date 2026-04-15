import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/divider_container.dart';
import 'package:provider/provider.dart';
import '../provider/business_info_provider.dart';
import 'package:logo_app_flutter/screens/design_style_screen.dart';
import '../components/business_info/business_input_card.dart';
import '../components/business_info/business_preview_card.dart';
import '../components/business_info/business_continue_button.dart';

class BusinessInfoScreen extends StatefulWidget {
  final String categoryName;

  const BusinessInfoScreen({super.key, required this.categoryName});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sloganController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing values from Provider
    final provider = context.read<BusinessInfoProvider>();
    _nameController.text = provider.businessName;
    _sloganController.text = provider.slogan;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sloganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F9),
                // shape: BoxShape.circle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Color(0xFF1F1F39), size: 25),
            ),
          ),
        ),
        title: const Text(
          'Business Info',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2), child: DividerContainer()

            //  Container(
            //   height: 4,
            //   decoration: const BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         Color(0xFFFF5722),
            //         Color(0xFFE91E63),
            //         Color(0xFF9C27B0)
            //       ],
            //     ),
            //   ),
            // ),
            ),
      ),
      body: Consumer<BusinessInfoProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Tell us about your business',
                  style: TextStyle(
                    color: Color(0xFF171717),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),

                // Business Name Card
                BusinessInputCard(
                  title: 'Business Name *',
                  hint: 'Enter your business name',
                  icon: Icons.business,
                  iconBgColor: const Color(0xFFFF5252).withOpacity(0.8),
                  controller: _nameController,
                  maxLength: 30,
                  onChanged: (val) => provider.updateBusinessName(val),
                ),

                const SizedBox(height: 20),

                // Slogan Card
                BusinessInputCard(
                  title: 'Slogan (Optional)',
                  hint: 'Your business tagline',
                  icon: Icons.chat_bubble_outline_rounded,
                  iconBgColor: const Color(0xFF9C27B0).withOpacity(0.8),
                  controller: _sloganController,
                  maxLength: 50,
                  onChanged: (val) => provider.updateSlogan(val),
                ),

                const SizedBox(height: 30),

                // Preview Card
                BusinessPreviewCard(
                  showPreview: provider.showPreview,
                  businessName: provider.businessName,
                  slogan: provider.slogan,
                ),

                // const SizedBox(height: 30),

                // Continue Button
                BusinessContinueButton(
                  isEnabled: provider.canContinue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DesignStyleScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
