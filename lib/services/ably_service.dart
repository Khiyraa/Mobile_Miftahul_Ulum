import 'dart:async';
import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AblyService {
  static final AblyService _instance = AblyService._internal();
  factory AblyService() => _instance;
  AblyService._internal();

  late ably.Realtime _realtime;
  late ably.RealtimeChannel _channel;
  final String _channelName = 'pesantren-chat'; // Same as website
  final _uuid = Uuid();
  bool _isConnected = false;
  String _userId = '';
  String _userName = '';
  int _sessionId = 0; // Changed to int to match database bigint
  final String _baseUrl =
      'https://webfw23.myhost.id/gol_d1/miftahul-ulum'; // Updated URL

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
  int get sessionId => _sessionId;

  // 🔥 NEW METHOD: Initialize session directly with existing session ID
  Future<void> initializeSessionDirect({
    required int sessionId,
    required String parentName,
  }) async {
    _sessionId = sessionId;
    _userName = parentName;
    _userId = 'parent-$sessionId';

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('session_id', _sessionId);
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_id', _userId);

    debugPrint('[AblyService] Direct session set: $_sessionId');
    debugPrint('[AblyService] User: $_userName ($_userId)');
  }

  // Initialize the Ably service
  Future<void> initialize({
    required String apiKey,
    String? userId,
    String? userName,
  }) async {
    debugPrint('[AblyService] Initializing Ably...');
    debugPrint('[AblyService] Using API Key: ${apiKey.substring(0, 10)}...');

    // Store user details (use existing if already set by initializeSessionDirect)
    if (_userId.isEmpty) {
      _userId = userId ?? 'mobile-user-${_uuid.v4()}';
    }
    if (_userName.isEmpty) {
      _userName = userName ?? 'Orang Tua Santri';
    }

    // Initialize client options
    final clientOptions = ably.ClientOptions(key: apiKey, echoMessages: false);

    // Create realtime instance
    _realtime = ably.Realtime(options: clientOptions);

    // Listen for connection state changes
    _realtime.connection.on().listen((ably.ConnectionStateChange stateChange) {
      debugPrint('[AblyService] Connection state: ${stateChange.current}');
      _isConnected = stateChange.current == ably.ConnectionState.connected;
      _connectionStatusController.add(_isConnected);

      if (_isConnected) {
        debugPrint('[AblyService] Connected successfully!');
        // When connected, join presence
        _enterPresence();
      } else {
        debugPrint('[AblyService] Connection failed or disconnected');
      }
    });

    // Get channel instance (same channel as website)
    _channel = _realtime.channels.get(_channelName);

    // Subscribe to messages with specific event name (same as website)
    _subscribeToMessages();

    // Subscribe to presence events to detect admin status
    _subscribeToPresence();

    try {
      // Connect to Ably
      await _realtime.connect();

      // Save user session
      await _saveUserSession();

      debugPrint('[AblyService] Ably initialized successfully');
      debugPrint('[AblyService] Session ID: $_sessionId');
      debugPrint('[AblyService] Channel: ${_channel.name}');
    } catch (e) {
      debugPrint('[AblyService] Error during initialization: $e');
      rethrow;
    }
  }

  // Store user session
  Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _userId);
    await prefs.setString('user_name', _userName);
    await prefs.setInt('session_id', _sessionId);
  }

  // Restore user session (can be called before initialize)
  Future<Map<String, dynamic>> restoreUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('user_id') ?? '';
    final savedUserName = prefs.getString('user_name') ?? '';
    final savedSessionId = prefs.getInt('session_id') ?? 0;

    // Only restore if we don't already have values set
    if (_userId.isEmpty) _userId = savedUserId;
    if (_userName.isEmpty) _userName = savedUserName;
    if (_sessionId == 0) _sessionId = savedSessionId;

    debugPrint(
      '[AblyService] Restored session: $_sessionId, $_userName, $_userId',
    );

    return {'userId': _userId, 'userName': _userName, 'sessionId': _sessionId};
  }

  // Subscribe to channel messages with specific event name (same as website)
  void _subscribeToMessages() {
    // Listen to 'new-message' event specifically (same as website)
    _channel
        .subscribe(name: 'new-message')
        .listen((ably.Message message) {
          debugPrint('[AblyService] Received message: ${message.data}');

          final dataRaw = message.data;
          if (dataRaw is Map) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(
              dataRaw,
            );

            // Only process messages for this session and not from self (orang_tua)
            if (data['id_session'] == _sessionId &&
                data['pengirim'] != 'orang_tua') {
              debugPrint(
                '[AblyService] Processing message for session: $_sessionId',
              );

              // Convert website format to mobile format
              final convertedMessage = {
                'id': 'remote-${DateTime.now().millisecondsSinceEpoch}',
                'message': data['pesan'] ?? '',
                'senderId': 'admin',
                'senderName': 'Admin Pesantren',
                'isAdmin': true,
                'status': 'received',
                'time': data['waktu'] ?? DateTime.now().toIso8601String(),
                'pengirim': data['pengirim'],
                'id_session': data['id_session'],
              };

              // Add received message to stream
              _messageController.add(convertedMessage);
            } else {
              debugPrint(
                '[AblyService] Ignoring message: session=${data['id_session']} (mine=$_sessionId), sender=${data['pengirim']}',
              );
            }
          }
        })
        .onError((error) {
          debugPrint('[AblyService] Message subscription error: $error');
        });
  }

  // Subscribe to presence events to detect admin status
  void _subscribeToPresence() {
    _channel.presence
        .subscribe()
        .listen((ably.PresenceMessage message) {
          debugPrint(
            '[AblyService] Presence event: ${message.action} - ${message.data}',
          );
          _updateAdminStatus();
        })
        .onError((error) {
          debugPrint('[AblyService] Presence subscription error: $error');
        });
  }

  // Update admin online status
  Future<void> _updateAdminStatus() async {
    try {
      final presenceList = await _channel.presence.get();
      final adminOnline = presenceList.any((member) {
        final dataRaw = member.data;
        if (dataRaw is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(dataRaw);
          return data['isAdmin'] == true && data['status'] == 'online';
        }
        return false;
      });

      debugPrint('[AblyService] Admin online status: $adminOnline');
      _adminStatusController.add(adminOnline);
    } catch (e) {
      debugPrint('[AblyService] Error updating admin status: $e');
    }
  }

  // Enter presence (for parent users)
  Future<void> _enterPresence() async {
    final data = {
      'userId': _userId,
      'userName': _userName,
      'sessionId': _sessionId,
      'isAdmin': false, // Parents are never admins
      'status': 'online',
      'lastSeen': DateTime.now().toIso8601String(),
      'platform': 'mobile',
      'userType': 'orang_tua',
    };

    try {
      await _channel.presence.enter(data);
      debugPrint('[AblyService] Entered presence successfully');
      // Check admin status after entering
      _updateAdminStatus();
    } catch (e) {
      debugPrint('[AblyService] Error entering presence: $e');
    }
  }

  // Update status
  Future<void> updateStatus({String status = 'online'}) async {
    if (!_isConnected) {
      debugPrint('[AblyService] Cannot update status - not connected');
      return;
    }

    final data = {
      'userId': _userId,
      'userName': _userName,
      'sessionId': _sessionId,
      'isAdmin': false,
      'status': status,
      'lastSeen': DateTime.now().toIso8601String(),
      'platform': 'mobile',
      'userType': 'orang_tua',
    };

    try {
      await _channel.presence.update(data);
      debugPrint('[AblyService] Status updated to: $status');
    } catch (e) {
      debugPrint('[AblyService] Error updating status: $e');
    }
  }

  // Send a message (using exact website format for database)
  Future<Map<String, dynamic>> sendMessage(String message) async {
    if (_userId.isEmpty || _userName.isEmpty || _sessionId == 0) {
      debugPrint('[AblyService] Error: Required fields are empty');
      debugPrint(
        '[AblyService] userId: $_userId, userName: $_userName, sessionId: $_sessionId',
      );
      throw Exception('User not properly initialized');
    }

    if (!_isConnected) {
      debugPrint('[AblyService] Error: Not connected to Ably');
      throw Exception('Not connected to Ably');
    }

    try {
      debugPrint(
        '[AblyService] Sending message as $_userName ($_userId) in session $_sessionId',
      );

      // Use exact same format as website backend for database compatibility
      final messageData = {
        'id_session': _sessionId, // int to match database bigint
        'pengirim': 'orang_tua', // enum value matches database
        'pesan': message, // text field
        'waktu': DateTime.now().toIso8601String(), // timestamp format
        // Additional fields for debugging (not saved to database)
        'senderId': _userId,
        'senderName': _userName,
        'platform': 'mobile',
      };

      // Publish with same event name as website
      await _channel.publish(
        name: 'new-message', // Same as website
        data: messageData,
      );

      debugPrint('[AblyService] Message sent successfully to Ably');

      // Also save to database via API for immediate consistency
      await _saveMessageToDatabase(message);

      // Return message in mobile format for local display
      return {
        'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'message': message,
        'senderId': _userId,
        'senderName': _userName,
        'isAdmin': false,
        'status': 'sent',
        'time': DateTime.now().toIso8601String(),
        'pengirim': 'orang_tua',
        'id_session': _sessionId,
      };
    } catch (e) {
      debugPrint('[AblyService] Error sending message: $e');
      rethrow;
    }
  }

  // 🔥 FIXED: Save message to database via Laravel API
  Future<void> _saveMessageToDatabase(String message) async {
    try {
      debugPrint('[AblyService] Saving message to database...');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Note: CSRF token might not be needed for API routes
        },
        body: jsonEncode({
          'id_session': _sessionId,
          'pengirim': 'orang_tua',
          'pesan': message,
        }),
      );

      debugPrint(
        '[AblyService] Database save response: ${response.statusCode}',
      );
      debugPrint('[AblyService] Database save body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('[AblyService] Message saved to database successfully');
      } else {
        debugPrint(
          '[AblyService] Failed to save to database: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[AblyService] Error saving to database: $e');
      // Don't throw error here, message was sent via Ably successfully
    }
  }

  // Load message history from Laravel API
  Future<List<Map<String, dynamic>>> getMessageHistory() async {
    try {
      debugPrint(
        '[AblyService] Loading message history for session: $_sessionId',
      );

      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/session/$_sessionId'),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('[AblyService] History response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        debugPrint('[AblyService] History body: $responseBody');

        final List<dynamic> messages = jsonDecode(responseBody);

        final historyMessages =
            messages.map((msg) {
              // Convert database format to mobile format
              return {
                'id': 'history-${msg['id_message']}',
                'message': msg['pesan'] ?? '',
                'senderId': msg['pengirim'] == 'orang_tua' ? _userId : 'admin',
                'senderName':
                    msg['pengirim'] == 'orang_tua'
                        ? _userName
                        : 'Admin Pesantren',
                'isAdmin': msg['pengirim'] != 'orang_tua',
                'status': 'delivered',
                'time': msg['waktu'] ?? DateTime.now().toIso8601String(),
                'pengirim': msg['pengirim'],
                'id_session': msg['id_session'],
              };
            }).toList();

        // Sort messages by time
        historyMessages.sort((a, b) {
          final timeA = DateTime.tryParse(a['time'] ?? '') ?? DateTime(1970);
          final timeB = DateTime.tryParse(b['time'] ?? '') ?? DateTime(1970);
          return timeA.compareTo(timeB);
        });

        debugPrint(
          '[AblyService] Loaded ${historyMessages.length} messages from database',
        );
        return historyMessages;
      } else {
        debugPrint(
          '[AblyService] Failed to load history: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('[AblyService] Error loading message history: $e');
      return [];
    }
  }

  // Create session via Laravel API (kept for compatibility)
  Future<int> createChatSession({
    required String parentName,
    required String studentNames,
    required String region,
  }) async {
    try {
      debugPrint('[AblyService] Creating chat session via API...');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat/create-session'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama_orang_tua': parentName,
          'wali_dari': studentNames,
          'asal_daerah': region,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final sessionId = data['session_id'] as int;
        debugPrint('[AblyService] Session created successfully: $sessionId');
        return sessionId;
      } else {
        debugPrint(
          '[AblyService] Failed to create session: ${response.statusCode}',
        );
        throw Exception('Failed to create session: ${response.body}');
      }
    } catch (e) {
      debugPrint('[AblyService] Error creating session: $e');
      // Fallback: create local session ID if API fails
      final fallbackId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      debugPrint('[AblyService] Using fallback session ID: $fallbackId');
      return fallbackId;
    }
  }

  // Create or get session ID for parent (kept for compatibility)
  Future<void> initializeSession({
    required String parentName,
    required String studentNames,
    required String region,
  }) async {
    try {
      // Check if we already have a session
      final prefs = await SharedPreferences.getInstance();
      int? existingSessionId = prefs.getInt('session_id');

      if (existingSessionId == null || existingSessionId == 0) {
        // Create new session via API
        _sessionId = await createChatSession(
          parentName: parentName,
          studentNames: studentNames,
          region: region,
        );

        await prefs.setInt('session_id', _sessionId);
        await prefs.setString('parent_name', parentName);
        await prefs.setString('student_names', studentNames);
        await prefs.setString('region', region);

        debugPrint('[AblyService] Created new session: $_sessionId');
      } else {
        _sessionId = existingSessionId;
        debugPrint('[AblyService] Using existing session: $_sessionId');
      }

      _userName = parentName;
    } catch (e) {
      debugPrint('[AblyService] Error initializing session: $e');
      rethrow;
    }
  }

  // Get session info from database
  Future<Map<String, dynamic>?> getSessionInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/user-info/$_sessionId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint(
          '[AblyService] Failed to get session info: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[AblyService] Error getting session info: $e');
    }
    return null;
  }

  // Disconnect from Ably
  Future<void> disconnect() async {
    try {
      debugPrint('[AblyService] Disconnecting...');
      if (_isConnected) {
        await updateStatus(status: 'offline');
        await _channel.presence.leave();
        await _realtime.close();
      }
      _isConnected = false;
      _connectionStatusController.add(false);
      debugPrint('[AblyService] Disconnected successfully');
    } catch (e) {
      debugPrint('[AblyService] Error disconnecting: $e');
    }
  }

  // Dispose resources
  void dispose() {
    debugPrint('[AblyService] Disposing resources...');
    _messageController.close();
    _adminStatusController.close();
    _connectionStatusController.close();
  }

  // Method to check connection status
  Future<bool> checkConnection() async {
    try {
      final state = _realtime.connection.state;
      final isConnected = state == ably.ConnectionState.connected;
      debugPrint(
        '[AblyService] Connection check - State: $state, Connected: $isConnected',
      );
      return isConnected;
    } catch (e) {
      debugPrint('[AblyService] Error checking connection: $e');
      return false;
    }
  }

  // Method to retry connection
  Future<void> retryConnection() async {
    try {
      debugPrint('[AblyService] Retrying connection...');
      await _realtime.connect();
    } catch (e) {
      debugPrint('[AblyService] Error retrying connection: $e');
      rethrow;
    }
  }

  // Clear session (for testing or logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('parent_name');
    await prefs.remove('student_names');
    await prefs.remove('region');

    _sessionId = 0;
    _userId = '';
    _userName = '';

    debugPrint('[AblyService] Session cleared');
  }
}
