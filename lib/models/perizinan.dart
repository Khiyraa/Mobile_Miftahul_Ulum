class Perizinan {
  final String id;
  final String idSantri;
  final String jenisPerizinan;
  final String alasan;
  final String waktu;
  final String status;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Perizinan({
    required this.id,
    required this.idSantri,
    required this.jenisPerizinan,
    required this.alasan,
    required this.waktu,
    required this.status,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Perizinan.fromJson(Map<String, dynamic> json) {
    return Perizinan(
      id: json['id']?.toString() ?? '',
      idSantri: json['id_santri']?.toString() ?? '',
      jenisPerizinan: json['jenis_perizinan']?.toString() ?? '',
      alasan: json['alasan']?.toString() ?? '',
      waktu: json['waktu']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      keterangan: json['keterangan']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_santri': idSantri,
      'jenis_perizinan': jenisPerizinan,
      'alasan': alasan,
      'waktu': waktu,
      'status': status,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
