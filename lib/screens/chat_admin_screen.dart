import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulum/services/ably_service.dart';
// import 'ably_service.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({Key? key, required this.userId, required this.userName})
    : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AblyService _ablyService = AblyService();

  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  bool _isConnected = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeAbly();
  }

  Future<void> _initializeAbly() async {
    try {
      await _ablyService.initialize(
        apiKey: 'TZaB8g._BT4jQ:8BWttVcvWHL6GTZJGaIve9G90RLZCQXdtBqSfceGEGo',
        userId: widget.userId,
        userName: widget.userName,
        customChannelName: 'pesantren-chat',
      );

      // listen connection status
      _ablyService.onConnectionStatusChange.listen((connected) {
        setState(() {
          _isConnected = connected;
        });
      });

      // listen incoming messages
      _ablyService.onMessage.listen((message) {
        setState(() {
          _messages.add(message);
        });
      });

      // load history messages
      final history = await _ablyService.getMessageHistory();
      setState(() {
        _messages.addAll(history);
      });
    } catch (e) {
      debugPrint('Error initializing Ably: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (!_isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Belum terhubung ke server chat')));
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Kirim pesan ke Ably
      final sentMessage = await _ablyService.sendMessage(text);

      setState(() {
        // Tampilkan pesan yang baru dikirim di list
        _messages.add(sentMessage);
        _messageController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan: $e')));
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _ablyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Pesantren'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _messages.isEmpty
                    ? Center(child: Text('Belum ada pesan'))
                    : ListView.builder(
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[_messages.length - 1 - index];
                        final isMe = message['senderId'] == _ablyService.userId;
                        return ListTile(
                          title: Align(
                            alignment:
                                isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.green[300] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                message['message'] ?? '',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          subtitle: Align(
                            alignment:
                                isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Text(
                              message['senderName'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText:
                            _isConnected
                                ? 'Ketik pesan...'
                                : 'Menghubungkan ke server...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      enabled: _isConnected && !_isSending,
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon:
                        _isSending
                            ? CircularProgressIndicator()
                            : Icon(Icons.send),
                    color: _isConnected ? Colors.green[700] : Colors.grey,
                    onPressed:
                        _isConnected && !_isSending ? _sendMessage : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
