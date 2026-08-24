import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract final class RouteGuard {
	/// Authentication is intentionally deferred to a later phase.
	static String? redirect(BuildContext context, GoRouterState state) => null;
}
