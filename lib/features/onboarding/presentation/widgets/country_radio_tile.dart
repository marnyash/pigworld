import 'package:flutter/material.dart';

class CountryRadioTile extends StatelessWidget {
  const CountryRadioTile({required this.country, super.key});

  final String country;

  @override
  Widget build(BuildContext context) => Card(
        child: RadioListTile<String>(value: country, title: Text(country), secondary: const Icon(Icons.public_outlined)),
      );
}