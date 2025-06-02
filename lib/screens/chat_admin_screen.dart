import 'package:flutter/material.dart';
import '../services/ably_service.dart';
import '../models/current_user.dart';

class ChatScreen extends StatefulWidget {
  final int idStaf;
  final int idOrtu;
  final String role; // 'staf' atau 'orang_tua'

  const ChatScreen({
    super.key,
    required this.idStaf,
    required this.idOrtu,
    required this.role,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AblyService _ablyService = AblyService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  int? _sessionId;

  @override
  void initState() {
    super.initState();

    final token = CurrentUser().token; // token dari login/session

    _initChat(token!);
  }

  Future<void> _initChat(String token) async {
    await _ablyService.initialize();

    final sessionId = await _ablyService.getOrCreateSession(
      idStaf: widget.idStaf,
      idOrtu: widget.idOrtu,
      token: token, // kirim token ke sini
    );

    if (sessionId == null) {
      // Tangani error, misal show dialog atau snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal membuat sesi chat.')));
      return;
    }

    _sessionId = sessionId;

    final msgs = await _ablyService.getMessages(sessionId);
    setState(() {
      _messages = msgs;
      _isLoading = false;
    });

    _ablyService.listenToMessages((message, pengirim) {
      setState(() {
        _messages.add({
          'pesan': message,
          'pengirim': pengirim,
          'created_at': DateTime.now().toIso8601String(),
        });
      });

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
    if (text.isEmpty || _sessionId == null) return;

    try {
      await _ablyService.sendMessage(
        idSession: _sessionId!,
        pesan: text,
        pengirim: widget.role,
      );

      setState(() {
        _messages.add({
          'pesan': text,
          'pengirim': widget.role,
          'created_at': DateTime.now().toIso8601String(),
        });
        _controller.clear();
      });

      _scrollToBottom();
    } catch (e) {
      // Tambahkan penanganan error agar user tahu jika gagal mengirim pesan
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan: $e')));
    }
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final bool isMine = message['pengirim'] == widget.role;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
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
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Pengurus Pondok')),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
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
