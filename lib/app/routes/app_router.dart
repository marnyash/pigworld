import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/herd/presentation/pages/herd_page.dart';
import '../../features/health/presentation/pages/health_page.dart';
import '../../features/breeding/presentation/pages/breeding_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/feed/presentation/pages/inventory_page.dart';
import '../../features/growth/presentation/pages/growth_page.dart';
import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/about/presentation/pages/about_page.dart';
import '../../features/settings/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/farm_selection_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/session_expired_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/create_account_page.dart';
import '../../features/onboarding/presentation/pages/country_page.dart';
import '../../features/onboarding/presentation/pages/account_type_page.dart';
import '../../features/onboarding/presentation/pages/herd_setup_page.dart';
import '../../features/onboarding/presentation/pages/subscription_page.dart';
import '../../features/onboarding/presentation/pages/language_page.dart';
import '../../features/onboarding/presentation/pages/permissions_page.dart';
import '../../features/settings/presentation/pages/farm_management_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../shared/components/bottom_navigation.dart';
import '../../shared/widgets/module_page.dart';
import '../../shared/widgets/profile_avatar.dart';
import '../../app/theme/app_colors.dart';
import 'app_routes.dart';
import 'route_guard.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: RouteGuard.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.permissions,
        builder: (context, state) => const PermissionsPage(),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => const LanguagePage(),
      ),
      GoRoute(
        path: AppRoutes.country,
        builder: (context, state) => const CountryPage(),
      ),
      GoRoute(
        path: AppRoutes.accountType,
        builder: (context, state) => const AccountTypePage(),
      ),
      GoRoute(
        path: AppRoutes.herdSetup,
        builder: (context, state) => const HerdSetupPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.createAccount,
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionPage(),
      ),
      GoRoute(
        path: AppRoutes.farmSelection,
        builder: (context, state) => const FarmSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.sessionExpired,
        builder: (context, state) =>
            SessionExpiredPage(onSignIn: () => context.go(AppRoutes.login)),
      ),
      ShellRoute(
        builder: (context, state, child) => NavigationShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.herd,
            builder: (context, state) => const HerdPage(),
          ),
          GoRoute(
            path: AppRoutes.health,
            builder: (context, state) => const HealthPage(),
          ),
          GoRoute(
            path: AppRoutes.breeding,
            builder: (context, state) => const BreedingPage(),
          ),
          GoRoute(
            path: AppRoutes.feed,
            builder: (context, state) => const FeedPage(),
          ),
          GoRoute(
            path: AppRoutes.finance,
            builder: (context, state) => const FinancePage(),
          ),
          GoRoute(
            path: AppRoutes.growth,
            builder: (context, state) => const GrowthPage(),
          ),
          GoRoute(
            path: AppRoutes.salesAndExpenses,
            builder: (context, state) => const SalesPage(),
          ),
          GoRoute(
            path: AppRoutes.inventory,
            builder: (context, state) => const InventoryPage(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.workers,
            builder: (context, state) => const FarmManagementPage(),
          ),
          GoRoute(
            path: AppRoutes.crm,
            builder: (context, state) => const ModulePage(
              title: 'Customers',
              description:
                  'Customer relationship management now lives in the standalone CRM web app.',
              icon: Icons.groups_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: AppRoutes.farmManagement,
            builder: (context, state) => const FarmManagementPage(),
          ),
          GoRoute(
            path: AppRoutes.support,
            builder: (context, state) => const SupportPage(),
          ),
          GoRoute(
            path: AppRoutes.about,
            builder: (context, state) => const AboutPage(),
          ),
        ],
      ),
    ],
  );
}

class NavigationShell extends StatelessWidget {
  const NavigationShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = switch (location) {
      AppRoutes.herd => 1,
      AppRoutes.feed => 2,
      AppRoutes.profile => 3,
      _ => 0,
    };
    return Scaffold(
      key: navigationScaffoldKey,
      drawer: const _AppDrawer(),
      body: child,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: selectedIndex,
        onSelected: (index) => context.go(
          [
            AppRoutes.home,
            AppRoutes.herd,
            AppRoutes.feed,
            AppRoutes.profile,
          ][index],
        ),
      ),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).valueOrNull;
    final user = session?.user;
    final farmName = session?.selectedFarm?.name ?? 'Pig World Smart';
    final initials = (user?.name.isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : '?';
    return Drawer(
      width: 300,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              decoration: const BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(initials: initials, radius: 26),
                  const SizedBox(height: 14),
                  Text(
                    'Pig World Smart',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    farmName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
                children: [
                  const _DrawerSectionLabel('Farm management'),
                  _ListTile(
                    icon: Icons.home_outlined,
                    title: 'Dashboard',
                    route: AppRoutes.home,
                  ),
                  _ListTile(
                    icon: Icons.pets_outlined,
                    title: 'Herd',
                    route: AppRoutes.herd,
                  ),
                  _ListTile(
                    icon: Icons.restaurant_outlined,
                    title: 'Feed',
                    route: AppRoutes.feed,
                  ),
                  _ListTile(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Health',
                    route: AppRoutes.health,
                  ),
                  _ListTile(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Growth',
                    route: AppRoutes.growth,
                  ),
                  _ListTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Inventory',
                    route: AppRoutes.inventory,
                  ),
                  _ListTile(
                    icon: Icons.favorite_outline,
                    title: 'Breeding',
                    route: AppRoutes.breeding,
                  ),
                  _ListTile(
                    icon: Icons.point_of_sale_outlined,
                    title: 'Sales',
                    route: AppRoutes.salesAndExpenses,
                  ),
                  const _DrawerSectionLabel('Workspace'),
                  _ListTile(
                    icon: Icons.assessment_outlined,
                    title: 'Reports',
                    route: AppRoutes.reports,
                  ),
                  _ListTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Customer Support',
                    route: AppRoutes.support,
                  ),
                  _ListTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    route: AppRoutes.settings,
                  ),
                  _ListTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    route: AppRoutes.about,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
                  _LogoutTile(
                    onLogout: () async {
                      await ref.read(logoutUseCaseProvider)();
                      ref.read(authProvider.notifier).clearSession();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.icon,
    required this.title,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    final selected = GoRouterState.of(context).uri.path == route;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        dense: true,
        minLeadingWidth: 28,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: selected,
        selectedTileColor: AppColors.primaryGreen.withValues(alpha: 0.11),
        leading: Icon(
          icon,
          color: selected ? AppColors.deepGreen : AppColors.mutedText,
          size: 22,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: selected ? AppColors.deepGreen : AppColors.text,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.primaryGreen,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      ),
    ),
  );
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    tileColor: Colors.red.withValues(alpha: 0.06),
    leading: const Icon(Icons.logout, color: Colors.red),
    title: const Text('Logout'),
    textColor: Colors.red,
    onTap: onLogout,
  );
}
