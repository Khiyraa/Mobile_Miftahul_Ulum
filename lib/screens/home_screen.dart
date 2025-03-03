import 'package:flutter/material.dart';
import 'home_content.dart';
import '../navbar/custom_bottom_navbar.dart';
import '../navbar/nav_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 1; // Mulai dengan Home terpilih

  // Simpan semua halaman dalam variabel agar tidak hilang saat berpindah
  late final Widget _santriPage = SantriPage();
  late final Widget _homePage = HomeContent();
  late final Widget _announcementPage = AnnouncementPage();

  // Bangun NavItems menggunakan halaman yang sudah dibuat
  late final List<NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = [
      NavItem(label: 'Santri', icon: Icons.calendar_today, page: _santriPage),
      NavItem(label: 'Home', icon: Icons.home, page: _homePage),
      NavItem(
        label: 'Pengumuman',
        icon: Icons.chat_bubble_outline,
        page: _announcementPage,
      ),
    ];
  }

  void _navigate(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Santri')),
      body: IndexedStack(
        index: _currentPage,
        children: [_santriPage, _homePage, _announcementPage],
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: CustomBottomNavBar(
          currentIndex: _currentPage,
          items: _navItems,
          onTap: _navigate,
        ),
      ),
    );
  }
}

// Halaman dummy untuk navigasi
class SantriPage extends StatelessWidget {
  const SantriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Jadwal Adzan'));
  }
}

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman FAQ dan chat admin'));
  }
}
