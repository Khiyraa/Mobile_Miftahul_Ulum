import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/current_user.dart';

class ReverbService {
  static final ReverbService _instance = ReverbService._internal();
  factory ReverbService() => _instance;
  ReverbService._internal();

  Echo? _echo;
  PusherClient? _pusher;

  // Reverb Config (dari .env Laravel V2)
  final String _appKey = '5e3xxduirsctb4kkd899';
  final String _host =
      kIsWeb ? 'localhost' : '10.0.2.2'; // 10.0.2.2 untuk Android Emulator
  final int _port = 8080;

  Future<void> initialize() async {
    try {
      PusherOptions options = PusherOptions(
        host: _host,
        wsPort: _port,
        wssPort: _port,
        encrypted: false,
        auth: PusherAuth(
          'http://127.0.0.1:8000/broadcasting/auth',
          headers: {
            'Authorization': 'Bearer ${CurrentUser().token}',
            'Accept': 'application/json',
          },
        ),
      );

      _pusher = PusherClient(
        _appKey,
        options,
        autoConnect: true,
        enableLogging: true,
      );

      _echo = Echo(broadcaster: EchoBroadcasterType.Pusher, client: _pusher);

      _pusher!.onConnectionStateChange((state) {
        debugPrint("Connection state: ${state!.currentState}");
      });

      debugPrint("Reverb/Echo Initialized");
    } catch (e) {
      debugPrint("Echo Init Error: $e");
    }
  }

  void listenToChat(int parentId, Function(Map<String, dynamic>) onMessage) {
    _echo?.channel('chat.$parentId').listen('MessageSent', (data) {
      debugPrint("New Message via Reverb: $data");
      // Tergantung format payload di Laravel, biasanya data['message'] atau data
      onMessage(data is Map ? (data['message'] ?? data) : data);
    });
  }

  void disconnect() {
    _pusher?.disconnect();
  }

  Future<bool> sendMessage(int parentId, String pesan) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/chat/$parentId/send-api');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${CurrentUser().token}',
        },
        body: json.encode({'pesan': pesan}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Send Message Error: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(int parentId) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/chat/$parentId/history');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${CurrentUser().token}',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint("Get History Error: $e");
    }
    return [];
  }
}
