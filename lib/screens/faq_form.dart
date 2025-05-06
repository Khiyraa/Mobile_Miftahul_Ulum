import 'package:flutter/material.dart';
import 'chat_admin_screen.dart';

class FaqForm extends StatefulWidget {
  const FaqForm({super.key});

  @override
  State<FaqForm> createState() => _FaqFormState();
}

class _FaqFormState extends State<FaqForm> {
  String selectedCategory = 'Semua';

  final Map<String, List<Map<String, String>>> faqData = {
    'Akun': [
      {
        'question': 'Bagaimana cara mendaftar akun?',
        'answer': 'Unduh aplikasi, lalu klik daftar dan isi formulir.',
      },
      {
        'question': 'Bagaimana cara mengganti password?',
        'answer': 'Masuk ke Pengaturan Akun lalu pilih Ganti Password.',
      },
      {
        'question': 'Bagaimana cara memperbarui email?',
        'answer': 'Buka Profil, klik Edit, lalu ubah email.',
      },
      {
        'question': 'Bagaimana jika lupa username?',
        'answer': 'Hubungi admin melalui fitur Chat untuk reset username.',
      },
    ],
    'Jadwal': [
      {
        'question': 'Bagaimana melihat jadwal?',
        'answer': 'Masuk ke halaman Jadwal pada dashboard aplikasi.',
      },
      {
        'question': 'Bagaimana mengganti jadwal?',
        'answer': 'Pilih jadwal yang diinginkan lalu klik "Ajukan Perubahan".',
      },
      {
        'question': 'Kapan jadwal diperbarui?',
        'answer': 'Jadwal diperbarui setiap hari Minggu pukul 20.00 WIB.',
      },
      {
        'question': 'Apa yang terjadi jika terlambat jadwal?',
        'answer': 'Segera konfirmasi kepada admin melalui aplikasi.',
      },
    ],
    'Teknis': [
      {
        'question': 'Kenapa aplikasi tidak bisa dibuka?',
        'answer': 'Coba update aplikasi atau cek koneksi internet Anda.',
      },
      {
        'question': 'Bagaimana cara mengupdate aplikasi?',
        'answer':
            'Buka Play Store/App Store lalu klik Update di aplikasi kami.',
      },
      {
        'question': 'Kenapa saya tidak menerima notifikasi?',
        'answer': 'Pastikan izin notifikasi diaktifkan di pengaturan HP Anda.',
      },
      {
        'question': 'Bagaimana cara clear cache aplikasi?',
        'answer':
            'Masuk ke Pengaturan > Aplikasi > Pilih Aplikasi > Hapus Cache.',
      },
    ],
    'Kebijakan': [
      {
        'question': 'Apakah data saya aman?',
        'answer':
            'Kami melindungi data Anda dengan sistem enkripsi tingkat tinggi.',
      },
      {
        'question': 'Bagaimana kebijakan refund?',
        'answer':
            'Refund hanya bisa dilakukan jika sesuai dengan syarat dan ketentuan.',
      },
      {
        'question': 'Apakah akun bisa dinonaktifkan?',
        'answer': 'Akun dapat dinonaktifkan jika melanggar ketentuan layanan.',
      },
      {
        'question': 'Bagaimana saya menyetujui kebijakan privasi?',
        'answer':
            'Dengan menggunakan aplikasi, Anda otomatis setuju dengan kebijakan kami.',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> getVisibleFaqs() {
      if (selectedCategory == 'Semua') {
        return [
          faqData['Akun']![0],
          faqData['Jadwal']![0],
          faqData['Teknis']![0],
          faqData['Kebijakan']![0],
        ];
      } else {
        return faqData[selectedCategory]!;
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_pattern.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange.shade100,
                  child: const Text(
                    'Baru! Fitur Live Chat tersedia untuk semua pengguna.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCategoryButton('Akun'),
                      _buildCategoryButton('Jadwal'),
                      _buildCategoryButton('Teknis'),
                      _buildCategoryButton('Kebijakan'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children:
                        getVisibleFaqs().map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  item['question']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(item['answer']!),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatAdminScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Butuh Bantuan? Chat Kami'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return ChoiceChip(
      label: Text(category),
      selected: selectedCategory == category,
      onSelected: (_) {
        setState(() {
          selectedCategory = category;
        });
      },
    );
  }
}
