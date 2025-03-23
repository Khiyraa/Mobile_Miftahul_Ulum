import 'package:flutter/material.dart';

class DropdownLokasi extends StatelessWidget {
  final Function(String) onCitySelected;

  DropdownLokasi({required this.onCitySelected});

  final List<String> cities = ["Jakarta", "Surabaya", "Bandung"];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: cities[0],
      onChanged: (value) {
        if (value != null) {
          onCitySelected(value);
        }
      },
      items: cities.map((city) {
        return DropdownMenuItem(value: city, child: Text(city));
      }).toList(),
    );
  }
}
