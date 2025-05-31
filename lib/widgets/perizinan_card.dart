import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/perizinan.dart';
import '../services/santri_api_service.dart';

class PerizinanCard extends StatefulWidget {
  final String santriId;

  const PerizinanCard({super.key, required this.santriId});

  @override
  State<PerizinanCard> createState() => _PerizinanCardState();
}

class _PerizinanCardState extends State<PerizinanCard> {
  late Future<ApiResponse<List<Perizinan>>> _perizinanFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(PerizinanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.santriId != widget.santriId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isRefreshing = true);
    _perizinanFuture = ApiService.getPerizinanSetahun(widget.santriId);
    setState(() => _isRefreshing = false);
  }

  Map<String, dynamic> _getPerizinanSummary(List<Perizinan> perizinanList) {
    // Hitung total perizinan dalam setahun
    final totalPerizinan = perizinanList.length;

    // Hitung berdasarkan status
    final disetujui =
        perizinanList
            .where(
              (p) =>
                  p.status.toLowerCase() == 'disetujui' ||
                  p.status.toLowerCase() == 'approved',
            )
            .length;
    final pending =
        perizinanList
            .where(
              (p) =>
                  p.status.toLowerCase() == 'pending' ||
                  p.status.toLowerCase() == 'menunggu',
            )
            .length;
    final ditolak =
        perizinanList
            .where(
              (p) =>
                  p.status.toLowerCase() == 'ditolak' ||
                  p.status.toLowerCase() == 'rejected',
            )
            .length;

    // Hitung berdasarkan jenis
    final sakit =
        perizinanList
            .where((p) => p.jenisPerizinan.toLowerCase().contains('sakit'))
            .length;
    final izin =
        perizinanList
            .where((p) => p.jenisPerizinan.toLowerCase().contains('izin'))
            .length;
    final lainnya = totalPerizinan - sakit - izin;

    // Tentukan status berdasarkan jumlah perizinan
    String statusText;
    Color statusColor;

    if (totalPerizinan == 0) {
      statusText = 'Sangat Baik';
      statusColor = Colors.green;
    } else if (totalPerizinan <= 5) {
      statusText = 'Baik';
      statusColor = Colors.blue;
    } else if (totalPerizinan <= 10) {
      statusText = 'Cukup';
      statusColor = Colors.orange;
    } else {
      statusText = 'Perlu Perhatian';
      statusColor = Colors.red;
    }

    // Hitung persentase kehadiran (asumsi 365 hari dalam setahun)
    final persentaseKehadiran = ((365 - totalPerizinan) / 365 * 100).clamp(
      0,
      100,
    );

    return {
      'totalPerizinan': totalPerizinan,
      'disetujui': disetujui,
      'pending': pending,
      'ditolak': ditolak,
      'sakit': sakit,
      'izin': izin,
      'lainnya': lainnya,
      'statusText': statusText,
      'statusColor': statusColor,
      'persentaseKehadiran': persentaseKehadiran,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Perizinan>>>(
      future: _perizinanFuture,
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
        int totalPerizinan = 0;
        int sakit = 0;
        String statusText = 'Sangat Baik';
        Color cardColor = const Color(0xFF4CAF50); // Green
        double persentaseKehadiran = 100.0;

        if (snapshot.hasData &&
            snapshot.data!.success &&
            snapshot.data!.data != null) {
          final summary = _getPerizinanSummary(snapshot.data!.data!);
          totalPerizinan = summary['totalPerizinan'];
          sakit = summary['sakit'];
          statusText = summary['statusText'];
          cardColor = summary['statusColor'];
          persentaseKehadiran = summary['persentaseKehadiran'];
        }

        return GestureDetector(
          onTap: () => _showPerizinanDetail(context, snapshot.data?.data ?? []),
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
                      const Icon(
                        Icons.assignment,
                        color: Colors.white,
                        size: 24,
                      ),
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
                    'Perizinan (1 Tahun)',
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
                            '${persentaseKehadiran.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Kehadiran',
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
                            '$totalPerizinan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Perizinan',
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
                      statusText,
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

  void _showPerizinanDetail(
    BuildContext context,
    List<Perizinan> perizinanList,
  ) {
    if (perizinanList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tidak ada data perizinan')));
      return;
    }

    final summary = _getPerizinanSummary(perizinanList);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detail Perizinan (1 Tahun)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Summary Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total',
                              '${summary['totalPerizinan']}',
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Sakit',
                              '${summary['sakit']}',
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Izin',
                              '${summary['izin']}',
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Riwayat Perizinan:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // List perizinan
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: perizinanList.length,
                          itemBuilder: (context, index) {
                            final perizinan = perizinanList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(
                                    perizinan.status,
                                  ),
                                  child: Icon(
                                    _getStatusIcon(perizinan.jenisPerizinan),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  perizinan.jenisPerizinan,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(perizinan.alasan),
                                    Text(
                                      'Tanggal: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(perizinan.waktu))}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      perizinan.status,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    perizinan.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(perizinan.status),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return Colors.green;
      case 'pending':
      case 'menunggu':
        return Colors.orange;
      case 'ditolak':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String jenisPerizinan) {
    if (jenisPerizinan.toLowerCase().contains('sakit')) {
      return Icons.local_hospital;
    } else if (jenisPerizinan.toLowerCase().contains('izin')) {
      return Icons.event_note;
    } else {
      return Icons.assignment;
    }
  }
}
