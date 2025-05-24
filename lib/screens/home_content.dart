import 'package:flutter/material.dart';
import '../widgets/header_card.dart';
import '../widgets/disiplin_card.dart';
import '../widgets/ibadah_summary_card.dart';
import '../widgets/jadwal_harian_card.dart';
import '../widgets/prestasi_card.dart';
import '../widgets/kesehatan_card.dart';
import '../widgets/pengumuman_card.dart';
import '../widgets/quick_actions_card.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Implementasi refresh data
        await Future.delayed(const Duration(seconds: 2));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            // Header dengan info santri
            HeaderCard(),
            SizedBox(height: 16),

            // Row untuk cards yang sejajar
            Row(
              children: [
                Expanded(child: DisiplinCard()),
                SizedBox(width: 12),
                Expanded(child: IbadahSummaryCard()),
              ],
            ),
            SizedBox(height: 16),

            // Jadwal Harian
            JadwalHarianCard(),
            SizedBox(height: 16),

            // Quick Actions
            QuickActionsCard(),
            SizedBox(height: 16),

            // Row untuk Prestasi dan Kesehatan
            Row(
              children: [
                Expanded(child: PrestasiCard()),
                SizedBox(width: 12),
                Expanded(child: KesehatanCard()),
              ],
            ),
            SizedBox(height: 16),

            // Pengumuman
            PengumumanCard(),
            SizedBox(height: 80), // Extra space for bottom navigation
          ],
        ),
      ),
    );
  }
}
