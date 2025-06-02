import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class DropdownLokasi extends StatefulWidget {
  final Function(String) onCitySelected;

  const DropdownLokasi({super.key, required this.onCitySelected});

  @override
  _DropdownLokasiState createState() => _DropdownLokasiState();
}

class _DropdownLokasiState extends State<DropdownLokasi> {
  // Daftar Provinsi di Pulau Jawa
  final Map<String, List<String>> provinsiKota = {
    "DKI Jakarta": [
      "Jakarta Pusat",
      "Jakarta Barat",
      "Jakarta Selatan",
      "Jakarta Timur",
      "Jakarta Utara",
    ],
    "Jawa Barat": ["Bandung", "Bekasi", "Bogor", "Depok", "Cirebon"],
    "Jawa Tengah": ["Semarang", "Solo", "Magelang", "Tegal", "Pekalongan"],
    "DI Yogyakarta": [
      "Yogyakarta",
      "Bantul",
      "Sleman",
      "Gunungkidul",
      "Kulon Progo",
    ],
    "Jawa Timur": ["Surabaya", "Malang", "Kediri", "Jember", "Madiun"],
    "Banten": ["Serang", "Tangerang", "Cilegon", "Lebak", "Pandeglang"],
  };

  // Provinsi & Kota yang dipilih
  String selectedProvinsi = "DKI Jakarta";
  String selectedCity = "Jakarta Pusat";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon for location
          const Icon(Icons.location_on_outlined, color: Colors.blue),
          const SizedBox(width: 12),
          
          // Dropdown untuk Provinsi
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                value: selectedProvinsi,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedProvinsi = value;
                      selectedCity = provinsiKota[value]![0];
                    });
                    widget.onCitySelected(selectedCity);
                  }
                },
                items: provinsiKota.keys.map((provinsi) {
                  return DropdownMenuItem(
                    value: provinsi,
                    child: Text(
                      provinsi,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 40,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                ),
              ),
            ),
          ),
          
          const VerticalDivider(thickness: 1, width: 16),
          
          // Dropdown untuk Kota
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
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
                  return DropdownMenuItem(
                    value: city,
                    child: Text(
                      city,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 40,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}