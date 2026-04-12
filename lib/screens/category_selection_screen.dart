import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../components/category_card.dart';
import '../utils/theme_colors.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Retail',
        'icon': Iconsax.shop,
        'gradient': ThemeColors.retailGradient,
      },
      {
        'title': 'Food & Beverage',
        'icon': Icons.restaurant,
        'gradient': ThemeColors.foodGradient,
      },
      {
        'title': 'Health & Wellness',
        'icon': Icons.favorite_border,
        'gradient': ThemeColors.healthGradient,
      },
      {
        'title': 'Creative & Design',
        'icon': Icons.palette_outlined,
        'gradient': ThemeColors.creativeGradient,
      },
      {
        'title': 'Technology',
        'icon': Icons.code,
        'gradient': ThemeColors.technologyGradient,
      },
      {
        'title': 'Professional Services',
        'icon': Iconsax.briefcase,
        'gradient': ThemeColors.professionalGradient,
      },
      {
        'title': 'Fitness & Sports',
        'icon': Icons.fitness_center,
        'gradient': ThemeColors.fitnessGradient,
      },
      {
        'title': 'Music & Entertainment',
        'icon': Icons.music_note_outlined,
        'gradient': ThemeColors.musicGradient,
      },
      {
        'title': 'Photography',
        'icon': Icons.camera_alt_outlined,
        'gradient': ThemeColors.photographyGradient,
      },
      {
        'title': 'Travel & Tourism',
        'icon': Icons.explore_outlined,
        'gradient': ThemeColors.travelGradient,
      },
      {
        'title': 'Fashion & Beauty',
        'icon': Iconsax.bag,
        'gradient': ThemeColors.fashionGradient,
      },
      {
        'title': 'Cafe & Bakery',
        'icon': Icons.coffee_outlined,
        'gradient': ThemeColors.cafeGradient,
      },
      {
        'title': 'Real Estate',
        'icon': Iconsax.house,
        'gradient': ThemeColors.templatesGradient,
      },
      {
        'title': 'Gaming',
        'icon': Icons.gamepad_outlined,
        'gradient': ThemeColors.myLogosGradient,
      },
      {
        'title': 'Education',
        'icon': Icons.school_outlined,
        'gradient': ThemeColors.technologyGradient,
      },
      {
        'title': 'Eco & Nature',
        'icon': Icons.eco_outlined,
        'gradient': ThemeColors.fitnessGradient,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          'Select Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF2E94), Color(0xFFC32BAC)],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Choose the category that best fits your business',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(
                  title: category['title'],
                  icon: category['icon'],
                  gradient: category['gradient'],
                  onTap: () {
                    // Logic when category selected
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
