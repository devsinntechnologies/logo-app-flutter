import 'package:flutter/material.dart';
import 'package:logo_app_flutter/components/category_card.dart';
import 'package:logo_app_flutter/components/divider_container.dart';
import 'package:logo_app_flutter/provider/business_info_provider.dart';
import 'package:logo_app_flutter/provider/category_selection_provider.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:logo_app_flutter/screens/business_info_screen.dart';
import 'package:logo_app_flutter/models/industry_model.dart';
import 'package:provider/provider.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategorySelectionProvider>().fetchIndustries();
    });
  }

  // void _loadMore() {
  //   setState(() {
  //     _visibleCount += 20;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDF2F8),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset("assets/images/backarrow.png"),
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
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: DividerContainer(),
        ),
      ),
     
      body: Consumer<CategorySelectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchIndustries(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final industryModel = provider.industryModel;
          if (industryModel == null) {
            return const Center(child: Text('No categories found.'));
          }

          // COMBINE: industry + noiconIndustry for full coverage
          final industries = [
            ...industryModel.industry,
            ...industryModel.noiconIndustry,
          ];

          if (industries.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          // FRONTEND PAGINATION: Slice the list
          final visibleIndustries =
              industries.take(provider.visibleCount).toList();
          final hasMore = industries.length > provider.visibleCount;

          return SingleChildScrollView(
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
                  itemCount: visibleIndustries.length,
                  itemBuilder: (context, index) {
                    final industry = visibleIndustries[index];

                    // DYNAMIC GENERATION OF VISUALS
                    final Widget iconWidget = _buildCategoryIcon(industry);
                    final Gradient gradient = _getCategoryGradient(industry);

                    return CategoryCard(
                      title: industry.cateName,
                      icon: iconWidget,
                      gradient: gradient,
                      // FIX: Pass unique Hero tag using ID + Name
                      heroTag:
                          'cat_icon_${industry.catId}_${industry.cateName}',
                      onTap: () {
                        context
                            .read<BusinessInfoProvider>()
                            .updateCategory(industry.cateName, id: industry.catId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessInfoScreen(
                              categoryName: industry.cateName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

             
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<CategorySelectionProvider>().loadMore();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: ThemeColors.pink,
                          side: const BorderSide(color: ThemeColors.pink),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Load More Categories',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }



  Widget _buildCategoryIcon(Industry industry) {
    final name = industry.cateName.toLowerCase();
    String? assetPath;

    if (name.contains('retail'))
      assetPath = 'assets/images/image.png';
    else if (name.contains('food') || name.contains('beverage'))
      assetPath = 'assets/images/fock.png';
    else if (name.contains('health') || name.contains('wellness'))
      assetPath = 'assets/images/love.png';
    else if (name.contains('creative') || name.contains('design'))
      assetPath = 'assets/images/palette1.png';
    else if (name.contains('tech'))
      assetPath = 'assets/images/arror.png';
    else if (name.contains('professional') || name.contains('service'))
      assetPath = 'assets/images/bag.png';
    else if (name.contains('fitness') || name.contains('sport'))
      assetPath = 'assets/images/weight.png';
    else if (name.contains('music') || name.contains('entertainment'))
      assetPath = 'assets/images/music.png';
    else if (name.contains('photo'))
      assetPath = 'assets/images/camera1.png';
    else if (name.contains('travel') || name.contains('tourism'))
      assetPath = 'assets/images/travel.png';
    else if (name.contains('fashion') || name.contains('beauty'))
      assetPath = 'assets/images/shoper.png';
    else if (name.contains('cafe') || name.contains('bakery'))
      assetPath = 'assets/images/cup.png';
    else if (name.contains('real estate'))
      assetPath = 'assets/images/home.png';
    else if (name.contains('game'))
      assetPath = 'assets/images/game.png';
    else if (name.contains('education') || name.contains('school'))
      assetPath = 'assets/images/school.png';
    else if (name.contains('eco') || name.contains('nature'))
      assetPath = 'assets/images/leave.png';

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        height: 50,
        width: 60,
      );
    }

    // --- TRULY DYNAMIC GENERATION: Letter Icon Fallback ---
    // This part creates a professional visual from scratch for ANY unknown category.
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        industry.cateName.isNotEmpty ? industry.cateName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Gradient _getCategoryGradient(Industry industry) {
    final pool = ThemeColors.categoryGradients;
    // deterministic selection based on catId
    return pool[industry.catId % pool.length];
  }
}
