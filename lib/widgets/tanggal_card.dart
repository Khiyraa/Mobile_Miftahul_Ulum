import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TanggalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    // Ambil 5 tanggal (2 hari sebelum, hari ini, 2 hari setelah)
    List<DateTime> dates = List.generate(5, (index) => now.subtract(Duration(days: 2 - index)));

    return SizedBox(
      height: 140, // Tinggi Card lebih besar
      width: 750,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.20, initialPage: 2), // Lebarkan card
        itemCount: dates.length,
        itemBuilder: (context, index) {
          DateTime date = dates[index];
          String bulan = DateFormat('MMM').format(date);
          String tanggal = DateFormat('dd').format(date);
          String hari = DateFormat('EEE').format(date);

          bool isToday = date.day == now.day && date.month == now.month && date.year == now.year;

          return Center(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: isToday ? 90 : 80, // Lebarkan "Hari Ini"
              margin: EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                color: isToday ? Color(0xFF1D7A81) : Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
                boxShadow: isToday
                    ? [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      bulan,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isToday ? Colors.white : Colors.black),
                    ),
                  ),
                  SizedBox(height: 8), // Tambahkan Jarak antar konten
                  FittedBox(
                    child: Text(
                      tanggal,
                      style: TextStyle(fontSize: isToday ? 24 : 20, fontWeight: FontWeight.bold, color: isToday ? Colors.white : Colors.black),
                    ),
                  ),
                  SizedBox(height: 8),
                  FittedBox(
                    child: Text(
                      hari,
                      style: TextStyle(fontSize: 16, color: isToday ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
