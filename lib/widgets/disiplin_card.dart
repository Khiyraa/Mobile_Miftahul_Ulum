import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kehadiran_mingguan.dart';
import '../services/santri_api_service.dart';

class DisiplinCard extends StatefulWidget {
  final String santriId;

  const DisiplinCard({super.key, required this.santriId});

  @override
  State<DisiplinCard> createState() => _DisiplinCardState();
}

class _DisiplinCardState extends State<DisiplinCard> {
  List<KehadiranMingguan>? kehadiranData;
  bool isLoading = true;
  String selectedPeriode = 'seminggu';

  final List<Map<String, String>> filterOptions = [
    {'value': 'seminggu', 'label': '7 Hari'},
    {'value': 'sebulan', 'label': '1 Bulan'},
    {'value': 'setahun', 'label': '1 Tahun'},
  ];

  @override
  void initState() {
    super.initState();
    _loadKehadiranData();
  }

  @override
  void didUpdateWidget(covariant DisiplinCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.santriId != widget.santriId) {
      _loadKehadiranData();
    }
  }

  Future<void> _loadKehadiranData() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.getKehadiranMingguan(widget.santriId);
      if (response.success && response.data != null) {
        setState(() {
          kehadiranData = response.data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Map<String, dynamic> _getIbadahSummary(String periode) {
    if (kehadiranData == null) {
      return {
        'totalSholat': 0,
        'totalSeharusnya': 0,
        'persentase': 0.0,
        'status': 'Tidak Ada Data',
        'statusColor': Colors.grey,
        'statusWaktu': _getCurrentPrayerStatus(),
      };
    }

    int totalSholat = 0;
    int totalSeharusnya = 0;

    if (periode == 'seminggu') {
      int hari = 7;
      final cutoffDate = DateTime.now().subtract(Duration(days: hari));

      for (var kehadiran in kehadiranData!) {
        final tanggalKehadiran = DateTime.parse(kehadiran.tanggal);
        if (tanggalKehadiran.isAfter(cutoffDate) ||
            tanggalKehadiran.isAtSameMomentAs(cutoffDate)) {
          totalSholat += kehadiran.jumlahKehadiran;
          totalSeharusnya += 5;
        }
      }
    } else if (periode == 'sebulan') {
      int hari = 30;
      final cutoffDate = DateTime.now().subtract(Duration(days: hari));

      for (var kehadiran in kehadiranData!) {
        final tanggalKehadiran = DateTime.parse(kehadiran.tanggal);
        if (tanggalKehadiran.isAfter(cutoffDate) ||
            tanggalKehadiran.isAtSameMomentAs(cutoffDate)) {
          totalSholat += kehadiran.jumlahKehadiran;
          totalSeharusnya += 5;
        }
      }
    } else if (periode == 'setahun') {
      int hari = 365;
      final cutoffDate = DateTime.now().subtract(Duration(days: hari));

      for (var kehadiran in kehadiranData!) {
        final tanggalKehadiran = DateTime.parse(kehadiran.tanggal);
        if (tanggalKehadiran.isAfter(cutoffDate) ||
            tanggalKehadiran.isAtSameMomentAs(cutoffDate)) {
          totalSholat += kehadiran.jumlahKehadiran;
          totalSeharusnya += 5;
        }
      }
    }

    double persentase =
        totalSeharusnya > 0 ? (totalSholat / totalSeharusnya) * 100 : 0;

    String status;
    Color statusColor;

    if (persentase >= 80) {
      status = 'Sangat Baik';
      statusColor = const Color(0xFF2E8B57);
    } else if (persentase >= 60) {
      status = 'Baik';
      statusColor = const Color(0xFF32CD32);
    } else if (persentase >= 40) {
      status = 'Cukup';
      statusColor = const Color(0xFFFF8C00);
    } else {
      status = 'Perlu Perbaikan';
      statusColor = const Color(0xFFDC143C);
    }

    return {
      'totalSholat': totalSholat,
      'totalSeharusnya': totalSeharusnya,
      'persentase': persentase,
      'status': status,
      'statusColor': statusColor,
      'statusWaktu': _getCurrentPrayerStatus(),
    };
  }

  String _getCurrentPrayerStatus() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTime = currentHour * 60 + currentMinute;

    const int subuhTime = 5 * 60;
    const int dzuhurTime = 12 * 60;
    const int asharTime = 15 * 60;
    const int maghribTime = 18 * 60;
    const int isyaTime = 19 * 60 + 30;

    if (currentTime < subuhTime) {
      return 'Menuju Subuh';
    } else if (currentTime < dzuhurTime) {
      return 'Menuju Dzuhur';
    } else if (currentTime < asharTime) {
      return 'Menuju Ashar';
    } else if (currentTime < maghribTime) {
      return 'Menuju Maghrib';
    } else if (currentTime < isyaTime) {
      return 'Menuju Isya';
    } else {
      return 'Waktu Istirahat';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF197A83), Color(0xFF1E525E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          Row(
            children: const [
              Icon(Icons.verified_user, color: Colors.amber, size: 22),
              SizedBox(width: 8),
              Text(
                'Kedisiplinan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Filter Dropdown
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTapDown: (details) async {
                final selected = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    0,
                    0,
                  ),
                  color: const Color(0xFF1D7A81),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  items:
                      filterOptions.map((option) {
                        return PopupMenuItem<String>(
                          value: option['value'],
                          child: Text(
                            option['label']!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                );

                if (selected != null && selected != selectedPeriode) {
                  setState(() => selectedPeriode = selected);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filterOptions.firstWhere(
                        (element) => element['value'] == selectedPeriode,
                        orElse: () => {'label': ''},
                      )['label']!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Content
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            _buildIbadahContent(),
        ],
      ),
    );
  }

  Widget _buildIbadahContent() {
    final summary = _getIbadahSummary(selectedPeriode);
    final persentase = summary['persentase'] as double;
    final totalSholat = summary['totalSholat'] as int;
    final totalSeharusnya = summary['totalSeharusnya'] as int;
    final status = summary['status'] as String;
    final statusColor = summary['statusColor'] as Color;

    return Column(
      children: [
        Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: persentase / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Text(
                  '${persentase.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sholat: $totalSholat / $totalSeharusnya',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPeriodeLabel(selectedPeriode),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.6), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: statusColor, size: 16),
              const SizedBox(width: 6),
              Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPeriodeLabel(String periode) {
    switch (periode) {
      case 'seminggu':
        return '7 hari terakhir';
      case 'sebulan':
        return '30 hari terakhir';
      case 'setahun':
        return '1 tahun terakhir';
      default:
        return '';
    }
  }
}
