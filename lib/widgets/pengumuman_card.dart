import 'package:flutter/material.dart';

class PengumumanCard extends StatelessWidget {
  const PengumumanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengumuman Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder:
                  (context, index) => ListTile(
                    leading: const Icon(Icons.campaign, color: Colors.blue),
                    title: Text('Pengumuman ${index + 1}'),
                    subtitle: const Text('Detail pengumuman...'),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
