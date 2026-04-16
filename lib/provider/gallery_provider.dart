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
      {
        'name': 'Color Palette',
        'image': 'assets/gallery_images/Text.png',
        'isAd': false
      },
      {
        'name': 'Briefcase Logo',
        'image': 'assets/gallery_images/bag.png',
        'isAd': false
      },
      {
        'name': 'Rocket Logo',
        'image': 'assets/gallery_images/airoplain.png',
        'isAd': false
      },
      {
        'name': 'Bulb Logo',
        'image': 'assets/gallery_images/bulb.png',
        'isAd': false
      },
      {
        'name': 'Target Logo',
        'image': 'assets/gallery_images/dart.png',
        'isAd': false
      },
      {
        'name': 'Crown Logo',
        'image': 'assets/gallery_images/king.png',
        'isAd': false
      },
    ],
    'Thanks Giving': [
      {
        'name': 'Turkey Logo',
        'image': 'assets/gallery_images/hen.png',
        'isAd': false
      },
      {
        'name': 'Pie',
        'image': 'assets/gallery_images/coock.png',
        'isAd': false
      },
      {
        'name': 'Corn',
        'image': 'assets/gallery_images/cons.png',
        'isAd': false
      },
      {
        'name': 'Leaves',
        'image': 'assets/gallery_images/leaf.png',
        'isAd': false
      },
    ],
    'Christmas': [
      {
        'name': 'Eco Green',
        'image': 'assets/gallery_images/Text (1).png',
        'isAd': false
      },
      {
        'name': 'Santa Claus',
        'image': 'assets/gallery_images/baba.png',
        'isAd': false
      },
      {
        'name': 'Gift Box',
        'image': 'assets/gallery_images/gift.png',
        'isAd': false
      },
      {
        'name': 'Snowman',
        'image': 'assets/gallery_images/c.png',
        'isAd': false
      },
      {'name': 'Bell', 'image': 'assets/gallery_images/bul.png', 'isAd': false},
      {
        'name': 'Star',
        'image': 'assets/gallery_images/atars.png',
        'isAd': false
      },
    ],
    'Business': [
      {
        'name': 'Bar Chart',
        'image': 'assets/gallery_images/graph.png',
        'isAd': false
      },
      {
        'name': 'Achievement',
        'image': 'assets/gallery_images/cup.png',
        'isAd': false
      },
      {
        'name': 'Growth Chart',
        'image': 'assets/gallery_images/line.png',
        'isAd': false
      },
    ],
    'Food': [
      {
        'name': 'Pizza Paradise',
        'image': 'assets/gallery_images/piza.png',
        'isAd': false
      },
      {
        'name': 'Burger King',
        'image': 'assets/gallery_images/berger.png',
        'isAd': false
      },
      {
        'name': 'Meat Leg',
        'image': 'assets/gallery_images/Text (4).png',
        'isAd': false
      },
    ],
    'Nature': [
      {
        'name': 'Pink Flower',
        'image': 'assets/gallery_images/Text (2).png',
        'isAd': false
      },
      {
        'name': 'Xmas Tree',
        'image': 'assets/gallery_images/Text (3).png',
        'isAd': true
      },
      {
        'name': 'Wave',
        'image': 'assets/gallery_images/water.png',
        'isAd': false
      },
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
