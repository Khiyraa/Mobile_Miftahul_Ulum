class KehadiranMingguan {
  final String tanggal;
  final int jumlahKehadiran;
  final bool subuh;
  final bool dzuhur;
  final bool ashar;
  final bool maghrib;
  final bool isya;

  // Jam masuk dan keluar untuk setiap sholat
  final String? jamMasukSubuh;
  final String? jamKeluarSubuh;
  final String? jamMasukDzuhur;
  final String? jamKeluarDzuhur;
  final String? jamMasukAshar;
  final String? jamKeluarAshar;
  final String? jamMasukMaghrib;
  final String? jamKeluarMaghrib;
  final String? jamMasukIsya;
  final String? jamKeluarIsya;

  KehadiranMingguan({
    required this.tanggal,
    required this.jumlahKehadiran,
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    this.jamMasukSubuh,
    this.jamKeluarSubuh,
    this.jamMasukDzuhur,
    this.jamKeluarDzuhur,
    this.jamMasukAshar,
    this.jamKeluarAshar,
    this.jamMasukMaghrib,
    this.jamKeluarMaghrib,
    this.jamMasukIsya,
    this.jamKeluarIsya,
  });

  factory KehadiranMingguan.fromJson(Map<String, dynamic> json) {
    return KehadiranMingguan(
      tanggal: json['tanggal'] ?? '',
      jumlahKehadiran: json['jumlah_kehadiran'] ?? 0,
      // Cek kehadiran berdasarkan value boolean dari database
      subuh: _parseBool(json['Subuh']),
      dzuhur: _parseBool(json['Dzuhur']),
      ashar: _parseBool(json['Ashar']),
      maghrib: _parseBool(json['Maghrib']),
      isya: _parseBool(json['Isya']),
      // Jam masuk dan keluar (jika ada di response)
      jamMasukSubuh: json['jam_masuk_subuh']?.toString(),
      jamKeluarSubuh: json['jam_keluar_subuh']?.toString(),
      jamMasukDzuhur: json['jam_masuk_dzuhur']?.toString(),
      jamKeluarDzuhur: json['jam_keluar_dzuhur']?.toString(),
      jamMasukAshar: json['jam_masuk_ashar']?.toString(),
      jamKeluarAshar: json['jam_keluar_ashar']?.toString(),
      jamMasukMaghrib: json['jam_masuk_maghrib']?.toString(),
      jamKeluarMaghrib: json['jam_keluar_maghrib']?.toString(),
      jamMasukIsya: json['jam_masuk_isya']?.toString(),
      jamKeluarIsya: json['jam_keluar_isya']?.toString(),
    );
  }

  // Helper method untuk parsing boolean dari berbagai format
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  // Helper method untuk mendapatkan jam masuk berdasarkan sholat
  String? getJamMasuk(String sholat) {
    switch (sholat.toLowerCase()) {
      case 'subuh':
        return jamMasukSubuh;
      case 'dzuhur':
        return jamMasukDzuhur;
      case 'ashar':
        return jamMasukAshar;
      case 'maghrib':
        return jamMasukMaghrib;
      case 'isya':
        return jamMasukIsya;
      default:
        return null;
    }
  }

  // Helper method untuk mendapatkan jam keluar berdasarkan sholat
  String? getJamKeluar(String sholat) {
    switch (sholat.toLowerCase()) {
      case 'subuh':
        return jamKeluarSubuh;
      case 'dzuhur':
        return jamKeluarDzuhur;
      case 'ashar':
        return jamKeluarAshar;
      case 'maghrib':
        return jamKeluarMaghrib;
      case 'isya':
        return jamKeluarIsya;
      default:
        return null;
    }
  }

  // Helper method untuk cek apakah hadir pada sholat tertentu
  bool isAttended(String sholat) {
    switch (sholat.toLowerCase()) {
      case 'subuh':
        return subuh;
      case 'dzuhur':
        return dzuhur;
      case 'ashar':
        return ashar;
      case 'maghrib':
        return maghrib;
      case 'isya':
        return isya;
      default:
        return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'jumlah_kehadiran': jumlahKehadiran,
      'Subuh': subuh ? 1 : 0,
      'Dzuhur': dzuhur ? 1 : 0,
      'Ashar': ashar ? 1 : 0,
      'Maghrib': maghrib ? 1 : 0,
      'Isya': isya ? 1 : 0,
      'jam_masuk_subuh': jamMasukSubuh,
      'jam_keluar_subuh': jamKeluarSubuh,
      'jam_masuk_dzuhur': jamMasukDzuhur,
      'jam_keluar_dzuhur': jamKeluarDzuhur,
      'jam_masuk_ashar': jamMasukAshar,
      'jam_keluar_ashar': jamKeluarAshar,
      'jam_masuk_maghrib': jamMasukMaghrib,
      'jam_keluar_maghrib': jamKeluarMaghrib,
      'jam_masuk_isya': jamMasukIsya,
      'jam_keluar_isya': jamKeluarIsya,
    };
  }

  @override
  String toString() {
    return 'KehadiranMingguan(tanggal: $tanggal, jumlahKehadiran: $jumlahKehadiran, '
        'subuh: $subuh, dzuhur: $dzuhur, ashar: $ashar, maghrib: $maghrib, isya: $isya)';
  }
}
