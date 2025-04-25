import 'package:flutter/material.dart';

class DropdownLokasi extends StatefulWidget {
  final Function(String) onCitySelected;

  DropdownLokasi({required this.onCitySelected});

  @override
  _DropdownLokasiState createState() => _DropdownLokasiState();
}

class _DropdownLokasiState extends State<DropdownLokasi> {
  // Daftar Provinsi di Pulau Jawa
  final Map<String, List<String>> provinsiKota = {
    "DKI Jakarta": ["Jakarta Pusat", "Jakarta Barat", "Jakarta Selatan", "Jakarta Timur", "Jakarta Utara"],
    "Jawa Barat": ["Bandung", "Bekasi", "Bogor", "Depok", "Cirebon"],
    "Jawa Tengah": ["Semarang", "Solo", "Magelang", "Tegal", "Pekalongan"],
    "DI Yogyakarta": ["Yogyakarta", "Bantul", "Sleman", "Gunungkidul", "Kulon Progo"],
    "Jawa Timur": ["Surabaya", "Malang", "Kediri", "Jember", "Madiun"],
    "Banten": ["Serang", "Tangerang", "Cilegon", "Lebak", "Pandeglang"],
  };

  // Provinsi & Kota yang dipilih
  String selectedProvinsi = "DKI Jakarta";
  String selectedCity = "Jakarta Pusat";

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Dropdown untuk Provinsi
        Expanded(
          child: DropdownButton<String>(
            value: selectedProvinsi,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedProvinsi = value;
                  selectedCity = provinsiKota[value]![0]; // Reset kota ke yang pertama
                });
                widget.onCitySelected(selectedCity);
              }
            },
            items: provinsiKota.keys.map((provinsi) {
              return DropdownMenuItem(value: provinsi, child: Text(provinsi));
            }).toList(),
          ),
        ),

        SizedBox(width: 16), // Spacer agar ada jarak

        // Dropdown untuk Kota
        Expanded(
          child: DropdownButton<String>(
            value: selectedCity,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCity = value;
                });
                widget.onCitySelected(value);
              }
            },
            items: provinsiKota[selectedProvinsi]!.map((city) {
              return DropdownMenuItem(value: city, child: Text(city));
            }).toList(),
          ),
        ),
      ],
    );
  }
}
