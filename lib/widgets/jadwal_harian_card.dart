import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kehadiran_mingguan.dart';
import '../services/santri_api_service.dart';

class JadwalHarianCard extends StatefulWidget {
  final String idSantri;

  const JadwalHarianCard({super.key, required this.idSantri});

  @override
  State<JadwalHarianCard> createState() => _JadwalHarianCardState();
}

class _JadwalHarianCardState extends State<JadwalHarianCard> {
  late Future<ApiResponse<List<KehadiranMingguan>>> _kehadiranFuture;
  bool _isRefreshing = false;
  String? _currentSantriId;

  @override
  void initState() {
    super.initState();
    _currentSantriId = widget.idSantri;
    _loadData();
  }

  @override
  void didUpdateWidget(JadwalHarianCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika idSantri berubah, load data baru
    if (oldWidget.idSantri != widget.idSantri) {
      _currentSantriId = widget.idSantri;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isRefreshing = true);

    // Clear cache untuk santri sebelumnya jika berganti santri
    if (_currentSantriId != null && _currentSantriId != widget.idSantri) {
      ApiService.clearSantriCache(_currentSantriId!);
    }

    _kehadiranFuture = ApiService.getKehadiranMingguan(
      widget.idSantri,
      useCache: false, // Force refresh untuk memastikan data terbaru
    );

    // Update current santri ID
    _currentSantriId = widget.idSantri;

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<KehadiranMingguan>>>(
      future: _kehadiranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_isRefreshing) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.success) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    snapshot.data?.message ?? 'Gagal memuat data kehadiran',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final kehadiranList = snapshot.data!.data!;

        // Generate last 7 days
        final List<DateTime> last7Days = [];
        for (int i = 6; i >= 0; i--) {
          last7Days.insert(0, DateTime.now().subtract(Duration(days: i)));
        }

