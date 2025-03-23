import 'package:flutter/material.dart';
import '../models/jadwal_shalat_model.dart';

class JadwalCard extends StatelessWidget {
  final JadwalShalatModel jadwal;

  JadwalCard({required this.jadwal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildShalatItem("Subuh", jadwal.fajr),
        _buildShalatItem("Dzuhur", jadwal.dhuhr),
        _buildShalatItem("Ashar", jadwal.asr),
        _buildShalatItem("Maghrib", jadwal.maghrib),
        _buildShalatItem("Isya", jadwal.isha),
      ],
    );
  }

  Widget _buildShalatItem(String nama, String waktu) {
    return Card(
      child: ListTile(
        title: Text(nama),
        trailing: Text(waktu),
      ),
    );
  }
}
