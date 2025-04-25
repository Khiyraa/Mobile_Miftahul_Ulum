import 'package:flutter/material.dart';

class ChatAdminScreen extends StatefulWidget {
  const ChatAdminScreen({super.key});

  @override
  State<ChatAdminScreen> createState() => _ChatAdminScreenState();
}

class _ChatAdminScreenState extends State<ChatAdminScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'message': 'Selamat datang, ada yang bisa dibantu?', 'isSender': false},
  ];

  // Jawaban otomatis berdasarkan kata kunci
  final Map<String, String> autoResponses = {
    'jadwal':
        'Jadwal kegiatan bisa dilihat di menu utama atau kalender santri.',
    'nilai': 'Nilai santri tersedia di bagian “Kartu Santri” di halaman utama.',
    'password':
        'Jika lupa password, silakan gunakan fitur “Lupa Password” saat login.',
    'daftar':
        'Pendaftaran bisa dilakukan melalui menu “Pendaftaran” di halaman awal.',
    'izin':
        'Pengajuan izin dapat dilakukan melalui menu “Izin Santri” pada dashboard.',
  };

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    String lowerText = text.toLowerCase();
    String? response;

    for (var keyword in autoResponses.keys) {
      if (lowerText.contains(keyword)) {
        response = autoResponses[keyword];
        break;
      }
    }

    setState(() {
      // Tampilkan pertanyaan dari user
      _messages.add({'message': text, 'isSender': true});

      // Tampilkan balasan admin
      _messages.add({
        'message':
            response ??
            'Maaf, kami belum mengerti pertanyaan Anda. Silakan coba lagi.',
        'isSender': false,
      });

      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat dengan Admin')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final item = _messages[index];
                return Align(
                  alignment:
                      item['isSender']
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: ChatBubble(
                    message: item['message'],
                    isSender: item['isSender'],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pertanyaan...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_controller.text.trim());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;

  const ChatBubble({super.key, required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSender ? Colors.blue[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    );
  }
}
