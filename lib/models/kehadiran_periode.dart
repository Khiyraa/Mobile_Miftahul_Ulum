// models/kehadiran_periode.dart
class KehadiranPeriode {
  final String tanggal;
  final int jumlahKehadiran;
  final int subuh;
  final int dzuhur;
  final int ashar;
  final int maghrib;
  final int isya;
  final String? jamMasukSubuh;
  final String? jamMasukDzuhur;
  final String? jamMasukAshar;
  final String? jamMasukMaghrib;
  final String? jamMasukIsya;
  final String? jamKeluarSubuh;
  final String? jamKeluarDzuhur;
  final String? jamKeluarAshar;
  final String? jamKeluarMaghrib;
  final String? jamKeluarIsya;

  KehadiranPeriode({
    required this.tanggal,
    required this.jumlahKehadiran,
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    this.jamMasukSubuh,
    this.jamMasukDzuhur,
    this.jamMasukAshar,
    this.jamMasukMaghrib,
    this.jamMasukIsya,
    this.jamKeluarSubuh,
    this.jamKeluarDzuhur,
    this.jamKeluarAshar,
    this.jamKeluarMaghrib,
    this.jamKeluarIsya,
  });

  factory KehadiranPeriode.fromJson(Map<String, dynamic> json) {
    return KehadiranPeriode(
      tanggal: json['tanggal'],
      jumlahKehadiran: json['jumlah_kehadiran'] ?? 0,
      subuh: json['Subuh'] ?? 0,
      dzuhur: json['Dzuhur'] ?? 0,
      ashar: json['Ashar'] ?? 0,
      maghrib: json['Maghrib'] ?? 0,
      isya: json['Isya'] ?? 0,
      jamMasukSubuh: json['jam_masuk_subuh'],
      jamMasukDzuhur: json['jam_masuk_dzuhur'],
      jamMasukAshar: json['jam_masuk_ashar'],
      jamMasukMaghrib: json['jam_masuk_maghrib'],
      jamMasukIsya: json['jam_masuk_isya'],
      jamKeluarSubuh: json['jam_keluar_subuh'],
      jamKeluarDzuhur: json['jam_keluar_dzuhur'],
      jamKeluarAshar: json['jam_keluar_ashar'],
      jamKeluarMaghrib: json['jam_keluar_maghrib'],
      jamKeluarIsya: json['jam_keluar_isya'],
    );
  }
}

// models/kehadiran_tahunan.dart
class KehadiranTahunan {
  final String bulan;
  final int totalKehadiran;
  final int subuh;
  final int dzuhur;
  final int ashar;
  final int maghrib;
  final int isya;

  KehadiranTahunan({
    required this.bulan,
    required this.totalKehadiran,
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory KehadiranTahunan.fromJson(Map<String, dynamic> json) {
    return KehadiranTahunan(
      bulan: json['bulan'],
      totalKehadiran: json['total_kehadiran'] ?? 0,
      subuh: json['subuh'] ?? 0,
      dzuhur: json['dzuhur'] ?? 0,
      ashar: json['ashar'] ?? 0,
      maghrib: json['maghrib'] ?? 0,
      isya: json['isya'] ?? 0,
    );
  }
}