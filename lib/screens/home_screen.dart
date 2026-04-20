import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_content.dart';
import 'jadwal_shalat_page.dart';
import 'faq_form.dart';
import '../navbar/custom_bottom_navbar.dart';
import '../navbar/nav_item.dart';
import '../models/current_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 1;
  final CurrentUser _currentUser = CurrentUser();

  late final List<NavItem> _navItems = [
    NavItem(
      label: 'Jadwal',
      icon: Icons.access_time_filled_rounded,
      page: const JadwalShalatPage(),
    ),
    NavItem(
      label: 'Beranda',
      icon: Icons.home_rounded,
      page: const HomeContent(),
    ),
    NavItem(
      label: 'Bantuan',
      icon: Icons.help_center_rounded,
      page: const FaqForm(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentUser.initFromSharedPrefs();
  }

  Future<void> _logout() async {
    await _currentUser.clearUserData();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text(
          'Miftahul Ulum',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentPage,
        children: _navItems.map((e) => e.page).toList(),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentPage,
        items: _navItems,
        onTap: (index) => setState(() => _currentPage = index),
      ),
    );
  }
}
