import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logo_app_flutter/provider/gallery_provider.dart';
import 'package:logo_app_flutter/screens/business_info_screen.dart';
import 'package:logo_app_flutter/components/gallery/gallery_chip.dart';
import 'package:logo_app_flutter/components/gallery/template_row.dart';
import 'package:logo_app_flutter/components/gallery/template_row_item.dart';
import 'package:provider/provider.dart';

class TemplateGalleryScreen extends StatelessWidget {
  const TemplateGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        final filteredTemplates = provider.getFilteredTemplates();
        final isSearching = provider.searchQuery.isNotEmpty;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Search and Tabs Section
                _buildSearchAndFilters(context, provider),

                const Divider(height: 1),

                // Main Content Area
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFFFF2E94), Color(0xFFC32BAC)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Template Gallery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Choose your design style',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, GalleryProvider provider) {
    return Container(
      padding: const EdgeInsets.only(left: 16, bottom: 12, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => provider.toggleSearchExpanded(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: provider.isSearchExpanded
                        ? const LinearGradient(colors: [Color(0xFFFF2E94), Color(0xFFC32BAC)])
                        : null,
                    color: provider.isSearchExpanded ? null : Colors.white,
                    shape: BoxShape.circle,
                    border: provider.isSearchExpanded
                        ? null
                        : Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: provider.isSearchExpanded
                        ? [BoxShadow(color: const Color(0xFFFF2E94).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                        : null,
                  ),
                  child: Icon(
                    provider.isSearchExpanded ? Icons.search : Iconsax.search_normal,
                    size: 22,
                    color: provider.isSearchExpanded ? Colors.white : const Color(0xFFC32BAC),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: provider.isSearchExpanded ? 60 : 0,
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(top: provider.isSearchExpanded ? 12 : 0),
            child: provider.isSearchExpanded
                ? TextField(
                    controller: provider.searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search templates...',
                      suffixIcon: const Icon(Iconsax.search_status, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFFFF2E94)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: const Color(0xFFFF2E94).withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFFC32BAC), width: 1.5),
                      ),
                    ),
                    onChanged: (val) => provider.updateSearchQuery(val),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildAllView(BuildContext context, GalleryProvider provider) {
    return SingleChildScrollView(
      controller: provider.scrollController,
      child: Column(
        children: provider.templateData.entries.map((entry) {
          return TemplateRow(
            title: entry.key,
            onSeeAll: () => provider.selectCategory(entry.key),
            items: entry.value.map((item) {
              return TemplateRowItem(
                icon: Icon(item['icon'] as IconData, color: item['color'] as Color),
                isAd: item['isAd'] as bool,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessInfoScreen(
                        categoryName: item['name'] ?? 'Custom',
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, GalleryProvider provider, List<Map<String, dynamic>> items) {
    return SingleChildScrollView(
      controller: provider.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF2E94), Color(0xFFC32BAC)]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${items.length} templates found',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
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
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return TemplateRowItem(
                    icon: Icon(item['icon'] as IconData, color: item['color'] as Color),
                    isAd: item['isAd'] as bool,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessInfoScreen(
                            categoryName: item['name'] ?? 'Custom',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7FF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: const Icon(Iconsax.search_status, size: 80, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No templates found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
