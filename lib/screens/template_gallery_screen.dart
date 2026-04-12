import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../components/gallery/gallery_chip.dart';
import '../components/gallery/template_row.dart';
import '../components/gallery/template_row_item.dart';

class TemplateGalleryScreen extends StatefulWidget {
  const TemplateGalleryScreen({super.key});

  @override
  State<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends State<TemplateGalleryScreen> {
  bool _isSearchExpanded = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Free',
    'Thanks Giving',
    'Christmas',
    'Business',
    'Food',
    'Nature'
  ];

  // Template Data Map with Names for Search
  final Map<String, List<Map<String, dynamic>>> _templateData = {
    'Free': [
      {'name': 'Color Palette', 'icon': Iconsax.color_swatch, 'color': Colors.orange, 'isAd': false},
      {'name': 'Briefcase Logo', 'icon': Iconsax.briefcase, 'color': Colors.brown, 'isAd': false},
      {'name': 'ID Card Design', 'icon': Iconsax.personalcard, 'color': Colors.blue, 'isAd': false},
    ],
    'Thanks Giving': [
      {'name': 'Dinner Logo', 'icon': Icons.restaurant, 'color': Colors.orange, 'isAd': false},
      {'name': 'Autumn Leaf', 'icon': Icons.grass, 'color': Colors.orangeAccent, 'isAd': false},
      {'name': 'Grill Master', 'icon': Icons.outdoor_grill, 'color': Colors.deepOrange, 'isAd': false},
    ],
    'Christmas': [
      {'name': 'Xmas Tree', 'icon': Icons.park, 'color': Colors.green, 'isAd': true},
      {'name': 'Santa Claus', 'icon': Icons.face, 'color': Colors.red, 'isAd': false},
      {'name': 'Gift Box', 'icon': Icons.card_giftcard, 'color': Colors.redAccent, 'isAd': false},
    ],
    'Business': [
      {'name': 'Growth Chart', 'icon': Iconsax.graph, 'color': Colors.blue, 'isAd': false},
      {'name': 'Achievement Award', 'icon': Iconsax.award, 'color': Colors.amber, 'isAd': false},
      {'name': 'Market Status', 'icon': Iconsax.status_up, 'color': Colors.indigo, 'isAd': false},
    ],
    'Food': [
      {'name': 'Pizza Paradise', 'icon': Icons.local_pizza, 'color': Colors.orange, 'isAd': false},
      {'name': 'Burger King', 'icon': Icons.lunch_dining, 'color': Colors.brown, 'isAd': false},
      {'name': 'Pastry Chef', 'icon': Icons.bakery_dining, 'color': Colors.amber, 'isAd': false},
    ],
    'Nature': [
      {'name': 'Eco Green', 'icon': Icons.eco, 'color': Colors.green, 'isAd': false},
      {'name': 'Pink Flower', 'icon': Icons.filter_vintage, 'color': Colors.pink, 'isAd': false},
      {'name': 'Morning Sun', 'icon': Icons.wb_sunny, 'color': Colors.orange, 'isAd': false},
    ],
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = ''; // Clear search when switching categories
      _searchController.clear();
      _isSearchExpanded = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  List<Map<String, dynamic>> _getFilteredTemplates() {
    List<Map<String, dynamic>> allItems = [];
    if (_selectedCategory == 'All') {
      _templateData.values.forEach((list) => allItems.addAll(list));
    } else {
      allItems = _templateData[_selectedCategory] ?? [];
    }

    if (_searchQuery.isEmpty) return allItems;

    return allItems.where((item) {
      final name = (item['name'] as String).toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTemplates = _getFilteredTemplates();
    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Template Gallery',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
            ),

            // Search and Tabs Section
            Container(
              padding: const EdgeInsets.only(left: 16, bottom: 12, right: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Circular Search Icon (Conditional Styling)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearchExpanded = !_isSearchExpanded;
                            if (!_isSearchExpanded) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: _isSearchExpanded
                                ? const LinearGradient(colors: [
                                    Color(0xFFFF2E94),
                                    Color(0xFFC32BAC)
                                  ])
                                : null,
                            color: _isSearchExpanded ? null : Colors.white,
                            shape: BoxShape.circle,
                            border: _isSearchExpanded
                                ? null
                                : Border.all(
                                    color: Colors.black.withOpacity(0.08)),
                            boxShadow: _isSearchExpanded
                                ? [
                                    BoxShadow(
                                        color: const Color(0xFFFF2E94)
                                            .withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _isSearchExpanded
                                ? Icons.search // Search icon when expanded
                                : Iconsax.search_normal,
                            size: 22,
                            color: _isSearchExpanded
                                ? Colors.white
                                : const Color(0xFFC32BAC),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              return GalleryChip(
                                label: cat,
                                isSelected: _selectedCategory == cat,
                                onTap: () => _selectCategory(cat),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Expandable Search Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isSearchExpanded ? 60 : 0,
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.only(top: _isSearchExpanded ? 12 : 0),
                    child: _isSearchExpanded
                        ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search templates...',
                              suffixIcon: const Icon(Iconsax.search_status,
                                  color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Color(0xFFFF2E94)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                    color: const Color(0xFFFF2E94)
                                        .withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Color(0xFFC32BAC), width: 1.5),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Main Content Area
            Expanded(
              child: isSearching || _selectedCategory != 'All'
                  ? _buildGridView(filteredTemplates)
                  : _buildAllView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllView() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: _templateData.entries.map((entry) {
          return TemplateRow(
            title: entry.key,
            onSeeAll: () => _selectCategory(entry.key),
            items: entry.value.map((item) {
              return TemplateRowItem(
                icon: Icon(item['icon'] as IconData,
                    color: item['color'] as Color),
                isAd: item['isAd'] as bool,
                onTap: () {},
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> items) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "X templates found" banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFF2E94), Color(0xFFC32BAC)]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${items.length} templates found',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ],
            ),
          ),

          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Large Styled Search Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F7FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Icon(
                        Iconsax.search_status,
                        size: 80,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No templates found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filters',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
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
                    icon: Icon(item['icon'] as IconData,
                        color: item['color'] as Color),
                    isAd: item['isAd'] as bool,
                    onTap: () {},
                  );
                },
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
