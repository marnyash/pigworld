import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/components/bottom_navigation.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).valueOrNull;
    final user = session?.user;
    final farm = session?.selectedFarm ?? session?.farms.firstOrNull;
    final initials = (user?.name.isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.pagePadding,
          AppDimensions.pagePadding,
          32,
        ),
        children: [
          Card(
            color: AppColors.deepGreen,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: Text(
                      initials,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Your profile',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Sign in to view your account',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _roleLabel(user?.role.name),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text('Farm workspace', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.agriculture_outlined,
                color: AppColors.primaryGreen,
              ),
              title: Text(farm?.name ?? 'No farm selected'),
              subtitle: Text(
                farm == null
                    ? 'Complete setup to connect a farm'
                    : '${session?.farms.length ?? 0} farm${(session?.farms.length ?? 0) == 1 ? '' : 's'} available',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppRoutes.farmSelection),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text('Account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(AppRoutes.notifications),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support_agent_outlined),
                  title: const Text('Customer Care'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(AppRoutes.support),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(logoutUseCaseProvider)();
              ref.read(authProvider.notifier).clearSession();
              if (context.mounted) context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String? role) => switch (role) {
    'farmOwner' => 'Farm owner',
    'farmManager' => 'Farm manager',
    'farmWorker' => 'Farm worker',
    _ => 'Farm member',
  };
}
