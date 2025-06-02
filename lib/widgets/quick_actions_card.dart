import 'package:flutter/material.dart';
import '../screens/chat_admin_screen.dart'; // Import ChatScreen
import '../services/ably_service.dart'; // Pastikan ada
import '../models/current_user.dart'; // Pastikan ada

class QuickActionsCard extends StatefulWidget {
  const QuickActionsCard({super.key});

  @override
  State<QuickActionsCard> createState() => _QuickActionsCardState();
}

class _QuickActionsCardState extends State<QuickActionsCard> {
  final AblyService _ablyService = AblyService();
  final CurrentUser _currentUser = CurrentUser();

  Future<void> _handleLiveChatTap(BuildContext context) async {
    try {
      final token = await _currentUser.token;
      final idOrtu = _currentUser.idAkun;

      if (token == null || idOrtu == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token atau ID akun tidak tersedia.'),
          ),
        );
        return;
      }

      final idSession = await _ablyService.getOrCreateSession(
        idStaf: 1,
        idOrtu: idOrtu,
        token: token,
      );

      if (idSession != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              idStaf: 1,
              idOrtu: idOrtu,
              role: 'orang_tua',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal membuat sesi chat. Pastikan Anda sudah login dan memiliki akses.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'title': 'Live Chat',
        'subtitle': 'Chat dengan Ustadz',
        'icon': Icons.chat,
        'color': const Color(0xFF4CAF50),
        'onTap': () => _handleLiveChatTap(context),
      },
      {
        'title': 'Laporan',
        'subtitle': 'Laporan bulanan',
        'icon': Icons.assessment,
        'color': const Color(0xFFFF9800),
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Laporan akan segera tersedia')),
          );
        },
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
            const Text(
              'Aksi Cepat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return InkWell(
                  onTap: action['onTap'],
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: action['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: action['color'].withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: action['color'],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            action['icon'],
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                action['title'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                action['subtitle'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
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
