import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logo_app_flutter/components/category_card.dart';
import 'package:logo_app_flutter/components/divider_container.dart';
import 'package:logo_app_flutter/provider/business_info_provider.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:logo_app_flutter/screens/business_info_screen.dart';
import 'package:provider/provider.dart';

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
        'image': 'assets/images/fock.png',
        'gradient': ThemeColors.foodGradient,
      },
      {
        'title': 'Health & Wellness',
        'image': 'assets/images/love.png',
        'gradient': ThemeColors.healthGradient,
      },
      {
        'title': 'Creative & Design',
        'image': 'assets/images/palette1.png',
        'gradient': ThemeColors.creativeGradient,
      },
      {
        'title': 'Technology',
        'image': 'assets/images/code.png',
        'gradient': ThemeColors.technologyGradient,
      },
      {
        'title': 'Professional Services',
        'image': 'assets/images/bag.png',
        'gradient': ThemeColors.professionalGradient,
      },
      {
        'title': 'Fitness & Sports',
        'image': 'assets/images/weight.png',
        'gradient': ThemeColors.fitnessGradient,
      },
      {
        'title': 'Music & Entertainment',
        'image': 'assets/images/music.png',
        'gradient': ThemeColors.musicGradient,
      },
      {
        'title': 'Photography',
        'image': 'assets/images/camera1.png',
        'gradient': ThemeColors.photographyGradient,
      },
      {
        'title': 'Travel & Tourism',
        'image': 'assets/images/travel.png',
        'gradient': ThemeColors.travelGradient,
      },
      {
        'title': 'Fashion & Beauty',
        'image': 'assets/images/shoper.png',
        'gradient': ThemeColors.fashionGradient,
      },
      {
        'title': 'Cafe & Bakery',
        'image': 'assets/images/cup.png',
        'gradient': ThemeColors.cafeGradient,
      },
      {
        'title': 'Real Estate',
        'image': 'assets/images/home.png',
        'gradient': ThemeColors.realGradient,
      },
      {
        'title': 'Gaming',
        'image': 'assets/images/game.png',
        'gradient': ThemeColors.gameGradient,
      },
      {
        'title': 'Education',
        'image': 'assets/images/school.png',
        'gradient': ThemeColors.educationGradient,
      },
      {
        'title': 'Eco & Nature',
        'image': 'assets/images/leave.png',
        'gradient': ThemeColors.ecoGradient,
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xffF3F4F6),
      appBar: AppBar(
        // toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
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
          'Select Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),

        // con.st SizedBox(height: 12),

        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1), child: DividerContainer()
            //  Container(
            //   height: 1,
            //   decoration: const BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [Color(0xFFFF2E94), Color(0xFFC32BAC)],
            //     ),
            //   ),
            // ),
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
                color: Color(0xff101828),
                fontSize: 16,
                fontWeight: FontWeight.w400,
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
                childAspectRatio: 0.99,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(
                  title: category['title'],
                  image: category['image'],
                  gradient: category['gradient'],
                  onTap: () {
                    context
                        .read<BusinessInfoProvider>()
                        .updateCategory(category['title']);
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
