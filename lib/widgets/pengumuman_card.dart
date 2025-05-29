import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PengumumanCard extends StatefulWidget {
  const PengumumanCard({super.key});

  @override
  State<PengumumanCard> createState() => _PengumumanCardState();
}

class _PengumumanCardState extends State<PengumumanCard> {
  List<PengumumanModel> pengumumanList = [];
  bool isLoading = true;
  String? errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadPengumuman();
  }

  Future<void> _loadPengumuman() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('Loading pengumuman...'); // Debug log
      final data = await _apiService.getPengumuman();
      print('Loaded ${data.length} pengumuman'); // Debug log

      // Perbaikan 1: Tampilkan semua pengumuman terlebih dahulu untuk debugging
      // Nanti bisa dikembalikan ke filter isActive
      // final activePengumuman = data.where((p) => p.isActive).toList();
      final activePengumuman = data; // Sementara tampilkan semua

      // Sort berdasarkan tanggal created_at terbaru
      activePengumuman.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        pengumumanList = activePengumuman;
        isLoading = false;
      });

      // Debug log untuk setiap pengumuman
      for (var p in pengumumanList) {
        print(
          'Pengumuman: ${p.judul}, Active: ${p.isActive}, TglMulai: ${p.tglMulai}, TglSelesai: ${p.tglSelesai}',
        );
      }
    } catch (e) {
      print('Error loading pengumuman: $e'); // Debug log
      setState(() {
        errorMessage = 'Gagal memuat data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  int get unreadCount {
    // Untuk sementara, kita anggap pengumuman yang dibuat dalam 3 hari terakhir sebagai "baru"
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    return pengumumanList
        .where((p) => p.createdAt.isAfter(threeDaysAgo))
        .length;
  }

  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'akademik':
        return Colors.blue;
      case 'administrasi':
        return Colors.red;
      case 'kegiatan':
        return Colors.green;
      default:
        return const Color(0xFF1D7A81);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    if (unreadCount > 0)
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
                            Text(
                              '$unreadCount Baru',
                              style: const TextStyle(
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
                      onPressed: () {
                        _showAllPengumuman(context);
                      },
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
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: Color(0xFF1D7A81)),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.grey[400], size: 48),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat pengumuman',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadPengumuman,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D7A81),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (pengumumanList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.announcement_outlined,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada pengumuman',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadPengumuman,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D7A81),
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Horizontal scroll view untuk pengumuman
    return SizedBox(
      height: 280, // Fixed height untuk scroll horizontal
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pengumumanList.length,
        itemBuilder: (context, index) {
          final pengumuman = pengumumanList[index];
          final isHighPriority = pengumuman.prioritas == 'tinggi';
          final isUnread =
              DateTime.now().difference(pengumuman.createdAt).inDays < 3;
          final categoryColor = _getCategoryColor(pengumuman.kategori);

          return Container(
            width: 280, // Fixed width untuk setiap card
            margin: EdgeInsets.only(
              right: index == pengumumanList.length - 1 ? 0 : 12,
            ),
            child: InkWell(
              onTap: () {
                _showPengumumanDetail(context, pengumuman);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isUnread
                          ? categoryColor.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isHighPriority
                            ? Colors.red.withOpacity(0.3)
                            : categoryColor.withOpacity(0.2),
                    width: isHighPriority ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan icon dan badge
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              pengumuman.icon,
                              color: categoryColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    pengumuman.kategori.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: categoryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pengumuman.timeAgo,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
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
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Gambar jika ada
                    if (pengumuman.foto != null && pengumuman.foto!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(
                              'http://192.168.1.17:8000/storage/${pengumuman.foto}',
                            ),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              print('Error loading image: $exception');
                            },
                          ),
                        ),
                      )
                    else
                      // Placeholder jika tidak ada gambar
                      Container(
                        width: double.infinity,
                        height: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          pengumuman.icon,
                          color: categoryColor.withOpacity(0.5),
                          size: 48,
                        ),
                      ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pengumuman.judul,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                color:
                                    isUnread ? Colors.black : Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                pengumuman.isi,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Berlaku sampai: ${pengumuman.tglSelesai.day.toString().padLeft(2, '0')}/${pengumuman.tglSelesai.month.toString().padLeft(2, '0')}/${pengumuman.tglSelesai.year}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPengumumanDetail(BuildContext context, PengumumanModel pengumuman) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              pengumuman.judul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pengumuman.foto != null && pengumuman.foto!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(
                            'http://192.168.1.17:8000/storage/${pengumuman.foto}',
                          ),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            print('Error loading image: $exception');
                          },
                        ),
                      ),
                    ),
                  if (pengumuman.foto != null && pengumuman.foto!.isNotEmpty)
                    const SizedBox(height: 16),
                  Text(pengumuman.isi, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          pengumuman.kategori.toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: _getCategoryColor(
                          pengumuman.kategori,
                        ).withOpacity(0.1),
                      ),
                      const Spacer(),
                      Text(
                        'Berlaku sampai: ${pengumuman.tglSelesai.day.toString().padLeft(2, '0')}/${pengumuman.tglSelesai.month.toString().padLeft(2, '0')}/${pengumuman.tglSelesai.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    color: _getCategoryColor(pengumuman.kategori),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showAllPengumuman(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AllPengumumanPage(
              pengumumanList: pengumumanList,
              onRefresh: _loadPengumuman,
            ),
      ),
    );
  }
}

