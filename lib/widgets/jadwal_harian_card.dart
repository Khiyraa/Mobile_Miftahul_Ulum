import 'package:flutter/material.dart';

class JadwalHarianCard extends StatelessWidget {
  const JadwalHarianCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> jadwalList = [
      {
        'waktu': '05:00',
        'kegiatan': 'Shalat Subuh',
        'status': 'selesai',
        'icon': Icons.mosque,
      },
      {
        'waktu': '06:30',
        'kegiatan': 'Mengaji Al-Quran',
        'status': 'selesai',
        'icon': Icons.menu_book,
      },
      {
        'waktu': '07:30',
        'kegiatan': 'Sarapan',
        'status': 'selesai',
        'icon': Icons.restaurant,
      },
      {
        'waktu': '08:00',
        'kegiatan': 'Pembelajaran',
        'status': 'berlangsung',
        'icon': Icons.school,
      },
      {
        'waktu': '12:00',
        'kegiatan': 'Shalat Dzuhur',
        'status': 'akan_datang',
        'icon': Icons.mosque,
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jadwal Hari Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(color: Color(0xFF1D7A81), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jadwalList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final jadwal = jadwalList[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(jadwal['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(jadwal['status']).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getStatusColor(jadwal['status']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          jadwal['icon'],
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jadwal['kegiatan'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              jadwal['waktu'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusIndicator(jadwal['status']),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'berlangsung':
        return Colors.orange;
      case 'akan_datang':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusIndicator(String status) {
    switch (status) {
      case 'selesai':
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case 'berlangsung':
        return const Icon(Icons.access_time, color: Colors.orange, size: 20);
      case 'akan_datang':
        return const Icon(Icons.schedule, color: Colors.blue, size: 20);
      default:
        return const SizedBox();
    }
  }
}
