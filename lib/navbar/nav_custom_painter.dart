import 'package:flutter/material.dart';

class NavCustomPainter extends CustomPainter {
  late double loc;
  late double s;
  Color color;
  TextDirection textDirection;

  NavCustomPainter(
    double startingLoc,
    int itemsLength,
    this.color,
    this.textDirection,
  ) {
    final span = 1.0 / itemsLength;

    // Modifikasi nilai s untuk membuat lengkungan lebih sempit/lebih dekat dengan ikon
    s = 0.1; // Nilai lebih kecil untuk mempersempit lengkungan (asli 0.2)

    double l = startingLoc + (span - s) / 2;
    loc = textDirection == TextDirection.rtl ? 0.8 - l : l;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..moveTo(0, 0)
          // Mempersingkat jarak untuk memulai lengkungan
          ..lineTo((loc - 0.05) * size.width, 0) // Modifikasi dari 0.1 ke 0.05
          // Kurva 1: Lengkungan naik ke atas - Memodifikasi kontrol untuk lengkungan lebih dekat ke ikon
          ..cubicTo(
            (loc + s * 0.10) * size.width, // Modifikasi dari 0.20 ke 0.10
            size.height * 0.05,
            loc * size.width,
            size.height *
                0.75, // Modifikasi dari 0.60 ke 0.75 untuk membuat lengkungan lebih tinggi
            (loc + s * 0.50) * size.width,
            size.height * 0.75, // Modifikasi dari 0.60 ke 0.75
          )
          // Kurva 2: Lengkungan turun ke bawah - Memodifikasi kontrol untuk lengkungan lebih dekat ke ikon
          ..cubicTo(
            (loc + s) * size.width,
            size.height * 0.75, // Modifikasi dari 0.60 ke 0.75
            (loc + s - s * 0.10) * size.width, // Modifikasi dari 0.20 ke 0.10
            size.height * 0.05,
            (loc + s + 0.05) * size.width, // Modifikasi dari 0.1 ke 0.05
            0,
          )
          ..lineTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
