import 'package:flutter/material.dart';

class LanguageCard extends StatelessWidget {
  const LanguageCard({required this.flag, required this.nativeName, required this.translation, required this.selected, required this.onTap, super.key});

  final String flag;
  final String nativeName;
  final String translation;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [Text(flag, style: const TextStyle(fontSize: 30)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nativeName, style: Theme.of(context).textTheme.titleMedium), Text(translation)])), if (selected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)]),
          ),
        ),
      );
}