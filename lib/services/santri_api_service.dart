import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/santri.dart';
import 'package:universal_io/io.dart';

class ApiService {
  static String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Khusus Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000'; // Untuk iOS simulator
    } else {
      return 'http://192.168.1.8:8000/api'; // Untuk Web / Desktop
    }
  }

  static final String baseUrl = '${getBaseUrl()}/api';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get all santri
  static Future<ApiResponse<List<Santri>>> getAllSantri() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/santri'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'];
          List<Santri> santriList =
              data.map((json) => Santri.fromJson(json)).toList();

          return ApiResponse<List<Santri>>(
            success: true,
            message: jsonData['message'],
            data: santriList,
          );
        } else {
          return ApiResponse<List<Santri>>(
            success: false,
            message: jsonData['message'] ?? 'Gagal mengambil data',
          );
        }
      } else {
        return ApiResponse<List<Santri>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<Santri>>(
        success: false,
        message: 'Network Error: $e',
      );
    }
  }

  // Get santri by ID
  static Future<ApiResponse<Santri>> getSantriById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/santri/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          Santri santri = Santri.fromJson(jsonData['data']);

          return ApiResponse<Santri>(
            success: true,
            message: jsonData['message'],
            data: santri,
          );
        } else {
          return ApiResponse<Santri>(
            success: false,
            message: jsonData['message'] ?? 'Santri tidak ditemukan',
          );
        }
      } else if (response.statusCode == 404) {
        return ApiResponse<Santri>(
          success: false,
          message: 'Santri tidak ditemukan',
        );
      } else {
        return ApiResponse<Santri>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Santri>(success: false, message: 'Network Error: $e');
    }
  }

  // Get santri by orang tua ID
  static Future<ApiResponse<List<Santri>>> getSantriByOrtuId(int idOrtu) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/santri/ortu/$idOrtu'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'];
          List<Santri> santriList =
              data.map((json) => Santri.fromJson(json)).toList();

          return ApiResponse<List<Santri>>(
            success: true,
            message: jsonData['message'],
            data: santriList,
          );
        } else {
          return ApiResponse<List<Santri>>(
            success: false,
            message: jsonData['message'] ?? 'Gagal mengambil data',
          );
        }
      } else {
        return ApiResponse<List<Santri>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<Santri>>(
        success: false,
        message: 'Network Error: $e',
      );
    }
  }
}

// Response wrapper class
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }
}
