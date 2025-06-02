import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/header_card.dart';
import '../widgets/disiplin_card.dart';
import '../widgets/ibadah_summary_card.dart';
import '../widgets/jadwal_harian_card.dart';
import '../widgets/prestasi_card.dart';
import '../widgets/perizinan_card.dart';
// import '../widgets/kesehatan_card.dart';
import '../widgets/pengumuman_card.dart';
import '../widgets/quick_actions_card.dart';
import '../services/santri_api_service.dart';
import '../models/santri.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String? ortuId; // ID orang tua yang login
  List<Santri> santriList = [];
  bool isLoading = true;
  String? selectedSantriId; // ID santri yang sedang dipilih
  Santri? selectedSantri; // Data santri yang sedang dipilih

  @override
  void initState() {
    super.initState();
    _loadOrtuIdAndSantri();
  }

  Future<void> _loadOrtuIdAndSantri() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil id_akun sebagai int, lalu ubah ke string untuk API (kalau API butuh string)
    final int? ortuIdFromPrefs = prefs.getInt('id_akun');

    print('Loaded ortuId from prefs: $ortuIdFromPrefs');

    if (ortuIdFromPrefs != null) {
      setState(() {
        ortuId = ortuIdFromPrefs.toString(); // konversi ke string
      });

      await _loadSantriData();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID orang tua tidak ditemukan. Silakan login ulang.'),
        ),
      );
    }
  }

  Future<void> _loadSantriData() async {
    if (ortuId == null) return;

    try {
      final response = await ApiService.getSantriByOrtuId(ortuId!);

      // 🐞 Debug isi response dari server
      print('=== DEBUG: Response ===');
      print('Success: ${response.success}');
      print('Message: ${response.message}');
      print('Data (parsed): ${response.data}');

      if (response.success && response.data != null) {
        // 🐞 Debug tipe dan isi data
        print('=== DEBUG: Mapping ke List<Santri> ===');
        print('Data type: ${response.data.runtimeType}');
        print('First item: ${response.data![0]}');

        setState(() {
          santriList = response.data!;

          if (santriList.isNotEmpty) {
            selectedSantriId = santriList.first.idSantri;
            selectedSantri = santriList.first;
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
      }
    } catch (e, stackTrace) {
      print('=== ERROR CAUGHT ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');

      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Fungsi untuk menangani perubahan santri yang dipilih
  void _onSantriChanged(String newSantriId) {
    setState(() {
      selectedSantriId = newSantriId;
      selectedSantri = santriList.firstWhere(
        (santri) => santri.idSantri == newSantriId,
      );
    });

    // Simpan pilihan santri ke SharedPreferences (opsional)
    _saveSelectedSantri(newSantriId);

    // Refresh semua data untuk santri yang baru dipilih
    _refreshAllData();
  }

  Future<void> _saveSelectedSantri(String santriId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_santri_id', santriId);
  }

  // Fungsi untuk refresh semua data ketika santri berubah
  void _refreshAllData() {
    // Trigger rebuild untuk semua widget yang memerlukan data santri
    setState(() {
      // Widget akan otomatis rebuild dengan selectedSantriId yang baru
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data santri...'),
          ],
        ),
      );
    }

    // Jika tidak ada data santri
    if (santriList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadSantriData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height - 200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada data santri ditemukan',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tarik ke bawah untuk memuat ulang',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSantriData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header dengan dropdown santri (jika ada multiple santri)
            HeaderCard(
              santriId: selectedSantriId,
              santriList: santriList.length > 1 ? santriList : null,
              onSantriChanged: _onSantriChanged,
            ),
            const SizedBox(height: 16),

            // Cards dengan data santri yang dipilih
            Row(
              children: [
                Expanded(child: DisiplinCard(santriId: selectedSantriId!)),
                const SizedBox(width: 12),
                Expanded(child: IbadahSummaryCard(santriId: selectedSantriId!)),
              ],
            ),
            const SizedBox(height: 16),

            JadwalHarianCard(idSantri: selectedSantriId!),
            const SizedBox(height: 16),

            const QuickActionsCard(),
            const SizedBox(height: 16),

            PerizinanCard(santriId: selectedSantriId!),
            const SizedBox(height: 16),

            const PengumumanCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
