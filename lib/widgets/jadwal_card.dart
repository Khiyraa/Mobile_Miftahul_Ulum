import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/jadwal_shalat_model.dart';

class JadwalCard extends StatelessWidget {
  final JadwalShalatModel jadwal;
  final String namaDaerah;

  const JadwalCard({super.key, required this.jadwal, required this.namaDaerah});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> shalatTimes = [
      {"nama": "Subuh", "waktu": jadwal.fajr},
      {"nama": "Dzuhur", "waktu": jadwal.dhuhr},
      {"nama": "Ashar", "waktu": jadwal.asr},
      {"nama": "Maghrib", "waktu": jadwal.maghrib},
      {"nama": "Isya", "waktu": jadwal.isha},
    ];

    // Menentukan waktu adzan berikutnya
    DateTime now = DateTime.now();
    String? nextShalat;
    for (var shalat in shalatTimes) {
      DateTime shalatTime = _parseTime(shalat["waktu"]!);
      if (shalatTime.isAfter(now)) {
        nextShalat = shalat["nama"];
        break;
      }
    }

    return Column(
      children:
          shalatTimes.map((shalat) {
            bool isNext = shalat["nama"] == nextShalat;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              padding: EdgeInsets.all(isNext ? 15 : 10),
              decoration: BoxDecoration(
                color: isNext ? Color(0xFF1D7A81) : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                boxShadow:
                    isNext
                        ? [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ]
                        : [],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Kolom Nama Daerah dan Nama Waktu Adzan
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Waktu adzan untuk daerah: $namaDaerah",
                          style: TextStyle(
                            fontSize: 12,
                            color: isNext ? Colors.white : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          shalat["nama"]!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isNext ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Jam Waktu Adzan
                  Expanded(
                    flex: 1,
                    child: Text(
                      shalat["waktu"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isNext ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: isNext ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // Fungsi untuk mengubah string waktu ke DateTime
  DateTime _parseTime(String time) {
    DateTime now = DateTime.now();
    List<String> parts = time.split(":");
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
