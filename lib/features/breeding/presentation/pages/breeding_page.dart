import 'package:flutter/material.dart';
import '../../../../shared/widgets/module_page.dart';

class BreedingPage extends StatelessWidget {
  const BreedingPage({super.key});
  @override
  Widget build(BuildContext context) => const ModulePage(title: 'Breeding', description: 'Manage mating, pregnancy, and farrowing records.', icon: Icons.favorite_outline);
}
