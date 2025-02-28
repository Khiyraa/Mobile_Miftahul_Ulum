import 'package:flutter/material.dart';

class DisiplinCard extends StatelessWidget {
  const DisiplinCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color(0xFF1D7A81),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 200,
          maxWidth: 400,
          minHeight: 120,
          maxHeight: 180,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tingkat Kedisiplinan Santri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Teks putih untuk kontras
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: 0.85,
                backgroundColor: const Color.fromARGB(255, 238, 238, 238),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 20,
              ),
              const SizedBox(height: 8),
              const Text(
                '85% Kehadiran Shalat',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
