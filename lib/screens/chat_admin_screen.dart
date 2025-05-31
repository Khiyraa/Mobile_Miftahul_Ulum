import 'package:flutter/material.dart';
import '../services/ably_service.dart';

class ChatScreen extends StatefulWidget {
  final int idSession;
  final int pengirim;

  const ChatScreen({
    Key? key,
    required this.idSession,
    required this.pengirim,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AblyService _ablyService = AblyService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    await _ablyService.initialize();

    // Load existing messages dari backend
    final msgs = await _ablyService.getMessages(widget.idSession);
    setState(() {
      _messages = msgs;
      _isLoading = false;
    });

    // Listen pesan realtime dari Ably
    _ablyService.listenToMessages((message, pengirim) {
      // Asumsikan setiap pesan punya id_session dan filter di backend sudah dilakukan
      // Jika ingin filter di sini, bisa tambahkan logika filter

      setState(() {
        _messages.add({
          'pesan': message,
          'pengirim': pengirim,
          'created_at': DateTime.now().toIso8601String(),
        });
      });

      // Scroll ke bawah otomatis saat pesan baru datang
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Kirim pesan lewat AblyService
    await _ablyService.sendMessage(
      idSession: widget.idSession,
      pesan: text,
      pengirim: widget.pengirim.toString(),
    );

    // Tambah pesan lokal supaya user langsung lihat (optional, bisa juga menunggu Ably push)
    setState(() {
      _messages.add({
        'pesan': text,
        'pengirim': widget.pengirim.toString(),
        'created_at': DateTime.now().toIso8601String(),
      });
      _controller.clear();
    });

    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final bool isMine = message['pengirim'].toString() == widget.pengirim.toString();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMine ? Colors.teal : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message['pesan'],
          style: TextStyle(color: isMine ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Pengurus Pondok'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageItem(message);
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    onPressed: _sendMessage,
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
