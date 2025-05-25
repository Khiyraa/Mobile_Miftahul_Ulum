// services/api.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:http/http.dart' as http;

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000'; // Web akses langsung ke localhost
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000'; // Emulator Android harus pakai IP ini
  } else {
    return 'http://127.0.0.1:8000'; // iOS simulator atau lainnya
  }
}

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse('$baseUrl/api/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Login gagal: ${response.body}');
  }
}

Future<Map<String, dynamic>> resetPasswordAPI(
  String email,
  String newPassword,
) async {
  final response = await http.post(
    Uri.parse(
      'http://127.0.0.1:8000/api/reset-password',
    ), // ganti jika pakai IP device
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'new_password': newPassword,
      'new_password_confirmation': newPassword, // tambahkan ini
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {
      'success': false,
      'message': jsonDecode(response.body)['message'] ?? 'Gagal reset password',
    };
  }
}
