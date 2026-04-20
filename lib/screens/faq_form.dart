import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_admin_screen.dart';
import '../models/current_user.dart';

class FaqForm extends StatefulWidget {
  const FaqForm({super.key});

  @override
  State<FaqForm> createState() => _FaqFormState();
}

class _FaqFormState extends State<FaqForm> {
  String selectedCategory = 'Semua';
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  final CurrentUser _currentUser = CurrentUser();

  final Map<String, List<Map<String, dynamic>>> faqData = {
    'Umum': [
      {'question': 'Cara ganti password?', 'answer': 'Hubungi pengurus pondok.', 'icon': Icons.person},
      {'question': 'Pantau kedisiplinan?', 'answer': 'Lihat di dashboard utama.', 'icon': Icons.bar_chart},
    ],
    'Teknis': [
      {'question': 'Aplikasi error?', 'answer': 'Restart HP atau update aplikasi.', 'icon': Icons.warning},
    ],
  };

  @override
  void initState() {
    super.initState();
    _currentUser.initFromSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text('Pusat Bantuan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari bantuan...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFaqItem('Bagaimana cara menggunakan aplikasi?', 'Anda dapat melihat data santri melalui dashboard utama.'),
                _buildFaqItem('Kapan jadwal shalat diperbarui?', 'Jadwal shalat sinkron otomatis dengan lokasi Anda.'),
                _buildFaqItem('Cara menghubungi ustadz?', 'Gunakan fitur Live Chat di halaman Beranda.'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                label: Text('HUBUNGI ADMIN', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                    idStaf: 1, idOrtu: _currentUser.idAkun ?? 0, role: 'orang_tua'
                  )));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Text(q, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        children: [Padding(padding: const EdgeInsets.all(15), child: Text(a, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])))],
      ),
    );
  }
}
