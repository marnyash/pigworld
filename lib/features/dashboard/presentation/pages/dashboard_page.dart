import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../security/authorization/permissions.dart';
import '../../../../security/authorization/roles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../providers/farm_overview_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).valueOrNull;
    final farmId = session?.selectedFarm?.id;
    final overview = farmId == null
        ? const AsyncValue<Map<String, dynamic>>.data({})
        : ref.watch(farmOverviewProvider(farmId));
    final firstName = session?.user.name.split(' ').first ?? 'there';
    final farmName = session?.selectedFarm?.name ?? 'Pig World Smart';
    final registeredHerdCount = session?.selectedFarm?.registeredHerdCount ?? 0;
    final liveHerdCount = overview.valueOrNull?['herd_count'] as num?;
    final herdCount = liveHerdCount == null
        ? registeredHerdCount
        : liveHerdCount.toInt() > registeredHerdCount
        ? liveHerdCount.toInt()
        : registeredHerdCount;
    final role = session?.user.role;
    final isAdmin = role == UserRole.farmOwner;

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
      body: RefreshIndicator(
        onRefresh: () async {
          if (farmId == null) return;
          ref.invalidate(farmOverviewProvider(farmId));
          await ref.read(farmOverviewProvider(farmId).future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: [
            if (overview.isLoading) const LinearProgressIndicator(minHeight: 2),
            if (overview.hasError)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: AppDimensions.spacingMedium),
                      const Expanded(
                        child: Text(
                          'We could not load the latest farm overview.',
                        ),
                      ),
                      TextButton(
                        onPressed: farmId == null
                            ? null
                            : () =>
                                  ref.invalidate(farmOverviewProvider(farmId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            Card(
              color: AppColors.deepGreen,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Farm overview',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Good day, $firstName',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your farm is running smoothly today.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDimensions.spacingMedium,
              crossAxisSpacing: AppDimensions.spacingMedium,
              childAspectRatio: 1.18,
              children: [
                _StatCard(
                  icon: Icons.pets_outlined,
                  label: 'Herd size',
                  value: '$herdCount',
                  color: AppColors.primaryGreen,
                ),
                _StatCard(
                  icon: Icons.grass_outlined,
                  label: 'Feed stock',
                  value: overview.valueOrNull?['feed_stock']?.toString() ?? '—',
                  color: AppColors.warning,
                ),
                _StatCard(
                  icon: Icons.checklist_outlined,
                  label: 'Tasks due',
                  value: overview.valueOrNull?['tasks_due']?.toString() ?? '—',
                  color: AppColors.danger,
                ),
                _StatCard(
                  icon: Icons.point_of_sale_outlined,
                  label: 'Sales this week',
                  value:
                      overview.valueOrNull?['sales_this_week']?.toString() ??
                      '—',
                  color: AppColors.deepGreen,
                ),
              ],
            ),
            if (registeredHerdCount > 0) ...[
              const SizedBox(height: AppDimensions.spacingMedium),
              _RegisteredHerdBanner(
                motherPigs: session?.selectedFarm?.motherPigCount ?? 0,
                piglets: session?.selectedFarm?.registeredPigletCount ?? 0,
                pregnantPigs: session?.selectedFarm?.pregnantPigCount ?? 0,
              ),
            ],
            const SizedBox(height: AppDimensions.spacingLarge),
            _SectionHeader(title: 'Quick actions'),
            const SizedBox(height: AppDimensions.spacingMedium),
            Wrap(
              spacing: AppDimensions.spacingMedium,
              runSpacing: AppDimensions.spacingMedium,
              children: [
                _QuickAction(
                  icon: Icons.pets_outlined,
                  label: 'Herd',
                  color: AppColors.pigPink,
                  onTap: () => context.go(AppRoutes.herd),
                ),
                _QuickAction(
                  icon: Icons.grass_outlined,
                  label: 'Feed',
                  color: AppColors.leaf,
                  onTap: () => context.go(AppRoutes.feed),
                ),
                if (isAdmin ||
                    (role != null &&
                        RolePermissions.can(role, AppPermission.manageFinance)))
                  _QuickAction(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Finance',
                    color: AppColors.warmGold,
                    onTap: () => context.go(AppRoutes.finance),
                  ),
                if (isAdmin ||
                    (role != null &&
                        RolePermissions.can(role, AppPermission.manageSales)))
                  _QuickAction(
                    icon: Icons.groups_outlined,
                    label: 'Customers',
                    color: AppColors.info,
                    onTap: () => context.go(AppRoutes.crm),
                  ),
                _QuickAction(
                  icon: Icons.support_agent_outlined,
                  label: 'Support',
                  color: AppColors.violet,
                  onTap: () => context.go(AppRoutes.support),
                ),
                if (isAdmin)
                  _QuickAction(
                    icon: Icons.group_outlined,
                    label: 'Team & policies',
                    color: AppColors.aqua,
                    onTap: () => context.go(AppRoutes.farmManagement),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            _SectionHeader(title: 'Recent activity'),
            const SizedBox(height: AppDimensions.spacingMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inbox_outlined,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMedium),
                    Expanded(
                      child: Text(
                        overview.valueOrNull?['recent_activity'] is List &&
                                (overview.valueOrNull!['recent_activity']
                                        as List)
                                    .isNotEmpty
                            ? 'Recent farm activity is available in the activity view.'
                            : 'No recent activity recorded yet.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisteredHerdBanner extends StatelessWidget {
  const _RegisteredHerdBanner({
    required this.motherPigs,
    required this.piglets,
    required this.pregnantPigs,
  });

  final int motherPigs;
  final int piglets;
  final int pregnantPigs;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (motherPigs > 0) '$motherPigs mother pigs',
      if (piglets > 0) '$piglets piglets',
      if (pregnantPigs > 0) '$pregnantPigs pregnant',
    ];
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.pigPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: Colors.white),
          ),
          const SizedBox(width: AppDimensions.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your registered herd',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(details.join(' • ')),
              ],
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
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      onTap: onTap,
      child: Container(
        width: 94,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(AppDimensions.radius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [Text(title, style: Theme.of(context).textTheme.titleLarge)],
  );
}
