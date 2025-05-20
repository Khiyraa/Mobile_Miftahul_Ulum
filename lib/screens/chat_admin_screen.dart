import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:mobile_miftahul_ulum/services/ably_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  // Instance of Ably service
  final AblyService _ablyService = AblyService();

  // Subscription for message stream
  StreamSubscription? _messageSubscription;
  StreamSubscription? _adminStatusSubscription;
  StreamSubscription? _connectionSubscription;

  bool _isAdminOnline = false;
  bool _waitingForAdminResponse = false;
  bool _isInitialized = false;

  // Enhanced auto-responses for pesantren (gunakan yang sudah ada)
  final Map<String, String> autoResponses = {
    // Gunakan autoResponses yang sudah ada dalam kode Anda
  };

  // Keywords for better matching (gunakan yang sudah ada)
  final Map<String, List<String>> responseKeywords = {
    // Gunakan responseKeywords yang sudah ada dalam kode Anda
  };

  @override
  void initState() {
    super.initState();
    _initializeAbly();
  }

  Future<void> _initializeAbly() async {
    try {
      // Restore user session if exists
      final session = await _ablyService.restoreUserSession();

      // Initialize Ably connection
      await _ablyService.initialize(
        apiKey:
            'TZaB8g._BT4jQ:8BWttVcvWHL6GTZJGaIve9G90RLZCQXdtBqSfceGEGo', // Ganti dengan API key Ably Anda
        userId: session['userId'].isNotEmpty ? session['userId'] : null,
        userName: session['userName'].isNotEmpty ? session['userName'] : null,
      );

      // Listen for new messages
      _messageSubscription = _ablyService.onMessage.listen(
        _handleIncomingMessage,
      );

      // Listen for admin status changes
      _adminStatusSubscription = _ablyService.onAdminStatusChange.listen((
        isAdminOnline,
      ) {
        setState(() {
          _isAdminOnline = isAdminOnline;
        });
      });

      // Listen for connection status changes
      _connectionSubscription = _ablyService.onConnectionStatusChange.listen((
        isConnected,
      ) {
        setState(() {
          _isInitialized = isConnected;
        });
      });

      // Load message history
      final messages = await _ablyService.getMessageHistory();

      // Only add messages if we have any
      if (messages.isNotEmpty) {
        setState(() {
          _messages.addAll(messages);
        });
      } else {
        // Add welcome message if no history
        setState(() {
          _messages.add({
            'id': 'welcome',
            'message':
                'Assalamualaikum warahmatullahi wabarakatuh\n\nSelamat datang di Layanan Chat Pondok Pesantren Al-Ikhlas. Ada yang bisa kami bantu?',
            'senderId': 'system',
            'senderName': 'Admin Pondok',
            'isAdmin': true,
            'status': 'sent',
            'time': DateTime.now().toIso8601String(),
          });
        });
      }

      // Scroll to bottom after messages are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error initializing Ably: $e');
      // Show error message
      setState(() {
        _messages.add({
          'id': 'error',
          'message':
              'Maaf, terjadi kesalahan saat menghubungkan ke layanan chat. Silakan coba lagi nanti.',
          'senderId': 'system',
          'senderName': 'System',
          'isAdmin': true,
          'status': 'error',
          'time': DateTime.now().toIso8601String(),
        });
      });
    }
  }

  void _handleIncomingMessage(Map<String, dynamic> messageData) {
    setState(() {
      _messages.add(messageData);

      // If this is an admin response, clear waiting state
      if (messageData['isAdmin'] == true) {
        _waitingForAdminResponse = false;
      }
    });

    // Scroll to bottom when new message arrives
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || !_isInitialized) return;

    String lowerText = text.toLowerCase();
    String? autoResponse;
    bool isIzinRequest = false;

    try {
      // First, add the user's message to the UI and send via Ably
      final message = await _ablyService.sendMessage(text);

      setState(() {
        _messages.add(message);
        _controller.clear();
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Check if this is a permission (izin) request
      if (responseKeywords['izin']!.any((word) => lowerText.contains(word))) {
        isIzinRequest = true;
      }

      // If admin is offline, check for auto-responses
      if (!_isAdminOnline) {
        if (isIzinRequest) {
          // If admin is offline, use the offline izin response
          autoResponse = autoResponses['izin_offline'];
        } else {
          // Find matching response for non-izin requests
          for (var key in responseKeywords.keys) {
            if (responseKeywords[key]!.any(
              (word) => lowerText.contains(word),
            )) {
              autoResponse = autoResponses[key];
              break;
            }
          }
        }

        // If we have an auto-response, send it
        if (autoResponse != null) {
          await Future.delayed(const Duration(seconds: 1));

          setState(() {
            _messages.add({
              'id': 'auto-${DateTime.now().millisecondsSinceEpoch}',
              'message': autoResponse!,
              'senderId': 'system',
              'senderName': 'Admin Pondok',
              'isAdmin': true,
              'status': 'sent',
              'time': DateTime.now().toIso8601String(),
            });
          });

          // Scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else if (!isIzinRequest) {
          // For general questions without auto-response when admin is offline
          setState(() {
            _waitingForAdminResponse = true;
            _messages.add({
              'id': 'waiting-${DateTime.now().millisecondsSinceEpoch}',
              'message': '⏳ Pesan Anda telah kami terima. Sedang memproses...',
              'senderId': 'system',
              'senderName': 'System',
              'isAdmin': true,
              'status': 'waiting',
              'time': DateTime.now().toIso8601String(),
            });
          });

          await Future.delayed(const Duration(seconds: 10));

          // Remove waiting message and add offline notice
          setState(() {
            _messages.removeWhere((msg) => msg['status'] == 'waiting');
            _messages.add({
              'id': 'offline-${DateTime.now().millisecondsSinceEpoch}',
              'message':
                  'Mohon maaf, pengurus pondok sedang tidak tersedia.\n\n'
                  'Berikut kontak darurat yang bisa dihubungi:\n'
                  '1. Ustadz Ahmad - 0812-3456-7890\n'
                  '2. Klinik Pondok - 0813-4567-8901\n\n'
                  'Pesan Anda akan dibalas saat pengurus online.',
              'senderId': 'system',
              'senderName': 'Admin Pondok',
              'isAdmin': true,
              'status': 'sent',
              'time': DateTime.now().toIso8601String(),
            });
            _waitingForAdminResponse = false;
          });
        }
      } else if (isIzinRequest) {
        // Izin request when admin is online
        setState(() {
          _waitingForAdminResponse = true;
          _messages.add({
            'id': 'forwarding-${DateTime.now().millisecondsSinceEpoch}',
            'message':
                '⏳ Permintaan izin Anda sedang diteruskan ke pengurus pondok...',
            'senderId': 'system',
            'senderName': 'System',
            'isAdmin': true,
            'status': 'waiting',
            'time': DateTime.now().toIso8601String(),
          });
        });

        await Future.delayed(const Duration(seconds: 5));

        setState(() {
          _messages.removeWhere((msg) => msg['status'] == 'waiting');
          _messages.add({
            'id': 'izin-received-${DateTime.now().millisecondsSinceEpoch}',
            'message':
                'Pengurus pondok telah menerima permintaan izin Anda dan akan segera merespon.\n\n'
                'Untuk konsultasi langsung, silakan hubungi:\n'
                '📞 Ustadz Ahmad - 0812-3456-7890',
            'senderId': 'system',
            'senderName': 'Admin Pondok',
            'isAdmin': true,
            'status': 'sent',
            'time': DateTime.now().toIso8601String(),
          });
          _waitingForAdminResponse = false;
        });
      } else      // For other messages when admin is online
      setState(() {
        _waitingForAdminResponse = true;
      });
    
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        _messages.add({
          'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
          'message': 'Gagal mengirim pesan. Silakan coba lagi.',
          'senderId': 'system',
          'senderName': 'System',
          'isAdmin': false,
          'status': 'error',
          'time': DateTime.now().toIso8601String(),
        });
      });
    }
  }

  // Define our teal color
  final Color tealColor = const Color(0xFF1D7980);

  @override
  Widget build(BuildContext context) {
    // Gunakan implementation build dari kode asli dengan sedikit penyesuaian
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Pondok Pesantren'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tealColor, tealColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                Icon(
                  _isAdminOnline ? Icons.circle : Icons.circle_outlined,
                  color: _isAdminOnline ? Colors.greenAccent : Colors.grey[300],
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _isAdminOnline ? 'Admin Online' : 'Admin Offline',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final item = _messages[index];

                  if (item['status'] == 'waiting') {
                    return _buildLoadingMessage(item);
                  }

                  return _buildChatBubble(item);
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Ketik pesan...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onSubmitted: _sendMessage,
                            enabled: !_waitingForAdminResponse,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          color: tealColor,
                          onPressed: () {
                            setState(() {
                              _messages.add({
                                'id':
                                    'tip-${DateTime.now().millisecondsSinceEpoch}',
                                'message':
                                    '💡 *Tips*: Anda bisa menanyakan tentang:\n'
                                    '- Jadwal kegiatan\n'
                                    '- Informasi nilai\n'
                                    '- Prosedur perizinan\n'
                                    '- Layanan kesehatan\n'
                                    '- Pembayaran SPP\n'
                                    '- Kegiatan pesantren\n'
                                    '- Kontak penting',
                                'senderId': 'system',
                                'senderName': 'Admin Pondok',
                                'isAdmin': true,
                                'status': 'sent',
                                'time': DateTime.now().toIso8601String(),
                              });

                              // Scroll to bottom
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollToBottom();
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors:
                          _waitingForAdminResponse
                              ? [Colors.grey, Colors.grey]
                              : [tealColor, tealColor.withOpacity(0.8)],
                    ),
                  ),
                  child: IconButton(
                    icon:
                        _waitingForAdminResponse
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.send, color: Colors.white),
                    onPressed:
                        _waitingForAdminResponse
                            ? null
                            : () => _sendMessage(_controller.text.trim()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage(Map<String, dynamic> item) {
    // Gunakan implementasi dari kode asli Anda
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(tealColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(item['message'], style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> item) {
    // Modifikasi untuk bekerja dengan format pesan Ably
    final timeFormat = DateFormat('HH:mm');
    final bool isSender = item['senderId'] == _ablyService.userId;
    final bool isAdmin = item['isAdmin'] == true;
    final DateTime messageTime =
        item['time'] is String
            ? DateTime.parse(item['time'])
            : (item['time'] as DateTime);

    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSender ? const Color(0xFFE6F3F3) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isSender ? 12 : 0),
              bottomRight: Radius.circular(isSender ? 0 : 12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: isSender ? tealColor.withOpacity(0.3) : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSender && item['senderName'] != null)
                Text(
                  item['senderName'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? tealColor : Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              Text(
                item['message'],
                style: TextStyle(color: Colors.grey[800], fontSize: 15),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeFormat.format(messageTime),
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                  if (isSender) ...[
                    const SizedBox(width: 4),
                    Icon(
                      item['status'] == 'sent'
                          ? Icons.check
                          : (item['status'] == 'failed'
                              ? Icons.error_outline
                              : Icons.access_time),
                      size: 12,
                      color:
                          item['status'] == 'failed'
                              ? Colors.red
                              : Colors.grey[500],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _adminStatusSubscription?.cancel();
    _connectionSubscription?.cancel();
    _ablyService.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
