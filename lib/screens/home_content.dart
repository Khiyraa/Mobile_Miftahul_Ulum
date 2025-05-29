import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/header_card.dart';
import '../widgets/disiplin_card.dart';
import '../widgets/ibadah_summary_card.dart';
import '../widgets/jadwal_harian_card.dart';
import '../widgets/prestasi_card.dart';
import '../widgets/kesehatan_card.dart';
import '../widgets/pengumuman_card.dart';
import '../widgets/quick_actions_card.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String? santriId;

  @override
  void initState() {
    super.initState();
    _loadSantriId();
  }

  Future<void> _loadSantriId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('santri_id') ?? '1'; // fallback default
    setState(() {
      santriId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (santriId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 2));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HeaderCard(santriId: 'ST2018055'!),
            const SizedBox(height: 16),

            const Row(
              children: [
                Expanded(child: DisiplinCard()),
                SizedBox(width: 12),
                Expanded(child: IbadahSummaryCard()),
              ],
            ),
            const SizedBox(height: 16),

            const JadwalHarianCard(),
            const SizedBox(height: 16),

            const QuickActionsCard(),
            const SizedBox(height: 16),

            const Row(
              children: [
                // Expanded(child: PrestasiCard()),
                SizedBox(width: 12),
                Expanded(child: KesehatanCard()),
              ],
            ),
            const SizedBox(height: 16),

            const PengumumanCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}