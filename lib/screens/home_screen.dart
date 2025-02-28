import 'package:flutter/material.dart';
import 'home_content.dart'; // Import HomeContent
import '../widgets/custom_bottom_navbar.dart';
import '../models/nav_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;

  final List<NavItem> _navItems = const [
    NavItem(label: 'Santri', icon: Icons.people, page: SantriPage()),
    NavItem(
      label: 'Home',
      icon: Icons.home,
      page: HomeContent(), // Sekarang sudah bisa diakses
    ),

    NavItem(
      label: 'Pengumuman',
      icon: Icons.announcement,
      page: AnnouncementPage(),
    ),
  ];

  void _navigate(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Santri')),
      body: _navItems[_currentPage].page,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentPage,
        items: _navItems,
        onTap: _navigate,
      ),
    );
  }
}

// ... (HomeContent, SantriPage, AnnouncementPage tetap sama seperti sebelumnya)
// Halaman dummy untuk navigasi
class SantriPage extends StatelessWidget {
  const SantriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman Data Santri'));
  }
}

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman Pengumuman'));
  }
}
