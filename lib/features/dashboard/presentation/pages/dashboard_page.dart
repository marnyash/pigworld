import '../../../../shared/widgets/module_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => const ModulePage(title: 'Dashboard', description: 'Track herd, feed, tasks, sales, and farm performance at a glance.', icon: Icons.dashboard_outlined);
}
