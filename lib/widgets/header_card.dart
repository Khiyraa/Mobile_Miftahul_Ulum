import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/santri.dart';
import '../services/santri_api_service.dart';

class HeaderCard extends StatefulWidget {
  final String? santriId;

  const HeaderCard({super.key, this.santriId});

  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  Santri? santri;
  bool isLoading = true;
  String? errorMessage;
  bool isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocaleAndLoadData();
  }

  Future<void> _initializeLocaleAndLoadData() async {
    await initializeDateFormatting('id_ID');
    setState(() {
      isLocaleInitialized = true;
    });
    _loadSantriData();
  }

  Future<void> _loadSantriData() async {
    if (!isLocaleInitialized || widget.santriId == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getSantriById(widget.santriId!);

      if (response.success && response.data != null) {
        setState(() {
          santri = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.message ?? 'Data tidak ditemukan';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data: $e';
        isLoading = false;
      });
    }
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    return formatter.format(now);
  }

  String _getKelasInfo() {
    if (santri?.tahunAngkatan != null) {
      final currentYear = DateTime.now().year;
      final angkatan = int.tryParse(santri!.tahunAngkatan) ?? currentYear;
      final kelas = currentYear - angkatan + 1;
      return 'Kelas $kelas';
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D7A81), Color(0xFF2E8B91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              _buildLoadingWidget()
            else if (errorMessage != null || santri == null)
              _buildErrorWidget()
            else
              _buildContentWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Row(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
        SizedBox(width: 16),
        Text(
          'Memuat data...',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning, color: Colors.orange, size: 24),
        const SizedBox(height: 8),
        const Text(
          'Gagal memuat data santri',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (errorMessage != null)
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _loadSantriData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
          ),
          child: const Text('Coba Lagi'),
        ),
      ],
    );
  }

  Widget _buildContentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assalamu\'alaikum',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    santri!.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_getKelasInfo()} - ${santri!.idSantri}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (santri!.status.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            santri!.status.toLowerCase() == 'aktif'
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        santri!.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Hari ini: ${_getCurrentDay()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
