import 'package:flutter/material.dart';
import 'dart:async';

class ChatMessage {
  final String text;
  final bool isAdmin;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isAdmin,
    required this.timestamp,
  });
}

class AdminChatPage extends StatefulWidget {
  const AdminChatPage({super.key});

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  Timer? _typingTimer;
  bool _isAdminTyping = false;

  @override
  void initState() {
    super.initState();

    // Pesan selamat datang otomatis
    _addMessage(
      "Selamat datang di layanan chat PMI. Ada yang bisa kami bantu?",
      true,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
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

  void _addMessage(String text, bool isAdmin) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isAdmin: isAdmin, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _simulateAdminTyping() {
    setState(() => _isAdminTyping = true);

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      String response =
          "Terima kasih atas pertanyaannya. Kami akan segera memproses informasi Anda.";

      // Logika sederhana untuk auto-reply
      final userMessage = _messageController.text.toLowerCase();
      if (userMessage.contains('donor')) {
        response =
            "Untuk informasi donor darah, silakan kunjungi halaman utama aplikasi atau hubungi PMI terdekat.";
      } else if (userMessage.contains('stok') ||
          userMessage.contains('darah')) {
        response =
            "Stok darah dapat dilihat di halaman utama aplikasi. Untuk informasi lebih lanjut silakan hubungi PMI.";
      } else if (userMessage.contains('terima kasih')) {
        response = "Sama-sama. Semoga informasinya membantu!";
      }

      setState(() => _isAdminTyping = false);
      _addMessage(response, true);
    });
  }

  void _handleSendMessage() {
    final text = _messageController.text;
    _addMessage(text, false);
    _messageController.clear();
    _simulateAdminTyping();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: const Text('Chat dengan Admin PMI'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _messages.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Mulai chat dengan admin',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isAdminTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Tampilkan indikator "Admin sedang mengetik..."
                          if (_isAdminTyping && index == _messages.length) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.red,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Admin sedang mengetik...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final message = _messages[index];
                          final time =
                              "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}";

                          return Align(
                            alignment:
                                message.isAdmin
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    message.isAdmin
                                        ? Colors.grey.shade200
                                        : Colors.red.shade700,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      color:
                                          message.isAdmin
                                              ? Colors.black87
                                              : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          message.isAdmin
                                              ? Colors.black54
                                              : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _handleSendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
