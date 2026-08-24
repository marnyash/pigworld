import 'roles.dart';

enum AppPermission { viewDashboard, manageHerd, manageBreeding, manageFeed, manageFinance, manageSales, viewReports, manageSettings }

abstract final class RolePermissions {
	static final Map<UserRole, Set<AppPermission>> all = {
		UserRole.superAdmin: AppPermission.values.toSet(),
		UserRole.farmOwner: AppPermission.values.toSet(),
		UserRole.farmManager: {
			AppPermission.viewDashboard, AppPermission.manageHerd, AppPermission.manageBreeding,
			AppPermission.manageFeed, AppPermission.viewReports,
		},
		UserRole.farmWorker: {AppPermission.viewDashboard, AppPermission.manageHerd, AppPermission.manageFeed},
		UserRole.accountant: {AppPermission.viewDashboard, AppPermission.manageFinance, AppPermission.viewReports},
		UserRole.salesMarketing: {AppPermission.viewDashboard, AppPermission.manageSales, AppPermission.viewReports},
		UserRole.viewer: {AppPermission.viewDashboard, AppPermission.viewReports},
	};

	static bool can(UserRole role, AppPermission permission) => all[role]?.contains(permission) ?? false;
}
