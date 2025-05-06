import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/jadwal_shalat_model.dart';

class JadwalShalatRepository {
  Future<JadwalShalatModel> fetchJadwalShalat(String city, String country) async {
    final url = Uri.parse('http://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2');
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final timings = jsonData['data']['timings'];
      return JadwalShalatModel.fromJson(timings);
    } else {
      throw Exception('Gagal mengambil data API');
    }
  }
}
