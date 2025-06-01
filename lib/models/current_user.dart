// models/current_user.dart
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUser {
  int? idAkun;
  String? email;
  String? username;
  String? hakAkses;
  String? token;
  bool isLoggedIn = false;

  // Private constructor
  CurrentUser._internal();

  // Singleton instance
  static final CurrentUser _instance = CurrentUser._internal();

  // Factory constructor to return the same instance
  factory CurrentUser() => _instance;

  // Initialize user data from SharedPreferences
  Future<void> initFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      token = prefs.getString('token');
      idAkun = prefs.getInt('id_akun');
      email = prefs.getString('email');
      username = prefs.getString('username');
      hakAkses = prefs.getString('hak_akses');
    }
  }

  // Update user data after login
  Future<void> setUserData({
    required String newToken,
    required int newIdAkun,
    required String newEmail,
    required String newUsername,
    required String newHakAkses,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('token', newToken);
    await prefs.setInt('id_akun', newIdAkun);
    await prefs.setString('email', newEmail);
    await prefs.setString('username', newUsername);
    await prefs.setString('hak_akses', newHakAkses);

    // Update current instance
    token = newToken;
    idAkun = newIdAkun;
    email = newEmail;
    username = newUsername;
    hakAkses = newHakAkses;
    isLoggedIn = true;
  }

  // Clear user data on logout
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('isLoggedIn');
    await prefs.remove('token');
    await prefs.remove('id_akun');
    await prefs.remove('email');
    await prefs.remove('username');
    await prefs.remove('hak_akses');

    // Clear current instance
    token = null;
    idAkun = null;
    email = null;
    username = null;
    hakAkses = null;
    isLoggedIn = false;
  }
}