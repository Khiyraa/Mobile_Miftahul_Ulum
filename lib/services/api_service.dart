import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// ======================= BAGIAN KEDUA: Fungsi Umum =======================

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000/api';
  } else {
    return 'http://10.0.2.2:8000/api';
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
    return {'success': false, 'message': 'Terjadi kesalahan: $e'};
  }
}

// API untuk mengirim link reset password - DIPERBAIKI ENDPOINT NYA
Future<Map<String, dynamic>> sendResetLinkAPI(String email) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse(
    '$baseUrl/api/forgot-password',
  ); // UBAH DARI send-reset-link KE forgot-password

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email}),
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
    return {'success': false, 'message': 'Terjadi kesalahan: $e'};
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
        'message':
            responseData['message'] ??
            responseData['error'] ??
            'Gagal reset password',
        'errors': responseData['errors'] ?? {},
      };
    }
  } catch (e) {
    print('Verify Reset Password Error: $e');
    return {'success': false, 'message': 'Terjadi kesalahan: $e'};
  }
}

// ======================= BAGIAN PERTAMA: ApiService & Model =======================

class ApiService {
  // Base URL API yang baru (Local Laravel V2)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  // Singleton pattern untuk memastikan hanya ada satu instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers default untuk request
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Method untuk mengambil data pengumuman
  Future<List<PengumumanModel>> getPengumuman() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengumuman'),
        headers: _headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((json) => PengumumanModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Gagal mengambil pengumuman. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getPengumuman: $e');
      throw Exception('Error: $e');
    }
  }
}

class PengumumanModel {
  final int id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime tglMulai;
  final DateTime tglSelesai;
  final String? foto;
  final int idAkun;
  final DateTime createdAt;
  final DateTime updatedAt;

  PengumumanModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.tglMulai,
    required this.tglSelesai,
    this.foto,
    required this.idAkun,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PengumumanModel.fromJson(Map<String, dynamic> json) {
    try {
      return PengumumanModel(
        id: json['id'] ?? 0,
        judul: json['judul'] ?? '',
        isi: json['konten'] ?? '',
        kategori: json['kategori'] ?? '',
        tglMulai: _parseDateTime(json['published_at']),
        tglSelesai: _parseDateTime(json['published_at']),
        foto: json['foto'],
        idAkun: json['id_akun'] ?? 0,
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
      );
    } catch (e) {
      print('Error parsing PengumumanModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('Error parsing date: $dateValue');
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'kategori': kategori,
      'tgl_mulai': tglMulai.toIso8601String(),
      'tgl_selesai': tglSelesai.toIso8601String(),
      'foto': foto,
      'id_akun': idAkun,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${(difference.inDays / 7).floor()} minggu yang lalu';
    }
  }

  String get prioritas {
    if (kategori.toLowerCase() == 'administrasi') return 'tinggi';
    if (kategori.toLowerCase() == 'akademik') return 'tinggi';
    return 'sedang';
  }

  IconData get icon {
    switch (kategori.toLowerCase()) {
      case 'akademik':
        return Icons.school;
      case 'administrasi':
        return Icons.payment;
      case 'kegiatan':
        return Icons.event;
      default:
        return Icons.announcement;
    }
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(tglMulai.subtract(const Duration(days: 1))) &&
        now.isBefore(tglSelesai.add(const Duration(days: 1)));
  }
}

extension PengumumanModelExtension on PengumumanModel {
  String get fotoUrl {
    if (foto == null || foto!.isEmpty) {
      print('Foto kosong, pakai placeholder');
      return 'https://via.placeholder.com/150';
    }
    // Ganti base URL storage juga
    final url = 'https://webfw23.myhost.id/gol_d1/miftahul-ulum/storage/$foto';
    print('URL foto: $url');
    return url;
  }
}
