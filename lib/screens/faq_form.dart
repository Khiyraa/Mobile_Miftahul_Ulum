import 'package:flutter/material.dart';
import 'chat_admin_screen.dart'; // Import halaman chat

class FaqForm extends StatelessWidget {
  const FaqForm({super.key});

  @override
  Widget build(BuildContext context) {
    final faqList = [
      {
        'question': 'Bagaimana cara mendaftar?',
        'answer': 'Silakan ke menu pendaftaran dan isi data lengkap.',
      },
      {
        'question': 'Bagaimana melihat nilai disiplin?',
        'answer':
            'Nilai disiplin bisa dilihat di halaman utama dalam kartu Disiplin.',
      },
      {
        'question': 'Apa yang harus dilakukan jika lupa password?',
        'answer': 'Gunakan fitur lupa password atau hubungi admin.',
      },
    ];

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = faqList[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['question']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(item['answer']!),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatAdminScreen()),
          );
        },
        label: const Text('Customer Service'),
        icon: const Icon(Icons.support_agent),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
