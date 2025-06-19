import 'package:flutter/material.dart';
import 'package:avd_assets/Screens/AddProductPage.dart';
import 'package:avd_assets/Screens/Settings.dart';
import 'package:avd_assets/Screens/homepage.dart';
import 'package:avd_assets/model/colors.dart';
import 'package:get/get.dart';
import 'package:avd_assets/controller/product_controller.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put<productController>(productController());

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swipe navigation
        children: [
          HomePage(),
          ProductInputScreen(),
          Settings(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary1,
            Color.lerp(primary1, secondary2, 0.7)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: cardColor,
        unselectedItemColor: Colors.white,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        elevation: 0,
        items: [
          _buildNavItem(Icons.home, 0, 'Home'),
          _buildNavItem(Icons.add_circle_outline, 1, 'Add Product'),
          _buildNavItem(Icons.settings_outlined, 2, 'Settings'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index, String label) {
    return BottomNavigationBarItem(
      icon: _buildAnimatedIcon(icon, index),
      label: label,
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => onTabTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: isSelected ? 34 : 28,
          color: isSelected ? primary1 : Colors.white,
        ),
      ),
    );
  }
}
