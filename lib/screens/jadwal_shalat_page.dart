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
      child: JadwalShalatView(),
    );
  }
}

class JadwalShalatView extends StatefulWidget {
  const JadwalShalatView({super.key});

  @override
  _JadwalShalatViewState createState() => _JadwalShalatViewState();
}

class _JadwalShalatViewState extends State<JadwalShalatView> {
  String selectedCity = "Jakarta";
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
      // appBar: AppBar(title: Text("Jadwal Shalat")),
      body: Column(
        children: [
          TanggalCard(),
          DropdownLokasi(
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
          BlocBuilder<JadwalShalatCubit, JadwalShalatModel?>(
            builder: (context, jadwal) {
              if (jadwal == null) {
                return Center(child: CircularProgressIndicator());
              }
              return JadwalCard(jadwal: jadwal, namaDaerah: selectedCity);
            },
          ),
        ],
      ),
    );
  }
}
