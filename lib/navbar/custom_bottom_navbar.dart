// widgets/custom_bottom_navbar.dart
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'nav_item.dart';

class CustomBottomNavBar extends StatefulWidget {
  final List<NavItem> items;
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    if (widget.items.length != 3) {
      throw Exception('CustomBottomNavBar membutuhkan tepat 3 NavItems');
    }

    return CurvedNavigationBar(
      height: 55, // Tinggi bar
      backgroundColor: Colors.transparent, // Warna background
      color: Color(0xFF0B6E77), // Warna bar
      animationDuration: Duration(milliseconds: 300),
      onTap: (index) {
        widget.onTap(index);
      },
      index: widget.currentIndex,
      items: [
        // Item Kalender (Kiri)
        Icon(Icons.calendar_today, color: Colors.white),
        // Item Home (Tengah)
        Icon(Icons.home, color: Colors.white),
        // Item Chat (Kanan)
        Icon(Icons.chat_bubble, color: Colors.white),
      ],
    );
  }
}
