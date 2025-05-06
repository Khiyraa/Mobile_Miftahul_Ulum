import 'package:flutter/material.dart';
import 'home_content.dart';
import 'faq_form.dart'; // Import FaqForm
import '../navbar/custom_bottom_navbar.dart';
import '../navbar/nav_item.dart';
import 'chat_admin_screen.dart'; // Import halaman chat admin (pastikan file ini dibuat)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 1; // Mulai dengan Home terpilih

  // Simpan semua halaman dalam variabel agar tidak hilang saat berpindah
  late final Widget _santriPage = const SantriPage();
  late final Widget _homePage = const HomeContent();
  late final Widget _faqPage = const FaqForm(); // Ganti dengan FaqForm

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
        page: _faqPage,
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
        children: [_santriPage, _homePage, _faqPage],
      ),

      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 0),
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
