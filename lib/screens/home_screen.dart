import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulum/screens/jadwal_shalat_page.dart';
import 'home_content.dart';
import 'faq_form.dart'; // Import FaqForm
import '../navbar/custom_bottom_navbar.dart';
import '../navbar/nav_item.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 1;

  late final Widget _jadwalShalatPage = const JadwalShalatPage();
  late final Widget _homePage = const HomeContent();

  Future<Map<String, dynamic>>? _akunFuture;

  @override
  void initState() {
    super.initState();
    _akunFuture = _loadUserData();
  }

  Future<Map<String, dynamic>> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan, user belum login');
    }

    final userData = await fetchUserData(token);
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _akunFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final akun = snapshot.data!;
        final faqPage = FaqForm(
          userId: akun['id_akun'].toString(),
          userName: akun['username'],
        );

        final navItems = [
          NavItem(label: 'Santri', icon: Icons.calendar_today, page: _jadwalShalatPage),
          NavItem(label: 'Home', icon: Icons.home, page: _homePage),
          NavItem(label: 'Pengumuman', icon: Icons.chat_bubble_outline, page: faqPage),
        ];

        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard Santri')),
          body: IndexedStack(
            index: _currentPage,
            children: [_jadwalShalatPage, _homePage, faqPage],
          ),
          extendBody: true,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: CustomBottomNavBar(
              currentIndex: _currentPage,
              items: navItems,
              onTap: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
        );
      },
    );
  }
}
