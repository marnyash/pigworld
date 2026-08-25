import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/herd/presentation/pages/herd_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/settings/presentation/pages/more_page.dart';
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
import '../../features/onboarding/presentation/pages/language_page.dart';
import '../../features/onboarding/presentation/pages/permissions_page.dart';
import '../../features/settings/presentation/pages/farm_management_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/settings/presentation/providers/farm_access_provider.dart';
import '../../security/authorization/roles.dart';
import '../../security/authorization/permissions.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:crm/crm.dart';
import '../../shared/components/bottom_navigation.dart';
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
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.createAccount,
        builder: (context, state) => const CreateAccountPage(),
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
            path: AppRoutes.breeding,
            builder: (context, state) => const _SectionPage(title: 'Breeding'),
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
            path: AppRoutes.crm,
            builder: (context, state) => CrmPage(
              onOpenMenu: () =>
                  navigationScaffoldKey.currentState?.openDrawer(),
            ),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const MorePage(),
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
      floatingActionButton: location == AppRoutes.support
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.go(AppRoutes.support),
              icon: const Icon(Icons.support_agent_outlined),
              label: const Text('Support'),
            ),
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
    final role = session?.user.role;
    final access = ref.watch(farmAccessProvider).valueOrNull;
    final canManageMembers = role == UserRole.farmOwner ||
        (role == UserRole.farmManager &&
            (access?.permissionsFor(session?.user.id ?? '').contains(AppPermission.manageMembers) ?? false));
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text('Pig World Smart')),
            if (canManageMembers)
              _ListTile(
                icon: Icons.group_outlined,
                title: 'Farm members',
                route: AppRoutes.farmManagement,
              ),
            if (role != null &&
                RolePermissions.can(role, AppPermission.manageFinance))
              _ListTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Finance',
                route: AppRoutes.finance,
              ),
            if (role != null &&
                RolePermissions.can(role, AppPermission.manageSales))
              _ListTile(
                icon: Icons.groups_outlined,
                title: 'Customers',
                route: AppRoutes.crm,
              ),
            _ListTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              route: AppRoutes.notifications,
            ),
            if (role != null &&
                RolePermissions.can(role, AppPermission.manageSettings))
              _ListTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                route: AppRoutes.settings,
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
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: () {
      Navigator.pop(context);
      context.go(route);
    },
  );
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
