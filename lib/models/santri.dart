class Santri {
  final String idSantri;
  final String nama;
  final String tahunAngkatan;
  final String? sidikJari;
  final String status;
  final int idOrtu;
  final Ortu? ortu;

  Santri({
    required this.idSantri,
    required this.nama,
    required this.tahunAngkatan,
    this.sidikJari,
    required this.status,
    required this.idOrtu,
    this.ortu,
  });

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      idSantri: json['id_santri'],
      nama: json['nama'],
      tahunAngkatan: json['tahun_angkatan'],
      sidikJari: json['sidik_jari'],
      status: json['status'],
      idOrtu: json['id_ortu'] ?? 0,
      ortu: json['ortu'] != null ? Ortu.fromJson(json['ortu']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_santri': idSantri,
      'nama': nama,
      'tahun_angkatan': tahunAngkatan,
      'sidik_jari': sidikJari,
      'status': status,
      'id_ortu': idOrtu,
      'ortu': ortu?.toJson(),
    };
  }
}

class Ortu {
  final String namaLengkap;
  final String alamat;
  final String noTelp;

  Ortu({required this.namaLengkap, required this.alamat, required this.noTelp});

  factory Ortu.fromJson(Map<String, dynamic> json) {
    return Ortu(
      namaLengkap: json['nama_lengkap'],
      alamat: json['alamat'],
      noTelp: json['no_telp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nama_lengkap': namaLengkap, 'alamat': alamat, 'no_telp': noTelp};
  }
}
