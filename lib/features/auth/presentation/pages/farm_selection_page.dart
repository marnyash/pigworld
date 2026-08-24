import 'package:flutter/material.dart';
import '../../domain/entities/farm.dart';
import '../widgets/farm_card.dart';

class FarmSelectionPage extends StatelessWidget {
  const FarmSelectionPage({required this.farms, required this.onSelected, super.key});
  final List<Farm> farms;
  final ValueChanged<Farm> onSelected;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Select farm')), body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: farms.length, separatorBuilder: (_, index) => const SizedBox(height: 8), itemBuilder: (_, index) => FarmCard(farm: farms[index], onTap: () => onSelected(farms[index]))));
}