class AllPengumumanPage extends StatelessWidget {
  final List<PengumumanModel> pengumumanList;
  final VoidCallback? onRefresh;

  const AllPengumumanPage({
    super.key,
    required this.pengumumanList,
    this.onRefresh,
  });

  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'akademik':
        return Colors.blue;
      case 'administrasi':
        return Colors.red;
      case 'kegiatan':
        return Colors.green;
      default:
        return const Color(0xFF1D7A81);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Pengumuman'),
        backgroundColor: const Color(0xFF1D7A81),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              onRefresh?.call();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body:
          pengumumanList.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.announcement_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada pengumuman',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  onRefresh?.call();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pengumumanList.length,
                  itemBuilder: (context, index) {
                    final pengumuman = pengumumanList[index];
                    final isUnread =
                        DateTime.now().difference(pengumuman.createdAt).inDays <
                        3;
                    final categoryColor = _getCategoryColor(
                      pengumuman.kategori,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isUnread ? 3 : 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: categoryColor.withOpacity(0.1),
                          child: Icon(pengumuman.icon, color: categoryColor),
                        ),
                        title: Text(
                          pengumuman.judul,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pengumuman.isi,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pengumuman.timeAgo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Sampai: ${pengumuman.tglSelesai.day}/${pengumuman.tglSelesai.month}/${pengumuman.tglSelesai.year}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              label: Text(
                                pengumuman.kategori.toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: categoryColor.withOpacity(0.1),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          _showPengumumanDetail(context, pengumuman);
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }

  void _showPengumumanDetail(BuildContext context, PengumumanModel pengumuman) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(pengumuman.judul),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pengumuman.foto != null && pengumuman.foto!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(pengumuman.fotoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (pengumuman.foto != null && pengumuman.foto!.isNotEmpty)
                    const SizedBox(height: 16),
                  Text(pengumuman.isi, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          pengumuman.kategori.toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: _getCategoryColor(
                          pengumuman.kategori,
                        ).withOpacity(0.1),
                      ),
                      const Spacer(),
                      Text(
                        'Berlaku sampai: ${pengumuman.tglSelesai.day.toString().padLeft(2, '0')}/${pengumuman.tglSelesai.month.toString().padLeft(2, '0')}/${pengumuman.tglSelesai.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    color: _getCategoryColor(pengumuman.kategori),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
