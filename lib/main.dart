import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulum/models/current_user.dart';
import 'package:mobile_miftahul_ulum/screens/login_screen.dart';
import 'package:mobile_miftahul_ulum/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CurrentUser().initFromSharedPrefs();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miftahul Ulum',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: CurrentUser().isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}