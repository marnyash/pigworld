import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/settings/presentation/providers/farm_access_provider.dart';

class UserManagementSection extends ConsumerWidget {
  const UserManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmMembers = ref.watch(farmAccessProvider);

    return farmMembers.when(
      data: (state) => ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Farm Members',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          // TODO: Show add member dialog
                          _showAddMemberDialog(context, ref);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  if (state.members.isEmpty)
                    Text(
                      'No farm members yet',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...state.members.map(
                      (member) => Column(
                        children: [
                          _MemberTile(
                            member: member,
                            onTap: () {
                              // TODO: Show member details
                            },
                          ),
                          if (member != state.members.last) const Divider(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roles & Permissions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _RoleCard(
                    title: 'Farm Owner',
                    description: 'Full access to all farm features',
                    permissions: const [
                      'Manage farm settings',
                      'Add/remove workers',
                      'View all reports',
                      'Access finances',
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _RoleCard(
                    title: 'Farm Manager',
                    description: 'Manage daily operations',
                    permissions: const [
                      'View herd information',
                      'Record health data',
                      'Manage feeding schedules',
                      'View reports',
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _RoleCard(
                    title: 'Worker',
                    description: 'Record day-to-day activities',
                    permissions: const [
                      'Log feeding',
                      'Record health observations',
                      'Track herd movements',
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _RoleCard(
                    title: 'Veterinarian',
                    description: 'Manage animal health',
                    permissions: const [
                      'Record health data',
                      'Manage vaccinations',
                      'View health reports',
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 16),
            Text('Error: $err'),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final roleController = TextEditingController()..text = 'worker';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Farm Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: 'worker',
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.security),
              ),
              items: const [
                DropdownMenuItem(value: 'manager', child: Text('Manager')),
                DropdownMenuItem(value: 'worker', child: Text('Worker')),
                DropdownMenuItem(value: 'vet', child: Text('Veterinarian')),
              ],
              onChanged: (value) {
                if (value != null) roleController.text = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Send invitation
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invitation sent to ${emailController.text}'),
                ),
              );
            },
            child: const Text('Send Invitation'),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.onTap});

  final dynamic member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          member.name[0].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    ),
    title: Text(member.name),
    subtitle: Text('${member.role.name} • ${member.email}'),
    trailing: PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(child: Text('View Permissions')),
        const PopupMenuItem(child: Text('Remove Member')),
      ],
    ),
    onTap: onTap,
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.description,
    required this.permissions,
  });

  final String title;
  final String description;
  final List<String> permissions;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppDimensions.spacingMedium),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      border: Border.all(color: AppColors.outline),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        ...permissions.map(
          (perm) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.check, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Text(perm, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
