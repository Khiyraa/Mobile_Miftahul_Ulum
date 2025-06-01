import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/santri.dart';
import '../services/santri_api_service.dart';

class HeaderCard extends StatefulWidget {
  final String? santriId;
  final List<Santri>? santriList;
  final Function(String)? onSantriChanged;

  const HeaderCard({
    super.key,
    this.santriId,
    this.santriList,
    this.onSantriChanged,
  });

  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  Santri? santri;
  bool isLoading = true;
  String? errorMessage;
  bool isLocaleInitialized = false;
  String? selectedSantriId;

  @override
  void initState() {
    super.initState();
    selectedSantriId = widget.santriId;
    _initializeLocaleAndLoadData();
  }

  @override
  void didUpdateWidget(HeaderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.santriId != widget.santriId) {
      selectedSantriId = widget.santriId;
      _loadSantriData();
    }
  }

  Future<void> _initializeLocaleAndLoadData() async {
    await initializeDateFormatting('id_ID');
    setState(() {
      isLocaleInitialized = true;
    });
    _loadSantriData();
  }

  Future<void> _loadSantriData() async {
    if (!isLocaleInitialized || selectedSantriId == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getSantriById(selectedSantriId!);

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

  void _onSantriDropdownChanged(String? newSantriId) {
    if (newSantriId != null && newSantriId != selectedSantriId) {
      setState(() {
        selectedSantriId = newSantriId;
      });
      widget.onSantriChanged?.call(newSantriId);
      _loadSantriData();
    }
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
                    'Angkatan ${santri!.tahunAngkatan} - ${santri!.idSantri}',
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

        // Dropdown untuk multiple santri - letakkan di bawah foto profil
        if (widget.santriList != null && widget.santriList!.length > 1) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSantriId,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                dropdownColor: const Color(0xFF1D7A81),
                style: const TextStyle(color: Colors.white),
                items:
                    widget.santriList!.map((santri) {
                      return DropdownMenuItem<String>(
                        value: santri.idSantri,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      santri.nama,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'ID: ${santri.idSantri}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (santri.idSantri == selectedSantriId)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: _onSantriDropdownChanged,
                hint: const Row(
                  children: [
                    Icon(Icons.people, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Pilih Santri',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

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
