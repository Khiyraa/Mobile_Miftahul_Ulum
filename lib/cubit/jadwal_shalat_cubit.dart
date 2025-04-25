import 'package:bloc/bloc.dart';
import '../models/jadwal_shalat_model.dart';
import '../repositories/jadwal_shalat_repository.dart';

class JadwalShalatCubit extends Cubit<JadwalShalatModel?> {
  final JadwalShalatRepository repository;

  JadwalShalatCubit(this.repository) : super(null);

  Future<void> getJadwalShalat(String city, String country) async {
    try {
      final jadwal = await repository.fetchJadwalShalat(city, country);
      emit(jadwal);
    } catch (e) {
      emit(null);
    }
  }
}
