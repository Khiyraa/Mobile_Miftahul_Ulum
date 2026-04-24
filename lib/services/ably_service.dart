import 'dart:convert';
import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/current_user.dart';

class AblyService {
  static final AblyService _instance = AblyService._internal();
  factory AblyService() => _instance;
  AblyService._internal();

  late ably.Realtime realtime;
  late ably.RealtimeChannel channel;

  final String _baseUrl = 'http://localhost:8000/api';

  // Inisialisasi Ably dan channel
  Future<void> initialize() async {
    realtime = ably.Realtime(
      options: ably.ClientOptions(
        key: 'TZaB8g._BT4jQ:8BWttVcvWHL6GTZJGaIve9G90RLZCQXdtBqSfceGEGo',
      ),
    );
    channel = realtime.channels.get('pesantren-chat');
  }

  // Dengarkan pesan baru
  void listenToMessages(
    Function(String message, String pengirim) onMessageReceived,
  ) {
    // Jangan panggil subscribe('chat'), cukup subscribe() tanpa parameter
    channel.subscribe().listen((ably.Message message) {
      if (message.name == 'chat') {
        // filter pesan dengan nama event 'chat'
        final data = json.decode(message.data as String);
        onMessageReceived(data['pesan'], data['pengirim']);
      }
    });
  }

  // Kirim pesan ke server Laravel
  Future<void> sendMessage({
    required int idSession,
    required String pesan,
    required String pengirim,
  }) async {
    final url = Uri.parse('$_baseUrl/send-message');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // pastikan server balas JSON
        'Authorization': 'Bearer ${CurrentUser().token}', // token auth
      },
      body: json.encode({
        'id_session': idSession,
        'pesan': pesan,
        'pengirim': pengirim,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Pesan berhasil dikirim');
    } else {
      debugPrint('Gagal kirim pesan: ${response.body}');
    }
  }

  // Ambil semua pesan dalam satu session
  Future<List<Map<String, dynamic>>> getMessages(int idSession) async {
    final url = Uri.parse('$_baseUrl/session/$idSession');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${CurrentUser().token}'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      debugPrint('Gagal ambil pesan: ${response.body}');
      return [];
    }
  }

  Future<int?> getOrCreateSession({
    required int idStaf,
    required int idOrtu,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/get-or-create-session');

    final payload = {'id_staf': idStaf, 'id_ortu': idOrtu};

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept':
            'application/json', // 🟢 Tambahkan ini agar Laravel balas JSON!
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    debugPrint(
      'Session API Response: ${response.statusCode} - ${response.body}',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id_session'];
    } else {
      return null;
    }
  }

  // Ambil info user dari session
  Future<Map<String, dynamic>?> getUserInfo(int idSession) async {
    final url = Uri.parse('$_baseUrl/user-info/$idSession');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${CurrentUser().token}'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      debugPrint('Gagal ambil user info: ${response.body}');
      return null;
    }
  }
}
