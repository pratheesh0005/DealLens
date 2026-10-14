import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/search_provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

/// Main navigation scaffold with bottom navigation bar.
class DealLensNavigationScreen extends StatefulWidget {
  const DealLensNavigationScreen({super.key});

  @override
  State<DealLensNavigationScreen> createState() =>
      _DealLensNavigationScreenState();
}

class _DealLensNavigationScreenState extends State<DealLensNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onSearchTap: () => setState(() => _currentIndex = 1),
        onCategorySelect: (title) {
          final catalog = context.read<ProductsProvider>().allProducts;
          context.read<SearchProvider>().filterByCategory(title, catalog);
          setState(() => _currentIndex = 1);
        },
      ),
      const SearchScreen(),
      const WishlistScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
