import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  } else {
    return 'http://127.0.0.1:8000';
  }
}

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse('$baseUrl/api/login');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return responseData;
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Login gagal',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Terjadi kesalahan: $e',
    };
  }
}

// API untuk mengirim link reset password - DIPERBAIKI ENDPOINT NYA
Future<Map<String, dynamic>> sendResetLinkAPI(String email) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse('$baseUrl/api/forgot-password'); // UBAH DARI send-reset-link KE forgot-password
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );
    
    print('Send Reset Link Response Status: ${response.statusCode}');
    print('Send Reset Link Response Body: ${response.body}');
    
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Link reset berhasil dikirim',
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Gagal mengirim link reset',
      };
    }
  } catch (e) {
    print('Send Reset Link Error: $e');
    return {
      'success': false,
      'message': 'Terjadi kesalahan: $e',
    };
  }
}

// API untuk verifikasi dan reset password dengan token
Future<Map<String, dynamic>> verifyResetPasswordAPI(
  String email,
  String token,
  String newPassword,
) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse('$baseUrl/api/reset-password');
  
  try {
    final requestBody = {
      'email': email,
      'token': token,
      'password': newPassword,
      'password_confirmation': newPassword,
    };
    
    print('Verify Reset Password Request: $requestBody');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    
    print('Verify Reset Password Response Status: ${response.statusCode}');
    print('Verify Reset Password Response Body: ${response.body}');
    
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Password berhasil direset',
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? responseData['error'] ?? 'Gagal reset password',
        'errors': responseData['errors'] ?? {},
      };
    }
  } catch (e) {
    print('Verify Reset Password Error: $e');
    return {
      'success': false,
      'message': 'Terjadi kesalahan: $e',
    };
  }
}