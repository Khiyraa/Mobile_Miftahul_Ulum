import 'package:flutter/material.dart';

class KehadiranData {
  final int jumlahKehadiranSeminggu;
  final int jumlahKehadiranMingguanSeharusnya;
  final int jumlahKehadiranSebulan;
  final int jumlahKehadiranBulanSeharusnya;
  final int jumlahKehadiranSetahun;
  final int jumlahKehadiranTahunanSeharusnya;

  KehadiranData({
    required this.jumlahKehadiranSeminggu,
    required this.jumlahKehadiranMingguanSeharusnya,
    required this.jumlahKehadiranSebulan,
    required this.jumlahKehadiranBulanSeharusnya,
    required this.jumlahKehadiranSetahun,
    required this.jumlahKehadiranTahunanSeharusnya,
  });

  factory KehadiranData.fromJson(Map<String, dynamic> json) {
    return KehadiranData(
      jumlahKehadiranSeminggu: json['jumlah kehadiran seminggu'] ?? 0,
      jumlahKehadiranMingguanSeharusnya:
          json['Jumlah kehadiran mingguan seharusnya'] ?? 0,
      jumlahKehadiranSebulan: json['jumlah kehadiran sebulan'] ?? 0,
      jumlahKehadiranBulanSeharusnya:
          json['Jumlah kehadiran bulan seharusnya'] ?? 0,
      jumlahKehadiranSetahun: json['jumlah kehadiran setahun'] ?? 0,
      jumlahKehadiranTahunanSeharusnya:
          json['Jumlah kehadiran tahunan seharusnya'] ?? 0,
    );
  }

  double getPersentaseKehadiran(String periode) {
    switch (periode) {
      case 'seminggu':
        return jumlahKehadiranMingguanSeharusnya > 0
            ? (jumlahKehadiranSeminggu / jumlahKehadiranMingguanSeharusnya) *
                100
            : 0.0;
      case 'sebulan':
        return jumlahKehadiranBulanSeharusnya > 0
            ? (jumlahKehadiranSebulan / jumlahKehadiranBulanSeharusnya) * 100
            : 0.0;
      case 'setahun':
        return jumlahKehadiranTahunanSeharusnya > 0
            ? (jumlahKehadiranSetahun / jumlahKehadiranTahunanSeharusnya) * 100
            : 0.0;
      default:
        return 0.0;
    }
  }

  int getJumlahKehadiran(String periode) {
    switch (periode) {
      case 'seminggu':
        return jumlahKehadiranSeminggu;
      case 'sebulan':
        return jumlahKehadiranSebulan;
      case 'setahun':
        return jumlahKehadiranSetahun;
      default:
        return 0;
    }
  }

  int getJumlahSeharusnya(String periode) {
    switch (periode) {
      case 'seminggu':
        return jumlahKehadiranMingguanSeharusnya;
      case 'sebulan':
        return jumlahKehadiranBulanSeharusnya;
      case 'setahun':
        return jumlahKehadiranTahunanSeharusnya;
      default:
        return 0;
    }
  }

  String getStatusKehadiran(String periode) {
    final persentase = getPersentaseKehadiran(periode);
    if (persentase >= 90) {
      return 'Sangat Baik';
    } else if (persentase >= 80) {
      return 'Baik';
    } else if (persentase >= 70) {
      return 'Cukup';
    } else {
      return 'Perlu Perbaikan';
    }
  }

  Color getStatusColor(String periode) {
    final persentase = getPersentaseKehadiran(periode);
    if (persentase >= 90) {
      return Colors.green;
    } else if (persentase >= 80) {
      return Colors.blue;
    } else if (persentase >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
