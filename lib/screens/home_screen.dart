import 'package:flutter/material.dart';
import 'home_content.dart';
import 'faq_form.dart'; // Import FaqForm
import '../navbar/custom_bottom_navbar.dart';
import '../navbar/nav_item.dart';
<<<<<<< HEAD
import 'chat_admin_screen.dart'; // Import halaman chat admin (pastikan file ini dibuat)
=======
import '../screens/jadwal_shalat_page.dart';
>>>>>>> 1fe5283264d92dfe0002d6d1bd56b3263338260b

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 1; // Mulai dengan Home terpilih

  // Simpan semua halaman dalam variabel agar tidak hilang saat berpindah
<<<<<<< HEAD
  late final Widget _santriPage = const SantriPage();
  late final Widget _homePage = const HomeContent();
  late final Widget _faqPage = const FaqForm(); // Ganti dengan FaqForm
=======
  late final Widget _jadwalShalatPage = JadwalShalatPage();
  late final Widget _homePage = HomeContent();
  late final Widget _announcementPage = AnnouncementPage();
>>>>>>> 1fe5283264d92dfe0002d6d1bd56b3263338260b

  // Bangun NavItems menggunakan halaman yang sudah dibuat
  late final List<NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = [
      NavItem(label: 'Santri', icon: Icons.calendar_today, page: _jadwalShalatPage),
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
      appBar: _currentPage == 1 // Hanya tampil di HomeContent
          ? AppBar(title: const Text('Dashboard Santri'))
          : null, // AppBar tidak muncul di halaman lain
      body: IndexedStack(
        index: _currentPage,
<<<<<<< HEAD
        children: [_santriPage, _homePage, _faqPage],
=======
        children: [_jadwalShalatPage, _homePage, _announcementPage],
>>>>>>> 1fe5283264d92dfe0002d6d1bd56b3263338260b
      ),
      floatingActionButton:
          _currentPage ==
                  2 // Jika halaman FAQ
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatAdminScreen()),
                  );
                },
                label: const Text('Customer Service'),
                icon: const Icon(Icons.support_agent),
                backgroundColor: Colors.blueAccent,
              )
              : null,
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


<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Jadwal Adzan'));
=======
// Halaman dummy untuk navigasi
// class SantriPage extends StatelessWidget {
//   const SantriPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Jadwal Adzan'));
//   }
// }

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman FAQ dan chat admin'));
>>>>>>> 1fe5283264d92dfe0002d6d1bd56b3263338260b
  }
}
