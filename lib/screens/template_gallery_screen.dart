import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logo_app_flutter/provider/gallery_provider.dart';
import 'package:logo_app_flutter/screens/category_selection_screen.dart';
import 'package:logo_app_flutter/components/gallery/gallery_chip.dart';
import 'package:logo_app_flutter/components/gallery/template_row.dart';
import 'package:logo_app_flutter/components/gallery/template_row_item.dart';
import 'package:provider/provider.dart';

class TemplateGalleryScreen extends StatefulWidget {
  const TemplateGalleryScreen({super.key});

  @override
  State<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends State<TemplateGalleryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GalleryProvider>().selectCategory('All');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        final filteredTemplates = provider.getFilteredTemplates();
        final isSearching = provider.searchQuery.isNotEmpty;

        return Scaffold(
          backgroundColor: Color(0xffFDF3F5),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                _buildHeader(context),

                // ── Search + Category Filters ────────────────────────────
                _buildSearchAndFilters(context, provider),

                // ── Content ──────────────────────────────────────────────
                Expanded(
                  child: isSearching || provider.selectedCategory != 'All'
                      ? _buildGridView(context, provider, filteredTemplates)
                      : _buildAllView(context, provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: [
            SizedBox(
              height: 20,
            ),
            // Back button — gradient rounded square
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6516),
                      Color(0xFFD73ABA),
                      Color(0xFFA628EB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD73ABA).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset("assets/images/backarrow.png",
                    color: Colors.white, height: 18),
              ),
            ),

            const SizedBox(width: 14),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Template Gallery',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Choose your design style',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6A7282),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // // Decorative badge
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFFDF2F8),
            //     borderRadius: BorderRadius.circular(20),
            //     border: Border.all(
            //       color: const Color(0xFFD73ABA).withOpacity(0.25),
            //       width: 1,
            //     ),
            //   ),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: const [
            //       Icon(Icons.auto_awesome_rounded,
            //           size: 13, color: Color(0xFFD73ABA)),
            //       SizedBox(width: 4),
            //       Text(
            //         'Premium',
            //         style: TextStyle(
            //           fontSize: 11,
            //           fontWeight: FontWeight.w600,
            //           color: Color(0xFFD73ABA),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEARCH + CATEGORY FILTERS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearchAndFilters(
      BuildContext context, GalleryProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                // Search icon toggle
                GestureDetector(
                  onTap: () => provider.toggleSearchExpanded(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: provider.isSearchExpanded
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFFF6516),
                                Color(0xFFD73ABA),
                                Color(0xFFA628EB),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: provider.isSearchExpanded ? null : Colors.white,
                      shape: BoxShape.circle,
                      border: provider.isSearchExpanded
                          ? null
                          : Border.all(
                              color: const Color(0xFFC32BAC).withOpacity(0.3),
                              width: 1,
                            ),
                      boxShadow: provider.isSearchExpanded
                          ? [
                              BoxShadow(
                                color: const Color(0xFFD73ABA).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Image.asset(
                      "assets/images/search.png",
                      height: 20,
                      color: provider.isSearchExpanded
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Category chips
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.categories.length,
                      itemBuilder: (context, index) {
                        final cat = provider.categories[index];
                        return GalleryChip(
                          label: cat,
                          isSelected: provider.selectedCategory == cat,
                          onTap: () => provider.selectCategory(cat),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expandable search field
          Padding(
            padding: const EdgeInsets.only(left: 19, right: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: provider.isSearchExpanded ? 60 : 0,
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(top: provider.isSearchExpanded ? 12 : 0),
              child: provider.isSearchExpanded
                  ? TextField(
                      controller: provider.searchController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search templates...',
                        hintStyle: TextStyle(color: Colors.black, fontSize: 14),
                        suffixIcon:
                            Image.asset("assets/images/search.png", height: 20),
                        filled: true,
                        fillColor: const Color(0xFFFDF2F8),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: const Color(0xFFD73ABA).withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFD73ABA),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (val) => provider.updateSearchQuery(val),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          //  Divider()
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            width: double.infinity,
            height: 1,
          )
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ALL VIEW (horizontal rows per category)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAllView(BuildContext context, GalleryProvider provider) {
    return SingleChildScrollView(
      controller: provider.scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          ...provider.templateData.entries.map((entry) {
            return TemplateRow(
              title: entry.key,
              onSeeAll: () => provider.selectCategory(entry.key),
              items: entry.value.map((item) {
                return TemplateRowItem(
                  icon: Image.asset(
                    item['image'] as String,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  isAd: item['isAd'] as bool,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategorySelectionScreen(),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 10),
          _buildPremiumBanner(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PREMIUM BANNER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6516), Color(0xFFD73ABA), Color(0xFFA628EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD73ABA).withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles inside banner
          Positioned(
            right: -50,
            top: -60,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.09),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -50,
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon box
                  Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Image.asset(
                        "assets/gallery_images/king.png",
                        height: 40,
                        width: 40,
                      )
                      // const Icon(
                      //   Icons.workspace_premium_rounded,
                      //   color: Colors.yellow,
                      //   size: 28,
                      // ),
                      ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Premium Template',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Unlock 500+ exclusive designs',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Upgrade button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'UPGRADE NOW',
                    style: TextStyle(
                      color: Color(0xFFD73ABA),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GRID VIEW (filtered / category / search results)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGridView(
    BuildContext context,
    GalleryProvider provider,
    List<Map<String, dynamic>> items,
  ) {
    return SingleChildScrollView(
      controller: provider.scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results count header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6516), Color(0xFFA628EB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${items.length} templates found',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),

          if (items.isEmpty)
            _buildNoResults()
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildGridCard(context, item);
                },
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GRID CARD — same dual-layer design as TemplateRowItem
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGridCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategorySelectionScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffFCE7F3),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Top-right highlight circle
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 75,
                height: 75,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 249, 217, 235),
                ),
              ),
            ),

            // ── Bottom-left darkly tinted softly bubble
            Positioned(
              left: -35,
              bottom: -35,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 249, 217, 235),
                ),
              ),
            ),

            // ── Template image centered
            Center(
              child: Image.asset(
                item['image'] as String,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),

            // ── Ad badge
            if (item['isAd'] == true)
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A3FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NO RESULTS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF2F8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD73ABA).withOpacity(0.15),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.search_status,
                size: 72,
                color: Color(0xFFD73ABA),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No templates found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or\nchoose a different category',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
