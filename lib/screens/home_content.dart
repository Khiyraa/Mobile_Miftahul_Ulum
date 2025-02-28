import 'package:flutter/material.dart';
import '../widgets/disiplin_card.dart';
import '../widgets/aktivitas_card.dart';
import '../widgets/pengumuman_card.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          DisiplinCard(),
          SizedBox(height: 16),
          AktivitasCard(),
          SizedBox(height: 16),
          PengumumanCard(),
        ],
      ),
    );
  }
}
