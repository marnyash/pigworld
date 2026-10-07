import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../security/authorization/permissions.dart';
import '../../../../security/authorization/roles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../notifications/data/notifications_api.dart';
import '../../../health/presentation/providers/health_providers.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../providers/farm_overview_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Timer? _notificationRefreshTimer;

  @override
  void initState() {
    super.initState();
    _notificationRefreshTimer = Timer.periodic(const Duration(seconds: 30), (
      _,
    ) {
      ref.invalidate(notificationsProvider);
    });
  }

  @override
  void dispose() {
    _notificationRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
    final healthOverview = ref.watch(healthOverviewProvider);
    final pregnantCount = session?.selectedFarm?.pregnantPigCount ?? 0;
    final vaccinatedCount = healthOverview.valueOrNull?['vaccinated'] ?? 0;
    final notifications =
        ref.watch(notificationsProvider).valueOrNull ??
        const <FarmNotification>[];
    FarmNotification? crmMessage;
    for (final notification in notifications) {
      if (notification.type == 'crm_message') {
        crmMessage = notification;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.openMenu,
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(farmName, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: l10n.openNotifications,
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(AppRoutes.notifications),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.jpeg'),
                fit: BoxFit.cover,
                opacity: 0.07,
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              if (farmId == null) return;
              ref.invalidate(farmOverviewProvider(farmId));
              ref.invalidate(notificationsProvider);
              await ref.read(farmOverviewProvider(farmId).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.pagePadding),
              children: [
                if (overview.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                if (overview.hasError)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.spacingMedium,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: AppDimensions.spacingMedium),
                          Expanded(child: Text(l10n.overviewLoadFailed)),
                          TextButton(
                            onPressed: farmId == null
                                ? null
                                : () => ref.invalidate(
                                    farmOverviewProvider(farmId),
                                  ),
                            child: Text(l10n.retry),
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
                            color: AppColors.inverseText.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            l10n.farmOverview,
                            style: TextStyle(
                              color: AppColors.inverseText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${l10n.goodDay}, $firstName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppColors.inverseText),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          crmMessage?.body ?? l10n.farmRunningSmoothly,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.inverseMutedText),
                        ),
                      ],
                    ),
                  ),
                ),
                if (notifications.any((item) => !item.isRead)) ...[
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _NotificationBanner(
                    notification: notifications.firstWhere(
                      (item) => !item.isRead,
                    ),
                    onOpen: () => context.go(AppRoutes.notifications),
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingLarge),
                _HerdStatusCard(
                  pregnant: pregnantCount,
                  vaccinated: vaccinatedCount,
                  active: herdCount,
                ),
                const SizedBox(height: AppDimensions.spacingLarge),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppDimensions.spacingMedium,
                  crossAxisSpacing: AppDimensions.spacingMedium,
                  childAspectRatio: 1.0,
                  children: [
                    _StatCard(
                      icon: Icons.pets_outlined,
                      label: l10n.herdSize,
                      value: '$herdCount',
                      color: AppColors.primaryGreen,
                    ),
                    _StatCard(
                      icon: Icons.grass_outlined,
                      label: l10n.feedStock,
                      value:
                          overview.valueOrNull?['feed_stock']?.toString() ??
                          '—',
                      color: AppColors.warning,
                    ),
                    _StatCard(
                      icon: Icons.checklist_outlined,
                      label: l10n.tasksDue,
                      value:
                          overview.valueOrNull?['tasks_due']?.toString() ?? '—',
                      color: AppColors.danger,
                    ),
                    _StatCard(
                      icon: Icons.point_of_sale_outlined,
                      label: l10n.salesThisWeek,
                      value:
                          overview.valueOrNull?['sales_this_week']
                              ?.toString() ??
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
                _SectionHeader(title: l10n.quickActions),
                const SizedBox(height: AppDimensions.spacingMedium),
                Wrap(
                  spacing: AppDimensions.spacingMedium,
                  runSpacing: AppDimensions.spacingMedium,
                  children: [
                    _QuickAction(
                      icon: Icons.pets_outlined,
                      label: l10n.herd,
                      color: AppColors.pigPink,
                      onTap: () => context.go(AppRoutes.herd),
                    ),
                    _QuickAction(
                      icon: Icons.grass_outlined,
                      label: l10n.feed,
                      color: AppColors.leaf,
                      onTap: () => context.go(AppRoutes.feed),
                    ),
                    _QuickAction(
                      icon: Icons.check_circle_outline,
                      label: l10n.tasks,
                      color: AppColors.warmGold,
                      onTap: () => context.go(AppRoutes.tasks),
                    ),
                    if (isAdmin ||
                        (role != null &&
                            RolePermissions.can(
                              role,
                              AppPermission.manageFinance,
                            )))
                      _QuickAction(
                        icon: Icons.account_balance_wallet_outlined,
                        label: l10n.finance,
                        color: AppColors.warmGold,
                        onTap: () => context.go(AppRoutes.finance),
                      ),
                    if (isAdmin ||
                        (role != null &&
                            RolePermissions.can(
                              role,
                              AppPermission.manageSales,
                            )))
                      _QuickAction(
                        icon: Icons.groups_outlined,
                        label: l10n.customers,
                        color: AppColors.info,
                        onTap: () => context.go(AppRoutes.crm),
                      ),
                    _QuickAction(
                      icon: Icons.support_agent_outlined,
                      label: l10n.customerSupport,
                      color: AppColors.violet,
                      onTap: () => context.go(AppRoutes.support),
                    ),
                    if (isAdmin)
                      _QuickAction(
                        icon: Icons.group_outlined,
                        label: l10n.teamAndPolicies,
                        color: AppColors.aqua,
                        onTap: () => context.go(AppRoutes.farmManagement),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingLarge),
                _SectionHeader(title: l10n.recentActivity),
                const SizedBox(height: AppDimensions.spacingMedium),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.12,
                            ),
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
        ],
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
            child: const Icon(Icons.pets, color: AppColors.inverseText),
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
                Text(
                  details.join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _HerdStatusCard extends StatelessWidget {
  const _HerdStatusCard({
    required this.pregnant,
    required this.vaccinated,
    required this.active,
  });

  final int pregnant;
  final int vaccinated;
  final int active;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _HerdStatusMetric(
        label: AppLocalizations.of(context)!.pregnant,
        value: '$pregnant',
        color: AppColors.pigPink,
      ),
      _HerdStatusMetric(
        label: AppLocalizations.of(context)!.vaccinated,
        value: '$vaccinated',
        color: AppColors.info,
      ),
      _HerdStatusMetric(
        label: AppLocalizations.of(context)!.active,
        value: '$active',
        color: AppColors.success,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregnancy & vaccination',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              children: metrics
                  .map(
                    (metric) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: metric.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metric.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              metric.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HerdStatusMetric {
  const _HerdStatusMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
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
              child: Icon(icon, color: AppColors.inverseText, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

class _NotificationBanner extends StatelessWidget {
  const _NotificationBanner({required this.notification, required this.onOpen});

  final FarmNotification notification;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final color = switch (notification.severity) {
      'warning' => AppColors.warning,
      'danger' => AppColors.danger,
      'success' => AppColors.success,
      _ => AppColors.info,
    };
    return Card(
      color: color.withValues(alpha: 0.12),
      child: ListTile(
        leading: Icon(Icons.notifications_active_outlined, color: color),
        title: Text(notification.title),
        subtitle: Text(
          notification.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpen,
      ),
    );
  }
}
