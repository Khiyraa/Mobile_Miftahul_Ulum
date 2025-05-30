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
  bool _isConnecting = true;

  // Simplified - no form needed
  String _parentName = 'Orang Tua Santri';

  // Enhanced auto-responses for pesantren
  final Map<String, String> autoResponses = {
    'greeting':
        'Assalamualaikum warahmatullahi wabarakatuh. Selamat datang di layanan chat Pondok Pesantren Al-Ikhlas. Bagaimana kami bisa membantu Anda?',
    'izin':
        'Baik, permintaan izin Anda akan segera kami proses. Mohon tunggu konfirmasi dari pengurus pondok.',
    'jadwal':
        'Untuk informasi jadwal kegiatan, silakan hubungi bagian akademik di 0812-1234-5678.',
    'kesehatan':
        'Untuk layanan kesehatan darurat, silakan hubungi klinik pondok di 0813-4567-8901.',
    'offline':
        'Mohon maaf, pengurus pondok sedang tidak tersedia. Pesan Anda akan dibalas saat pengurus online.',
  };

  // Keywords for better matching
  final Map<String, List<String>> responseKeywords = {
    'greeting': [
      'halo',
      'hai',
      'assalamualaikum',
      'selamat',
      'pagi',
      'siang',
      'malam',
    ],
    'izin': ['izin', 'ijin', 'permisi', 'pulang', 'sakit', 'keperluan'],
    'jadwal': ['jadwal', 'kegiatan', 'acara', 'waktu'],
    'kesehatan': ['sakit', 'demam', 'obat', 'dokter', 'klinik', 'kesehatan'],
  };

  @override
  void initState() {
    super.initState();
    _initializeDirectly();
  }

  // Simplified initialization - directly use session ID 1
  Future<void> _initializeDirectly() async {
    try {
      setState(() {
        _isConnecting = true;
      });

      print('[ChatScreen] Starting direct initialization...');

      // Set session ID langsung (session yang sudah ada di server)
      await _ablyService.initializeSessionDirect(
        sessionId: 1, // Menggunakan session ID yang sudah ada
        parentName: _parentName,
      );

      await _initializeAbly();
    } catch (e) {
      print('[ChatScreen] Error in direct initialization: $e');
      setState(() {
        _isConnecting = false;
        _isInitialized = false;
      });

      _showErrorMessage('Error initialization: $e');
    }
  }

  Future<void> _initializeAbly() async {
    try {
      print('[ChatScreen] Starting Ably initialization...');

      // Initialize Ably connection with proper API key
      await _ablyService.initialize(
        apiKey: 'TZaB8g._BT4jQ:8BWttVcvWHL6GTZJGaIve9G90RLZCQXdtBqSfceGEGo',
        userId: null, // Let service generate
        userName: _parentName,
      );

      print('[ChatScreen] Ably initialized, setting up subscriptions...');

      // Listen for new messages
      _messageSubscription = _ablyService.onMessage.listen(
        _handleIncomingMessage,
        onError: (error) {
          print('[ChatScreen] Message subscription error: $error');
        },
      );

      // Listen for admin status changes
      _adminStatusSubscription = _ablyService.onAdminStatusChange.listen(
        (isAdminOnline) {
          print('[ChatScreen] Admin status changed: $isAdminOnline');
          setState(() {
            _isAdminOnline = isAdminOnline;
          });
        },
        onError: (error) {
          print('[ChatScreen] Admin status subscription error: $error');
        },
      );

      // Listen for connection status changes
      _connectionSubscription = _ablyService.onConnectionStatusChange.listen(
        (isConnected) {
          print('[ChatScreen] Connection status changed: $isConnected');
          setState(() {
            _isInitialized = isConnected;
            _isConnecting = !isConnected;
          });

          // Load content only when connected
          if (isConnected) {
            _loadInitialContent();
          }
        },
        onError: (error) {
          print('[ChatScreen] Connection subscription error: $error');
        },
      );

      print('[ChatScreen] All subscriptions set up successfully');
    } catch (e) {
      print('[ChatScreen] Error initializing Ably: $e');
      setState(() {
        _isConnecting = false;
        _isInitialized = false;
      });

      _showErrorMessage('Error connecting to chat service: $e');
    }
  }

  // Load initial content
  Future<void> _loadInitialContent() async {
    try {
      print('[ChatScreen] Loading message history...');

      // Load from database API
      final messages = await _ablyService.getMessageHistory();

      if (messages.isNotEmpty) {
        print('[ChatScreen] Loaded ${messages.length} messages from history');
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });
      } else {
        // Welcome message
        print('[ChatScreen] No history found, adding welcome message');
        setState(() {
          _messages.clear();
          _messages.add({
            'id': 'welcome',
            'message':
                'Assalamualaikum warahmatullahi wabarakatuh\n\nSelamat datang di Layanan Chat Pondok Pesantren Al-Ikhlas.\n\nAda yang bisa kami bantu?',
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
      print('[ChatScreen] Error loading initial content: $e');
      _showErrorMessage('Error loading chat history: $e');
    }
  }

  void _handleIncomingMessage(Map<String, dynamic> messageData) {
    print('[ChatScreen] Received incoming message: $messageData');

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
    if (text.trim().isEmpty || !_isInitialized) {
      print('[ChatScreen] Cannot send message - empty text or not initialized');
      return;
    }

    String lowerText = text.toLowerCase();
    String? autoResponse;

    try {
      print('[ChatScreen] Sending message: $text');

      // Add the user's message to the UI and send via Ably
      final message = await _ablyService.sendMessage(text);

      setState(() {
        _messages.add(message);
        _controller.clear();
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Auto-response logic when admin is offline
      if (!_isAdminOnline) {
        // Find matching response
        for (var key in responseKeywords.keys) {
          if (responseKeywords[key]!.any((word) => lowerText.contains(word))) {
            autoResponse = autoResponses[key];
            break;
          }
        }

        // If no specific response found, use offline message
        autoResponse ??= autoResponses['offline'];

        // Send auto-response after delay
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
      } else {
        // Admin is online, set waiting state
        setState(() {
          _waitingForAdminResponse = true;
        });
      }
    } catch (e) {
      print('[ChatScreen] Error sending message: $e');
      _showErrorMessage('Failed to send message: $e');
    }
  }

  void _showErrorMessage(String errorText) {
    setState(() {
      _messages.add({
        'id': 'error-${DateTime.now().millisecondsSinceEpoch}',
        'message':
            '$errorText\n\nSilakan coba lagi atau hubungi:\n📞 Ustadz Ahmad: 0812-3456-7890',
        'senderId': 'system',
        'senderName': 'System',
        'isAdmin': true,
        'status': 'error',
        'time': DateTime.now().toIso8601String(),
      });
      _waitingForAdminResponse = false;
    });
  }

  // Define our teal color
  final Color tealColor = const Color(0xFF1D7980);

  @override
  Widget build(BuildContext context) {
    // Show loading screen while connecting
    if (_isConnecting) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: tealColor),
              const SizedBox(height: 16),
              const Text(
                'Menghubungkan ke server chat...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

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
                  _isInitialized
                      ? (_isAdminOnline ? Icons.circle : Icons.circle_outlined)
                      : Icons.wifi_off,
                  color:
                      _isInitialized
                          ? (_isAdminOnline
                              ? Colors.greenAccent
                              : Colors.grey[300])
                          : Colors.red[300],
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _isInitialized
                      ? (_isAdminOnline ? 'Admin Online' : 'Admin Offline')
                      : 'Tidak Terhubung',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          if (!_isInitialized)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange[100],
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[800], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Koneksi tidak stabil. Mencoba menyambung ulang...',
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _initializeAbly(),
                    child: Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final item = _messages[index];
                  return _buildChatBubble(item);
                },
              ),
            ),
          ),

          // Message input
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
                            enabled:
                                !_waitingForAdminResponse && _isInitialized,
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
                          (_waitingForAdminResponse || !_isInitialized)
                              ? [Colors.grey, Colors.grey]
                              : [tealColor, tealColor.withOpacity(0.8)],
                    ),
                  ),
                  child: IconButton(
                    icon:
                        (_waitingForAdminResponse || !_isInitialized)
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
                        (_waitingForAdminResponse || !_isInitialized)
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

  Widget _buildChatBubble(Map<String, dynamic> item) {
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
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
    print('[ChatScreen] Disposing resources...');
    _messageSubscription?.cancel();
    _adminStatusSubscription?.cancel();
    _connectionSubscription?.cancel();
    _ablyService.disconnect();
    _ablyService.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