        return Card(
          elevation: 4,
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
                    const Text(
                      'Kehadiran 7 Hari Terakhir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon:
                          _isRefreshing
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.refresh),
                      onPressed: _isRefreshing ? null : _loadData,
                      color: const Color(0xFF1D7A81),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: last7Days.length,
                    itemBuilder: (context, index) {
                      return _buildDayCard(last7Days[index], kehadiranList);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayCard(DateTime date, List<KehadiranMingguan> kehadiranList) {
    final dateFormatted = DateFormat('yyyy-MM-dd').format(date);

    // Find attendance data for this specific date
    final dayKehadiran = kehadiranList.firstWhere(
      (item) => item.tanggal == dateFormatted,
      orElse:
          () => KehadiranMingguan(
            tanggal: dateFormatted,
            jumlahKehadiran: 0,
            subuh: false,
            dzuhur: false,
            ashar: false,
            maghrib: false,
            isya: false,
          ),
    );

    // Create prayer schedule for this day
    final List<Map<String, dynamic>> prayerSchedule = [
      {
        'name': 'Subuh',
        'time': '05:00',
        'attended': dayKehadiran.subuh,
        'jamMasuk': dayKehadiran.jamMasukSubuh,
        'jamKeluar': dayKehadiran.jamKeluarSubuh,
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'name': 'Dzuhur',
        'time': '12:00',
        'attended': dayKehadiran.dzuhur,
        'jamMasuk': dayKehadiran.jamMasukDzuhur,
        'jamKeluar': dayKehadiran.jamKeluarDzuhur,
        'icon': Icons.wb_sunny,
      },
      {
        'name': 'Ashar',
        'time': '15:00',
        'attended': dayKehadiran.ashar,
        'jamMasuk': dayKehadiran.jamMasukAshar,
        'jamKeluar': dayKehadiran.jamKeluarAshar,
        'icon': Icons.wb_cloudy,
      },
      {
        'name': 'Maghrib',
        'time': '18:00',
        'attended': dayKehadiran.maghrib,
        'jamMasuk': dayKehadiran.jamMasukMaghrib,
        'jamKeluar': dayKehadiran.jamKeluarMaghrib,
        'icon': Icons.wb_twilight,
      },
      {
        'name': 'Isya',
        'time': '19:30',
        'attended': dayKehadiran.isya,
        'jamMasuk': dayKehadiran.jamMasukIsya,
        'jamKeluar': dayKehadiran.jamKeluarIsya,
        'icon': Icons.nights_stay,
      },
    ];

    final bool isToday =
        DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateFormatted;
    final attendedCount =
        prayerSchedule.where((p) => p['attended'] == true).length;

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: isToday ? 8 : 2,
        color: isToday ? const Color(0xFF1D7A81).withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isToday
                  ? const BorderSide(color: Color(0xFF1D7A81), width: 2)
                  : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and attendance summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM').format(date),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isToday ? const Color(0xFF1D7A81) : null,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getAttendanceColor(
                        attendedCount,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$attendedCount/5',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getAttendanceColor(attendedCount),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Prayer attendance list
              Expanded(
                child: ListView.separated(
                  itemCount: prayerSchedule.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    return _buildPrayerItem(prayerSchedule[index], date);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerItem(Map<String, dynamic> prayer, DateTime date) {
    final bool attended = prayer['attended'] ?? false;
    final String? jamMasuk = prayer['jamMasuk'];
    final String? jamKeluar = prayer['jamKeluar'];
    final bool isToday =
        DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
        DateFormat('yyyy-MM-dd').format(date);
    final bool isPast = _isPrayerTimePast(prayer['time'], date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color:
            attended
                ? Colors.green.withOpacity(0.1)
                : (isPast
                    ? Colors.red.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              attended
                  ? Colors.green.withOpacity(0.3)
                  : (isPast
                      ? Colors.red.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            prayer['icon'],
            size: 16,
            color:
                attended ? Colors.green : (isPast ? Colors.red : Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer['name'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  prayer['time'],
                  style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                ),
                if (attended && jamMasuk != null)
                  Text(
                    'Masuk: ${DateFormat.Hm().format(DateTime.parse(jamMasuk))}',
                    style: TextStyle(fontSize: 8, color: Colors.grey[700]),
                  ),
                if (attended && jamKeluar != null)
                  Text(
                    'Keluar: ${DateFormat.Hm().format(DateTime.parse(jamKeluar))}',
                    style: TextStyle(fontSize: 8, color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
          Icon(
            attended
                ? Icons.check_circle
                : (isPast ? Icons.cancel : Icons.schedule),
            size: 14,
            color:
                attended ? Colors.green : (isPast ? Colors.red : Colors.grey),
          ),
        ],
      ),
    );
  }

  bool _isPrayerTimePast(String prayerTime, DateTime date) {
    print('Debug _isPrayerTimePast - prayerTime: $prayerTime'); // debug

    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final dateFormatted = DateFormat('yyyy-MM-dd').format(date);

    // Only check if prayer time is past for today
    if (dateFormatted != today) {
      return dateFormatted.compareTo(today) < 0; // Past date
    }

    final timeParts = prayerTime.split(':');
    print('Debug _isPrayerTimePast - timeParts: $timeParts'); // debug
    print(
      'Debug _isPrayerTimePast - timeParts[0]: ${timeParts[0]}, type: ${timeParts[0].runtimeType}',
    ); // debug
    print(
      'Debug _isPrayerTimePast - timeParts[1]: ${timeParts[1]}, type: ${timeParts[1].runtimeType}',
    ); // debug

    final prayerDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]), // <- error kemungkinan muncul di sini
      int.parse(timeParts[1]),
    );

    return now.isAfter(prayerDateTime);
  }

  Color _getAttendanceColor(int attendedCount) {
    if (attendedCount >= 4) return Colors.green;
    if (attendedCount >= 2) return Colors.orange;
    return Colors.red;
  }
}
