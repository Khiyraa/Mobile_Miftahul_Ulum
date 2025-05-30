import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/jadwal_shalat_cubit.dart';
import '../repositories/jadwal_shalat_repository.dart';
import '../widgets/tanggal_card.dart';
import '../widgets/dropdown_lokasi.dart';
import '../widgets/jadwal_card.dart';
import '../models/jadwal_shalat_model.dart';

class JadwalShalatPage extends StatelessWidget {
  const JadwalShalatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JadwalShalatCubit(JadwalShalatRepository()),
      child: const JadwalShalatView(),
    );
  }
}

class JadwalShalatView extends StatefulWidget {
  const JadwalShalatView({super.key});

  @override
  _JadwalShalatViewState createState() => _JadwalShalatViewState();
}

class _JadwalShalatViewState extends State<JadwalShalatView> {
  String selectedCity = "Jakarta Pusat";
  String selectedCountry = "Indonesia";

  @override
  void initState() {
    super.initState();
    context.read<JadwalShalatCubit>().getJadwalShalat(
      selectedCity,
      selectedCountry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Tanggal Card with spacing
                const TanggalCard(),
                const SizedBox(height: 30),
                
                // Dropdown Lokasi with spacing
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownLokasi(
                    onCitySelected: (city) {
                      setState(() {
                        selectedCity = city;
                      });
                      context.read<JadwalShalatCubit>().getJadwalShalat(
                        selectedCity,
                        selectedCountry,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Jadwal Card with BlocBuilder
                BlocBuilder<JadwalShalatCubit, JadwalShalatModel?>(
                  builder: (context, jadwal) {
                    if (jadwal == null) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return JadwalCard(
                      jadwal: jadwal, 
                      namaDaerah: selectedCity,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}