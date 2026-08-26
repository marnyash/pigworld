import 'package:flutter/material.dart';
import '../../../../shared/widgets/module_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});
  @override
  Widget build(BuildContext context) => const ModulePage(
    title: 'Feed inventory',
    description: 'Review available feed ingredients and stock levels.',
    icon: Icons.inventory_2_outlined,
  );
}
