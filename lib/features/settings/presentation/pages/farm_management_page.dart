import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../security/authorization/permissions.dart';
import '../../../../security/authorization/roles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/farm_access_provider.dart';

class FarmManagementPage extends ConsumerWidget {
  const FarmManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).valueOrNull;
    final role = session?.user.role;
    final access = ref.watch(farmAccessProvider);
    final isOwner = role == UserRole.farmOwner;
    return Scaffold(
      appBar: AppBar(title: const Text('Farm members')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(farmAccessProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              session?.selectedFarm?.name ?? 'Your farm',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              isOwner
                  ? 'Control who can work here and what they can do.'
                  : 'Manage workers according to your owner-approved access.',
            ),
            if (isOwner && session?.selectedFarm?.inviteCode != null) ...[
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Invite code'),
                  subtitle: Text(
                    'Share this with a farm manager or worker so they can join at sign-up: ${session!.selectedFarm!.inviteCode}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Copy invite code',
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: session.selectedFarm!.inviteCode!),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invite code copied.')),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'People with access',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            access.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Could not load farm members: $error'),
              ),
              data: (state) => Column(
                children: [
                  for (final member in state.members) ...[
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            member.role == UserRole.farmOwner
                                ? Icons.business
                                : member.role == UserRole.farmManager
                                ? Icons.manage_accounts
                                : Icons.agriculture,
                          ),
                        ),
                        title: Text(member.name),
                        subtitle: Text(
                          '${_roleName(member.role)}\n${member.email}',
                        ),
                        isThreeLine: true,
                      ),
                    ),
                    if (isOwner && member.role != UserRole.farmOwner)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Policies'),
                              ),
                              for (final policy in const [
                                (AppPermission.manageHerd, 'Manage herd'),
                                (AppPermission.manageFeed, 'Manage feed'),
                                (AppPermission.viewReports, 'View reports'),
                                (
                                  AppPermission.manageMembers,
                                  'Add farm workers',
                                ),
                              ])
                                CheckboxListTile(
                                  dense: true,
                                  value: member.permissions.contains(policy.$1),
                                  title: Text(policy.$2),
                                  onChanged: (value) => ref
                                      .read(farmAccessProvider.notifier)
                                      .togglePermission(
                                        member.id,
                                        policy.$1,
                                        value ?? false,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _roleName(UserRole role) => switch (role) {
    UserRole.farmOwner => 'Farm owner',
    UserRole.farmManager => 'Farm manager',
    UserRole.farmWorker => 'Farm worker',
    _ => role.name,
  };
}
