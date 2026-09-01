import 'package:flutter/material.dart';

class CountryRadioTile extends StatelessWidget {
  const CountryRadioTile({
    required this.country,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String country;
  final bool selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Card(
    color: selected
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surface,
    child: RadioListTile<String>(
      value: country.substring(country.indexOf('  ') + 2),
      groupValue: selected ? country.substring(country.indexOf('  ') + 2) : null,
      title: Text(country),
      secondary: Icon(
        Icons.public_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    ),
  );
}
