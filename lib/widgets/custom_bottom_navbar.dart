import 'package:flutter/material.dart';
import '../models/nav_item.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<NavItem> items;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items.map((item) => _buildItem(item)).toList(),
    );
  }

  BottomNavigationBarItem _buildItem(NavItem item) {
    return BottomNavigationBarItem(icon: Icon(item.icon), label: item.label);
  }
}
