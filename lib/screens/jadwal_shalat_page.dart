import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
    context.read<JadwalShalatCubit>().getJadwalShalat(selectedCity, selectedCountry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: Text('Jadwal Shalat', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: const TanggalCard(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  DropdownLokasi(
                    onCitySelected: (city) {
                      setState(() => selectedCity = city);
                      context.read<JadwalShalatCubit>().getJadwalShalat(selectedCity, selectedCountry);
                    },
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<JadwalShalatCubit, JadwalShalatModel?>(
                    builder: (context, jadwal) {
                      if (jadwal == null) {
                        return const Center(child: CircularProgressIndicator(color: Colors.teal));
                      }
                      return JadwalCard(jadwal: jadwal, namaDaerah: selectedCity);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
