import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/herd/presentation/pages/herd_page.dart';
import '../app.dart';
import 'app_routes.dart';
import 'route_guard.dart';

abstract final class AppRouter {
	static final router = GoRouter(
		initialLocation: AppRoutes.home,
		redirect: RouteGuard.redirect,
		routes: [
			ShellRoute(
				builder: (context, state, child) => NavigationShell(child: child),
				routes: [
					GoRoute(
						path: AppRoutes.home,
						builder: (context, state) => const MyHomePage(title: 'Pig World'),
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
			AppRoutes.herd => 1,
			AppRoutes.breeding => 2,
			_ => 0,
		};
		return Scaffold(
			body: child,
			bottomNavigationBar: NavigationBar(
				selectedIndex: selectedIndex,
				onDestinationSelected: (index) => context.go([
					AppRoutes.home,
					AppRoutes.herd,
					AppRoutes.breeding,
				][index]),
				destinations: const [
					NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
					NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Herd'),
					NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Breeding'),
				],
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
