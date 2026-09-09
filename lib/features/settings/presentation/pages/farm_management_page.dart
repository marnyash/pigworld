import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:proj/app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../security/authorization/permissions.dart';
import '../../../../security/authorization/roles.dart';
import '../../../auth/domain/entities/session.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/farm_join_request.dart';
import '../providers/farm_team_provider.dart';
import '../providers/farm_access_provider.dart';

class FarmManagementPage extends ConsumerWidget {
  const FarmManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).valueOrNull;
    final role = session?.user.role;
    final access = ref.watch(farmAccessProvider);
    final team = ref.watch(farmTeamProvider);
    final isOwner = role == UserRole.farmOwner;
    return Scaffold(
      appBar: AppBar(title: const Text('My team')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(farmTeamProvider);
          ref.invalidate(farmAccessProvider);
          await ref.read(farmTeamProvider.future);
          await ref.read(farmAccessProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              isOwner
                  ? (session?.selectedFarm?.name ?? 'Your farms')
                  : 'Find a farm to work with',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              isOwner
                  ? 'Manage members, review join requests, and create additional farms.'
                  : 'Send a request to a farm owner. You can join after they approve it.',
            ),
            if (!isOwner) ...[
              const SizedBox(height: 20),
              _JoinFarmCard(ref: ref),
              const SizedBox(height: 24),
              Text(
                'My farm requests',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _RequestList(
                requests: team.valueOrNull?.myRequests ?? const [],
                emptyText: 'You have not requested to join a farm yet.',
              ),
            ],
            if (isOwner) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.swap_horiz_outlined),
                    label: const Text('Switch farm'),
                    onPressed: () => context.go(AppRoutes.farmSelection),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Add farm'),
                    onPressed: () => _showAddFarmDialog(context, ref),
                  ),
                ],
              ),
              if (isOwner && session?.selectedFarm?.inviteCode != null) ...[
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_add_alt_1_outlined),
                            SizedBox(width: 10),
                            Text('Register a manager or worker'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share this code. They choose Farm manager or Farm worker during account creation and enter it to join your farm.',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                session!.selectedFarm!.inviteCode!,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copy invite code',
                              icon: const Icon(Icons.copy_outlined),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: session.selectedFarm!.inviteCode!,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invite code copied.'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Join requests',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              team.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Text('Could not load join requests: $error'),
                data: (state) =>
                    _OwnerRequestList(ref: ref, requests: state.farmRequests),
              ),
            ],
            const SizedBox(height: 20),
            if (isOwner && session?.selectedFarm != null)
              Text(
                'People with access',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 8),
            if (isOwner && session?.selectedFarm != null)
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
                                  (
                                    AppPermission.manageBreeding,
                                    'Manage breeding',
                                  ),
                                  (AppPermission.manageFeed, 'Manage feed'),
                                  (
                                    AppPermission.manageFinance,
                                    'Manage finances',
                                  ),
                                  (AppPermission.manageSales, 'Manage sales'),
                                  (AppPermission.viewReports, 'View reports'),
                                  (
                                    AppPermission.manageMembers,
                                    'Manage team members',
                                  ),
                                ])
                                  CheckboxListTile(
                                    dense: true,
                                    value: member.permissions.contains(
                                      policy.$1,
                                    ),
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

  static Future<void> _showAddFarmDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final name = TextEditingController();
    final location = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add another farm'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Farm name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a farm name.'
                    : null,
              ),
              TextField(
                controller: location,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              try {
                final farm = await ref
                    .read(farmTeamApiProvider)
                    .createFarm(name.text, location: location.text);
                final session = ref.read(authProvider).valueOrNull;
                if (session != null) {
                  ref
                      .read(authProvider.notifier)
                      .setSession(
                        Session(
                          accessToken: session.accessToken,
                          refreshToken: session.refreshToken,
                          user: session.user,
                          farms: [...session.farms, farm],
                          selectedFarm: session.selectedFarm ?? farm,
                        ),
                      );
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Could not add farm: $error')),
                  );
                }
              }
            },
            child: const Text('Add farm'),
          ),
        ],
      ),
    );
    name.dispose();
    location.dispose();
  }

  static String _roleName(UserRole role) => switch (role) {
    UserRole.farmOwner => 'Farm owner',
    UserRole.farmManager => 'Farm manager',
    UserRole.farmWorker => 'Farm worker',
    _ => role.name,
  };
}

class _JoinFarmCard extends StatefulWidget {
  const _JoinFarmCard({required this.ref});

  final WidgetRef ref;

  @override
  State<_JoinFarmCard> createState() => _JoinFarmCardState();
}

class _JoinFarmCardState extends State<_JoinFarmCard> {
  final code = TextEditingController();
  final message = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    code.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request to join a farm',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text('Ask the farm owner for the farm invite code.'),
          const SizedBox(height: 12),
          TextField(
            controller: code,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Farm invite code'),
          ),
          TextField(
            controller: message,
            decoration: const InputDecoration(labelText: 'Message (optional)'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: sending ? null : _send,
            icon: const Icon(Icons.send_outlined),
            label: sending
                ? const Text('Sending...')
                : const Text('Send request'),
          ),
        ],
      ),
    ),
  );

  Future<void> _send() async {
    if (code.text.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      await widget.ref.read(farmTeamProvider.notifier).requestToJoin(code.text);
      if (mounted) {
        code.clear();
        message.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Join request sent.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send request: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}

class _OwnerRequestList extends StatelessWidget {
  const _OwnerRequestList({required this.ref, required this.requests});

  final WidgetRef ref;
  final List<FarmJoinRequest> requests;

  @override
  Widget build(BuildContext context) {
    final pending = requests.where((request) => request.isPending).toList();
    if (pending.isEmpty) {
      return const Text('No pending requests for this farm.');
    }
    return Column(
      children: [
        for (final request in pending)
          Card(
            child: ListTile(
              title: Text(request.userName ?? 'Farm applicant'),
              subtitle: Text(
                '${FarmManagementPage._roleName(request.requestedRole)}\n${request.userEmail ?? ''}${request.message == null ? '' : '\n${request.message}'}',
              ),
              isThreeLine: true,
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: 'Reject',
                    icon: const Icon(Icons.close, color: AppColors.danger),
                    onPressed: () => ref
                        .read(farmTeamProvider.notifier)
                        .reviewRequest(request.id, false),
                  ),
                  IconButton(
                    tooltip: 'Accept',
                    icon: const Icon(Icons.check, color: AppColors.success),
                    onPressed: () => ref
                        .read(farmTeamProvider.notifier)
                        .reviewRequest(request.id, true),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.requests, required this.emptyText});

  final List<FarmJoinRequest> requests;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) return Text(emptyText);
    return Column(
      children: [
        for (final request in requests)
          Card(
            child: ListTile(
              title: Text(request.farmName ?? 'Farm'),
              subtitle: Text(
                '${request.status[0].toUpperCase()}${request.status.substring(1)} request',
              ),
              trailing: Chip(
                label: Text(
                  FarmManagementPage._roleName(request.requestedRole),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
