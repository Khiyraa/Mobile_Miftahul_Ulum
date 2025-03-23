class JadwalShalatModel {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  JadwalShalatModel({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory JadwalShalatModel.fromJson(Map<String, dynamic> json) {
    return JadwalShalatModel(
      fajr: json['Fajr'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
    );
  }
}
