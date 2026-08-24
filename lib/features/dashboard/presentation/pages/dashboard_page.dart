import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/components/bottom_navigation.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).valueOrNull;
    final firstName = session?.user.name.split(' ').first ?? 'there';
    final farmName = session?.selectedFarm?.name ?? 'Pig World Smart';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(farmName),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(AppRoutes.notifications),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          Text(
            'Good day, $firstName',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Here is how your farm is doing today.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.spacingMedium,
            crossAxisSpacing: AppDimensions.spacingMedium,
            childAspectRatio: 1.3,
            children: const [
              _StatCard(
                icon: Icons.pets_outlined,
                label: 'Herd size',
                value: '—',
                color: AppColors.primaryGreen,
              ),
              _StatCard(
                icon: Icons.grass_outlined,
                label: 'Feed stock',
                value: '—',
                color: AppColors.warning,
              ),
              _StatCard(
                icon: Icons.checklist_outlined,
                label: 'Tasks due',
                value: '—',
                color: AppColors.danger,
              ),
              _StatCard(
                icon: Icons.point_of_sale_outlined,
                label: 'Sales this week',
                value: '—',
                color: AppColors.deepGreen,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.spacingMedium),
          Wrap(
            spacing: AppDimensions.spacingMedium,
            runSpacing: AppDimensions.spacingMedium,
            children: [
              _QuickAction(
                icon: Icons.pets_outlined,
                label: 'Herd',
                onTap: () => context.go(AppRoutes.herd),
              ),
              _QuickAction(
                icon: Icons.grass_outlined,
                label: 'Feed',
                onTap: () => context.go(AppRoutes.feed),
              ),
              _QuickAction(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Finance',
                onTap: () => context.go(AppRoutes.finance),
              ),
              _QuickAction(
                icon: Icons.support_agent_outlined,
                label: 'Support',
                onTap: () => context.go(AppRoutes.support),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text(
            'Recent activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Row(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    color: AppColors.text.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  const Expanded(
                    child: Text(
                      'No recent activity yet. Updates from your farm will appear here.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
