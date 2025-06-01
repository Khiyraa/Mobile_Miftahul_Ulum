import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulum/screens/jadwal_shalat_page.dart';
import 'home_content.dart';
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
  late final CurrentUser _currentUser = CurrentUser();

  late final Widget _jadwalShalatPage = const JadwalShalatPage();
  late final Widget _homePage = const HomeContent();
  late final Widget _faqPage = const FaqForm();

  late final List<NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _initializeUserData();

    _navItems = [
      NavItem(
        label: 'Santri',
        icon: Icons.calendar_today,
        page: const JadwalShalatPage(),
      ),
      NavItem(label: 'Home', icon: Icons.home, page: _homePage),
      NavItem(
        label: 'Pengumuman',
        icon: Icons.chat_bubble_outline,
        page: _faqPage,
      ),
    ];
  }

  Future<void> _initializeUserData() async {
    await _currentUser.initFromSharedPrefs();
    
    // Untuk debug, tampilkan data user yang sudah diload
    debugPrint('User Data:');
    debugPrint('isLoggedIn: ${_currentUser.isLoggedIn}');
    debugPrint('token: ${_currentUser.token}');
    debugPrint('idAkun: ${_currentUser.idAkun}');
    debugPrint('email: ${_currentUser.email}');
    debugPrint('username: ${_currentUser.username}');
    debugPrint('hakAkses: ${_currentUser.hakAkses}');
  }

  Future<void> _logout() async {
  await _currentUser.clearUserData();
  
  if (!mounted) return;
  Navigator.pushReplacementNamed(context, '/login');
}

  void _navigate(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Santri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentPage,
        children: [_jadwalShalatPage, _homePage, _faqPage],
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