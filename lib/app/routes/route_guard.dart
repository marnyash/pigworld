import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract final class RouteGuard {
	static const publicRoutes = {
		'/splash',
		'/login',
		'/forgot-password',
		'/session-expired',
	};

	static bool isPublic(String location) => publicRoutes.contains(location);

	/// Authentication is intentionally deferred to a later phase.
	static String? redirect(BuildContext context, GoRouterState state) => null;
}
