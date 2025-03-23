import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TanggalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String today = DateFormat('dd MMM yyyy').format(DateTime.now());
    
    return Container(
      margin: EdgeInsets.all(10),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().subtract(Duration(days: 3 - index));
          String formattedDate = DateFormat('dd MMM').format(date);

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: formattedDate == today ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(formattedDate),
          );
        },
      ),
    );
  }
}
