import 'package:flutter/material.dart';

class CountryRadioTile extends StatelessWidget {
  const CountryRadioTile({required this.country, super.key});

  final String country;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.surface,
    child: RadioListTile<String>(
      value: country.substring(country.indexOf('  ') + 2),
      title: Text(country),
      secondary: Icon(
        Icons.public_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
  );
}
