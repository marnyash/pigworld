import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../security/authorization/permissions.dart';
import '../../../../security/authorization/roles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/farm_access_provider.dart';

class FarmManagementPage extends ConsumerWidget {
	const FarmManagementPage({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final role = ref.watch(authProvider).valueOrNull?.user.role;
		final access = ref.watch(farmAccessProvider);
		final canManage = ref.read(farmAccessProvider.notifier).canManageMembers(role ?? UserRole.viewer);
		final isOwner = role == UserRole.farmOwner;
		return Scaffold(
			appBar: AppBar(title: const Text('Farm members')),
			body: ListView(padding: const EdgeInsets.all(20), children: [
				Text('Green Valley Farm', style: Theme.of(context).textTheme.headlineSmall),
				const SizedBox(height: 6),
				Text(isOwner ? 'Control who can work here and what they can do.' : 'Manage workers according to your owner-approved access.'),
				if (isOwner) ...[
					const SizedBox(height: 20),
					Card(child: SwitchListTile(
						value: access.managerCanAddWorkers,
						onChanged: (value) => ref.read(farmAccessProvider.notifier).setManagerCanAddWorkers(value),
						title: const Text('Let farm manager add workers'),
						subtitle: const Text('The manager can invite workers, but cannot change farm policies.'),
					)),
				],
				const SizedBox(height: 20),
				Row(children: [
					Text('People with access', style: Theme.of(context).textTheme.titleLarge),
					const Spacer(),
					if (canManage) IconButton(tooltip: 'Add farm worker', onPressed: () => _showAddMemberDialog(context, ref), icon: const Icon(Icons.person_add_alt_1)),
				]),
				const SizedBox(height: 8),
				...access.members.expand((member) => [
					Card(child: ListTile(
						leading: CircleAvatar(child: Icon(member.role == UserRole.farmOwner ? Icons.business : member.role == UserRole.farmManager ? Icons.manage_accounts : Icons.agriculture)),
						title: Text(member.name),
						subtitle: Text('${_roleName(member.role)}\n${member.email}'),
						isThreeLine: true,
					)),
					if (isOwner && member.role == UserRole.farmManager)
						Card(child: Padding(
							padding: const EdgeInsets.symmetric(vertical: 8),
							child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
								const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Manager policies')),
								for (final policy in const [
									(AppPermission.manageHerd, 'Manage herd'),
									(AppPermission.manageFeed, 'Manage feed'),
									(AppPermission.viewReports, 'View reports'),
									(AppPermission.manageMembers, 'Add farm workers'),
								])
									CheckboxListTile(
										dense: true,
										value: member.permissions.contains(policy.$1),
										title: Text(policy.$2),
										onChanged: (value) => ref.read(farmAccessProvider.notifier).togglePermission(member.id, policy.$1, value ?? false),
									),
							]),
						)),
				]),
			]),
		);
	}

	static String _roleName(UserRole role) => switch (role) {
		UserRole.farmOwner => 'Farm owner',
		UserRole.farmManager => 'Farm manager',
		UserRole.farmWorker => 'Farm worker',
		_ => role.name,
	};

	static Future<void> _showAddMemberDialog(BuildContext context, WidgetRef ref) async {
		final name = TextEditingController();
		final email = TextEditingController();
		final identity = TextEditingController();
		final added = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
			title: const Text('Add farm worker'),
			content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
				TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
				TextField(controller: email, decoration: const InputDecoration(labelText: 'Email or phone')),
				TextField(controller: identity, decoration: const InputDecoration(labelText: 'Identity number')),
			])),
			actions: [
				TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
				FilledButton(onPressed: () => Navigator.pop(dialogContext, name.text.trim().isNotEmpty), child: const Text('Add worker')),
			],
		));
		if (added == true) ref.read(farmAccessProvider.notifier).addMember(name: name.text.trim(), email: email.text.trim(), role: UserRole.farmWorker, identityNumber: identity.text.trim());
		name.dispose();
		email.dispose();
		identity.dispose();
	}
}
