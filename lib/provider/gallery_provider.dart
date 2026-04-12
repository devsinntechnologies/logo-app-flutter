import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class GalleryProvider extends ChangeNotifier {
  bool _isSearchExpanded = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  bool get isSearchExpanded => _isSearchExpanded;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  final List<String> categories = [
    'All',
    'Free',
    'Thanks Giving',
    'Christmas',
    'Business',
    'Food',
    'Nature'
  ];

  final Map<String, List<Map<String, dynamic>>> templateData = {
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

  void toggleSearchExpanded() {
    _isSearchExpanded = !_isSearchExpanded;
    if (!_isSearchExpanded) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _searchQuery = '';
    _isSearchExpanded = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  List<Map<String, dynamic>> getFilteredTemplates() {
    List<Map<String, dynamic>> allItems = [];
    if (_selectedCategory == 'All') {
      templateData.values.forEach((list) => allItems.addAll(list));
    } else {
      allItems = templateData[_selectedCategory] ?? [];
    }

    if (_searchQuery.isEmpty) return allItems;

    return allItems.where((item) {
      final name = (item['name'] as String).toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
