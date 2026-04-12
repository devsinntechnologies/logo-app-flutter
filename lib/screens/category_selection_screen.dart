import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logo_app_flutter/components/category_card.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:logo_app_flutter/screens/business_info_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Retail',
        'image': 'assets/images/image.png',
        'gradient': ThemeColors.retailGradient,
      },
      {
        'title': 'Food & Beverage',
        'image': 'assets/images/restaurant.png',
        'gradient': ThemeColors.foodGradient,
      },
      {
        'title': 'Health & Wellness',
        'image': 'assets/images/favorite.png',
        'gradient': ThemeColors.healthGradient,
      },
      {
        'title': 'Creative & Design',
        'image': 'assets/images/palette.png',
        'gradient': ThemeColors.creativeGradient,
      },
      {
        'title': 'Technology',
        'image': 'assets/images/code.png',
        'gradient': ThemeColors.technologyGradient,
      },
      {
        'title': 'Professional Services',
        'image': 'assets/images/briefcase.png',
        'gradient': ThemeColors.professionalGradient,
      },
      {
        'title': 'Fitness & Sports',
        'image': 'assets/images/fitness.png',
        'gradient': ThemeColors.fitnessGradient,
      },
      {
        'title': 'Music & Entertainment',
        'image': 'assets/images/music.png',
        'gradient': ThemeColors.musicGradient,
      },
      {
        'title': 'Photography',
        'image': 'assets/images/camera.png',
        'gradient': ThemeColors.photographyGradient,
      },
      {
        'title': 'Travel & Tourism',
        'image': 'assets/images/explore.png',
        'gradient': ThemeColors.travelGradient,
      },
      {
        'title': 'Fashion & Beauty',
        'image': 'assets/icons/bag.png',
        'gradient': ThemeColors.fashionGradient,
      },
      {
        'title': 'Cafe & Bakery',
        'image': 'assets/images/coffee.png',
        'gradient': ThemeColors.cafeGradient,
      },
      {
        'title': 'Real Estate',
        'image': 'assets/images/house.png',
        'gradient': ThemeColors.templatesGradient,
      },
      {
        'title': 'Gaming',
        'image': 'assets/images/gamepad.png',
        'gradient': ThemeColors.myLogosGradient,
      },
      {
        'title': 'Education',
        'image': 'assets/images/school.png',
        'gradient': ThemeColors.technologyGradient,
      },
      {
        'title': 'Eco & Nature',
        'image': 'assets/icons/eco.png',
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
              child:
                  const Icon(Icons.arrow_back, color: Colors.black, size: 20),
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
                  image: category['image'],
                  gradient: category['gradient'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusinessInfoScreen(
                          categoryName: category['title'],
                        ),
                      ),
                    );
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
