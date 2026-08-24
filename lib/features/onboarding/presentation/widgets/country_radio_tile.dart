import 'package:flutter/material.dart';

class CountryRadioTile extends StatelessWidget {
  const CountryRadioTile({required this.country, required this.selected, required this.onChanged, super.key});

  final String country;
  final bool selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Card(
        child: RadioListTile<String>(value: country, groupValue: selected ? country : null, onChanged: (_) => onChanged(), title: Text(country), secondary: const Icon(Icons.public_outlined)),
      );
}