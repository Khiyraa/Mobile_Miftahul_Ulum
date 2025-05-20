import 'dart:async';
import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AblyService {
  static final AblyService _instance = AblyService._internal();
  factory AblyService() => _instance;
  AblyService._internal();

  late ably.Realtime _realtime;
  late ably.RealtimeChannel _channel;
  final String _channelName = 'pesantren-chat'; // Default channel
  final _uuid = Uuid();
  bool _isConnected = false;
  String _userId = '';
  String _userName = '';

  // Controllers for streaming data
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _adminStatusController = StreamController<bool>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;
  Stream<bool> get onAdminStatusChange => _adminStatusController.stream;
  Stream<bool> get onConnectionStatusChange =>
      _connectionStatusController.stream;

  // Getters for properties
  bool get isConnected => _isConnected;
  String get userId => _userId;
  String get userName => _userName;

  // Initialize the Ably service
  Future<void> initialize({
    required String apiKey,
    String? userId,
    String? userName,
    String? customChannelName,
  }) async {
    // Store user details
    _userId = userId ?? 'mobile-user-${_uuid.v4()}';
    _userName = userName ?? 'Orang Tua Santri';

    // Initialize client options
    final clientOptions = ably.ClientOptions(
      key: apiKey,
      clientId: _userId,
      echoMessages: false,
    );

    // Create realtime instance
    _realtime = ably.Realtime(options: clientOptions);

    // Listen for connection state changes
    _realtime.connection.on().listen((ably.ConnectionStateChange stateChange) {
      _isConnected = stateChange.current == ably.ConnectionState.connected;
      _connectionStatusController.add(_isConnected);

      if (_isConnected) {
        // When connected, join presence
        _enterPresence();
      }
    });

    // Get channel instance
    final channelName = customChannelName ?? _channelName;
    _channel = _realtime.channels.get(channelName);

    // Subscribe to messages
    _subscribeToMessages();

    // Subscribe to presence events to detect admin status
    _subscribeToPresence();

    // Connect to Ably
    await _realtime.connect();

    // Save user session
    _saveUserSession();
  }

  // Store user session
  Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _userId);
    await prefs.setString('user_name', _userName);
  }

  // Restore user session (can be called before initialize)
  Future<Map<String, dynamic>> restoreUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? '';
    _userName = prefs.getString('user_name') ?? '';

    return {'userId': _userId, 'userName': _userName};
  }

  // Subscribe to channel messages
  void _subscribeToMessages() {
    _channel.subscribe().listen((ably.Message message) {
      final data = message.data as Map<String, dynamic>;

      // Only process messages not from self
      if (data['senderId'] != _userId) {
        // Add received message to stream
        _messageController.add(data);
      }
    });
  }

  // Subscribe to presence events to detect admin status
  void _subscribeToPresence() {
    _channel.presence.subscribe().listen((ably.PresenceMessage message) {
      _updateAdminStatus();
    });
  }

  // Update admin online status
  Future<void> _updateAdminStatus() async {
    try {
      final presenceList = await _channel.presence.get();
      final adminOnline = presenceList.any((member) {
        final data = member.data as Map<String, dynamic>?;
        return data != null &&
            data['isAdmin'] == true &&
            data['status'] == 'online';
      });

      _adminStatusController.add(adminOnline);
    } catch (e) {
      print('Error updating admin status: $e');
    }
  }

  // Enter presence
  Future<void> _enterPresence() async {
    final data = {
      'userId': _userId,
      'userName': _userName,
      'isAdmin': false, // Mobile users are never admins
      'status': 'online',
      'lastSeen': DateTime.now().toIso8601String(),
      'platform': 'mobile',
    };

    try {
      await _channel.presence.enter(data);
      // Check admin status after entering
      _updateAdminStatus();
    } catch (e) {
      print('Error entering presence: $e');
    }
  }

  // Update status
  Future<void> updateStatus({String status = 'online'}) async {
    if (!_isConnected) return;

    final data = {
      'userId': _userId,
      'userName': _userName,
      'isAdmin': false,
      'status': status,
      'lastSeen': DateTime.now().toIso8601String(),
      'platform': 'mobile',
    };

    try {
      await _channel.presence.update(data);
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // Send a message
  Future<Map<String, dynamic>> sendMessage(String text) async {
    if (!_isConnected) {
      throw Exception('Not connected to Ably');
    }

    final messageId = _uuid.v4();
    final timestamp = DateTime.now();

    final message = {
      'id': messageId,
      'message': text,
      'senderId': _userId,
      'senderName': _userName,
      'isAdmin': false,
      'status': 'sent',
      'time': timestamp.toIso8601String(),
      'platform': 'mobile',
    };

    try {
      await _channel.publish(name: 'chat_message', data: message);
      return message;
    } catch (e) {
      print('Error sending message: $e');
      return {...message, 'status': 'failed'};
    }
  }

  // Load message history
  Future<List<Map<String, dynamic>>> getMessageHistory() async {
    try {
      final history = await _channel.history();
      final historyMessages =
          history.items.map((message) {
            final data = message.data as Map<String, dynamic>;
            return data;
          }).toList();

      // Sort messages by time
      historyMessages.sort((a, b) {
        final timeA = DateTime.parse(a['time'] as String);
        final timeB = DateTime.parse(b['time'] as String);
        return timeA.compareTo(timeB);
      });

      return historyMessages;
    } catch (e) {
      print('Error getting message history: $e');
      return [];
    }
  }

  // Disconnect from Ably
  Future<void> disconnect() async {
    try {
      await updateStatus(status: 'offline');
      await _channel.presence.leave();
      await _realtime.close();
      _isConnected = false;
      _connectionStatusController.add(false);
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _messageController.close();
    _adminStatusController.close();
    _connectionStatusController.close();
  }
}
