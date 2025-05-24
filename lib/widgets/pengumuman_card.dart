import 'package:flutter/material.dart';

class PengumumanCard extends StatelessWidget {
  const PengumumanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> pengumumanList = [
      {
        'judul': 'Kegiatan Pondok Ramadhan 2025',
        'isi':
            'Persiapan kegiatan khusus bulan Ramadhan dengan jadwal tahfidz intensif dan kajian khusus.',
        'tanggal': '2 jam yang lalu',
        'prioritas': 'tinggi',
        'icon': Icons.star,
        'dibaca': false,
      },
      {
        'judul': 'Libur Semester Genap',
        'isi': 'Pengumuman jadwal libur semester genap tahun ajaran 2024/2025.',
        'tanggal': '1 hari yang lalu',
        'prioritas': 'sedang',
        'icon': Icons.event,
        'dibaca': true,
      },
      {
        'judul': 'Pembayaran SPP Bulan Juni',
        'isi':
            'Batas waktu pembayaran SPP bulan Juni adalah tanggal 10 Juni 2025.',
        'tanggal': '3 hari yang lalu',
        'prioritas': 'tinggi',
        'icon': Icons.payment,
        'dibaca': true,
      },
      {
        'judul': 'Perlombaan Tahfidz Antar Pondok',
        'isi': 'Pendaftaran lomba tahfidz tingkat kabupaten sudah dibuka.',
        'tanggal': '5 hari yang lalu',
        'prioritas': 'sedang',
        'icon': Icons.emoji_events,
        'dibaca': false,
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
                  'Pengumuman',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '2 Baru',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Color(0xFF1D7A81),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pengumumanList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pengumuman = pengumumanList[index];
                final isHighPriority = pengumuman['prioritas'] == 'tinggi';
                final isUnread = !pengumuman['dibaca'];

                return InkWell(
                  onTap: () {
                    // Handle tap to read announcement
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isUnread
                              ? const Color(0xFF1D7A81).withOpacity(0.05)
                              : Colors.grey.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isHighPriority
                                ? Colors.red.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isHighPriority
                                    ? Colors.red.withOpacity(0.1)
                                    : const Color(0xFF1D7A81).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            pengumuman['icon'],
                            color:
                                isHighPriority
                                    ? Colors.red
                                    : const Color(0xFF1D7A81),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pengumuman['judul'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            isUnread
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                        color:
                                            isUnread
                                                ? Colors.black
                                                : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  if (isHighPriority)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'PENTING',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (isUnread) const SizedBox(width: 8),
                                  if (isUnread)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1D7A81),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pengumuman['isi'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                pengumuman['tanggal'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
