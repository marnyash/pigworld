import 'package:flutter/material.dart';

class ModulePage extends StatelessWidget {
  const ModulePage({required this.title, required this.description, this.icon = Icons.dashboard_outlined, super.key});

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
