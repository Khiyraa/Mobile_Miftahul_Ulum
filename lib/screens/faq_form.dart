import 'package:flutter/material.dart';
import 'chat_admin_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/current_user.dart';
import '../services/ably_service.dart';

class FaqForm extends StatefulWidget {
  const FaqForm({super.key});

  @override
  State<FaqForm> createState() => _FaqFormState();
}

class _FaqFormState extends State<FaqForm> {
  String selectedCategory = 'Semua';
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  late final CurrentUser _currentUser = CurrentUser();
  late final AblyService _ablyService = AblyService();

  final Map<String, List<Map<String, dynamic>>> faqData = {
    'Umum': [
      {
        'question': 'Bagaimana cara mengganti password serta username ?',
        'answer': 'Untuk lebih lanjut silakan hubungi pengurus pondok .',
        'icon': Icons.person,
      },
      {
        'question': 'Bagaimana memantau kedisiplinan anak?',
        'answer': 'Masuk ke halaman Dashboard untuk melihat data kedisiplinan.',
        'icon': Icons.bar_chart,
      },
      {
        'question': 'Bagaimana cara melihat pengumuman dari pondok?',
        'answer':
            'Pengumuman akan tampil di Dashboard aplikasi secara berkala.',
        'icon': Icons.announcement,
      },
      {
        'question': 'Apakah saya bisa bertanya langsung ke pengurus?',
        'answer':
            'Ya, gunakan fitur Chat untuk berkomunikasi langsung dengan pengurus pondok.',
        'icon': Icons.chat,
      },
    ],
    'Teknis': [
      {
        'question': 'Aplikasi tidak bisa dibuka, apa yang harus saya lakukan?',
        'answer': 'Coba restart HP atau perbarui aplikasi ke versi terbaru.',
        'icon': Icons.warning,
      },
      {
        'question': 'Bagaimana jika saya tidak menerima notifikasi?',
        'answer':
            'Pastikan izin notifikasi untuk aplikasi ini sudah aktif di pengaturan HP Anda.',
        'icon': Icons.notifications,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await _currentUser.initFromSharedPrefs();
    debugPrint('FAQ Form - Current User Data:');
    debugPrint('akunId: ${_currentUser.idAkun}');
    debugPrint('token: ${_currentUser.token}');
  }

  List<Map<String, dynamic>> getVisibleFaqs() {
    if (selectedCategory == 'Semua') {
      List<Map<String, dynamic>> allFaqs = [];
      faqData.forEach((_, faqs) {
        allFaqs.addAll(faqs);
      });
      return searchQuery.isEmpty
          ? allFaqs
          : allFaqs.where((faq) {
            return faq['question'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                faq['answer'].toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
    } else {
      final filteredFaqs = faqData[selectedCategory] ?? [];
      return searchQuery.isEmpty
          ? filteredFaqs
          : filteredFaqs.where((faq) {
            return faq['question'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                faq['answer'].toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
    }
  }

  Widget _buildCategoryButton(String label, IconData icon) {
    final isSelected = selectedCategory == label;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: () => setState(() => selectedCategory = label),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faqs = getVisibleFaqs();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.teal.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jika Anda memiliki pertanyaan lain, silakan gunakan fitur Chat.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() => searchQuery = '');
                            },
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryButton('Semua', Icons.list),
                  const SizedBox(width: 8),
                  _buildCategoryButton('Umum', Icons.info),
                  const SizedBox(width: 8),
                  _buildCategoryButton('Teknis', Icons.settings),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child:
                  faqs.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text('Tidak ada hasil ditemukan'),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: faqs.length,
                        itemBuilder: (context, index) {
                          final faq = faqs[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.withOpacity(0.1),
                                child: Icon(faq['icon'], color: Colors.teal),
                              ),
                              title: Text(
                                faq['question'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(faq['answer']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 124, 112),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.chat),
                label: const Text("Chat Pengurus Pondok"),
                onPressed: () async {
                  try {
                    final token =
                        await _currentUser
                            .token; // pastikan kamu punya fungsi ini
                    final idOrtu = _currentUser.idAkun;

                    if (token == null || idOrtu == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Token atau ID akun tidak tersedia.'),
                        ),
                      );
                      return;
                    }

                    final idSession = await _ablyService.getOrCreateSession(
                      idStaf: 1, // selalu 1
                      idOrtu: idOrtu,
                      token: token,
                    );

                    if (idSession != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                idStaf: 1,
                                idOrtu: idOrtu,
                                role: 'orang_tua',
                              ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Gagal membuat sesi chat. Pastikan Anda sudah login dan memiliki akses.',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
