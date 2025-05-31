import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// ======================= BAGIAN KEDUA: Fungsi Umum =======================

String getBaseUrl() {
  // Karena Anda ingin selalu pakai base URL yang tetap ini, kita override semua kondisi:
  return 'https://webfw23.myhost.id/gol_d1/miftahul-ulum';
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
  final url = Uri.parse(
    'https://webfw23.myhost.id/gol_d1/miftahul-ulum/api/reset-password',
  );

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
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

// ======================= BAGIAN PERTAMA: ApiService & Model =======================

class ApiService {
  // Base URL API yang baru
  static final String baseUrl = 'https://webfw23.myhost.id/gol_d1/miftahul-ulum/api';

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

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        List<dynamic> data;

        if (jsonResponse.containsKey('data')) {
          data = jsonResponse['data'];
        } else if (jsonResponse is List) {
          data = jsonResponse as List<dynamic>;
        } else {
          data = json.decode(response.body) as List<dynamic>;
        }

        print('Data count: ${data.length}'); // Debug log

        return data.map((json) => PengumumanModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Gagal mengambil pengumuman. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getPengumuman: $e'); // Debug log
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
        isi: json['isi'] ?? '',
        kategori: json['kategori'] ?? '',
        tglMulai: _parseDateTime(json['tgl_mulai']),
        tglSelesai: _parseDateTime(json['tgl_selesai']),
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
