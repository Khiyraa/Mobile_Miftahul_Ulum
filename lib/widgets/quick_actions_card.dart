import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/chat_admin_screen.dart';
import '../screens/form_izin_screen.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aksi Cepat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: [
                _buildActionItem(
                  context,
                  title: 'Live Chat',
                  subtitle: 'Tanya Pengasuh',
                  icon: Icons.chat_rounded,
                  color: Colors.blue,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final idOrtu = prefs.getInt('id_akun') ?? 0;
                    if (context.mounted) {
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
                    }
                  },
                ),
                _buildActionItem(
                  context,
                  title: 'Izin Santri',
                  subtitle: 'Ajukan Perizinan',
                  icon: Icons.assignment_turned_in_rounded,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FormIzinScreen()),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  title: 'Laporan',
                  subtitle: 'Hasil Belajar',
                  icon: Icons.bar_chart_rounded,
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Laporan segera hadir')),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  title: 'FAQ',
                  subtitle: 'Pusat Bantuan',
                  icon: Icons.help_outline_rounded,
                  color: Colors.teal,
                  onTap: () {
                    // FAQ logic
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
