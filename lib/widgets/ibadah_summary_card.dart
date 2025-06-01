import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kehadiran_mingguan.dart';
import '../services/santri_api_service.dart';

class IbadahSummaryCard extends StatefulWidget {
  final String santriId;

  const IbadahSummaryCard({super.key, required this.santriId});

  @override
  State<IbadahSummaryCard> createState() => _IbadahSummaryCardState();
}

class _IbadahSummaryCardState extends State<IbadahSummaryCard> {
  late Future<ApiResponse<List<KehadiranMingguan>>> _kehadiranFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(IbadahSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.santriId != widget.santriId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isRefreshing = true);
    _kehadiranFuture = ApiService.getKehadiranMingguan(widget.santriId);
    setState(() => _isRefreshing = false);
  }

  Map<String, dynamic> _getTodayAttendanceSummary(
    List<KehadiranMingguan> kehadiranList,
  ) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Find today's attendance data
    final todayKehadiran = kehadiranList.firstWhere(
      (item) => item.tanggal == today,
      orElse:
          () => KehadiranMingguan(
            tanggal: today,
            jumlahKehadiran: 0,
            subuh: false,
            dzuhur: false,
            ashar: false,
            maghrib: false,
            isya: false,
          ),
    );

    // Count attended prayers
    int totalSholat = 0;
    if (todayKehadiran.subuh) totalSholat++;
    if (todayKehadiran.dzuhur) totalSholat++;
    if (todayKehadiran.ashar) totalSholat++;
    if (todayKehadiran.maghrib) totalSholat++;
    if (todayKehadiran.isya) totalSholat++;

    // Calculate remaining prayers
    int tersisa = 5 - totalSholat;

    // Determine current prayer time and status
    String statusWaktu = _getCurrentPrayerStatus();

    return {
      'totalSholat': totalSholat,
      'tersisa': tersisa,
      'statusWaktu': statusWaktu,
      'todayData': todayKehadiran,
    };
  }

  String _getCurrentPrayerStatus() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTime = currentHour * 60 + currentMinute;

    // Prayer times in minutes from midnight
    const int subuhTime = 5 * 60; // 05:00
    const int dzuhurTime = 12 * 60; // 12:00
    const int asharTime = 15 * 60; // 15:00
    const int maghribTime = 18 * 60; // 18:00
    const int isyaTime = 19 * 60 + 30; // 19:30

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

  Color _getStatusColor(int totalSholat) {
    if (totalSholat >= 4) return const Color(0xFF2E8B57); // Green
    if (totalSholat >= 2) return const Color(0xFFFF8C00); // Orange
    return const Color(0xFFDC143C); // Red
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<KehadiranMingguan>>>(
      future: _kehadiranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_isRefreshing) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 120,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Default values if no data
        int totalSholat = 0;
        int tersisa = 5;
        String statusWaktu = _getCurrentPrayerStatus();
        Color cardColor = const Color(0xFF2E8B57);

        if (snapshot.hasData &&
            snapshot.data!.success &&
            snapshot.data!.data != null) {
          final summary = _getTodayAttendanceSummary(snapshot.data!.data!);
          totalSholat = summary['totalSholat'];
          tersisa = summary['tersisa'];
          statusWaktu = summary['statusWaktu'];
          cardColor = _getStatusColor(totalSholat);
        }

        return GestureDetector(
          onTap: _loadData, // Refresh on tap
          child: Card(
            elevation: 4,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.mosque, color: Colors.white, size: 24),
                      if (_isRefreshing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ibadah Hari Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$totalSholat',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Shalat',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Column(
                        children: [
                          Text(
                            '$tersisa',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Tersisa',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusWaktu,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
