import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/herd/presentation/pages/herd_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/settings/presentation/pages/more_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/farm_selection_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/session_expired_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../shared/components/bottom_navigation.dart';
import '../app.dart';
import 'app_routes.dart';
import 'route_guard.dart';

abstract final class AppRouter {
	static final router = GoRouter(
		initialLocation: AppRoutes.splash,
		redirect: RouteGuard.redirect,
		routes: [
			GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashPage()),
			GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
			GoRoute(path: AppRoutes.farmSelection, builder: (context, state) => const FarmSelectionPage()),
			GoRoute(path: AppRoutes.forgotPassword, builder: (context, state) => const ForgotPasswordPage()),
			GoRoute(path: AppRoutes.sessionExpired, builder: (context, state) => SessionExpiredPage(onSignIn: () => context.go(AppRoutes.login))),
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
					GoRoute(path: AppRoutes.feed, builder: (context, state) => const FeedPage()),
					GoRoute(path: AppRoutes.finance, builder: (context, state) => const FinancePage()),
					GoRoute(path: AppRoutes.more, builder: (context, state) => const MorePage()),
					GoRoute(
						path: AppRoutes.settings,
						builder: (context, state) => const _SectionPage(title: 'Settings'),
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
			AppRoutes.feed => 1,
			AppRoutes.finance => 2,
			AppRoutes.more => 3,
			_ => 0,
		};
		return Scaffold(
			body: child,
			bottomNavigationBar: AppBottomNavigation(
				selectedIndex: selectedIndex,
				onSelected: (index) => context.go([
					AppRoutes.herd,
					AppRoutes.feed,
					AppRoutes.finance,
					AppRoutes.more,
				][index]),
			),
		);
	}
}

class _SectionPage extends StatelessWidget {
	const _SectionPage({required this.title});

	final String title;

	@override
	Widget build(BuildContext context) {
		return Center(child: Text(title, style: Theme.of(context).textTheme.headlineMedium));
	}
}
