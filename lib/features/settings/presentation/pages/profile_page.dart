import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../security/authorization/roles.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../../../../shared/widgets/profile_avatar.dart';
import '../../../../shared/widgets/pig_world_icon.dart';
import '../providers/farm_access_provider.dart';
import '../providers/profile_image_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _emailVisible = false;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final session = ref.watch(authProvider).valueOrNull;
    final user = session?.user;
    final farm = session?.selectedFarm ?? session?.farms.firstOrNull;
    final isFarmOwner = user?.role == UserRole.farmOwner;
    final farmAccess = isFarmOwner ? ref.watch(farmAccessProvider) : null;
    final initials = (user?.name.isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const PigWorldIcon('settings'),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.pagePadding,
          AppDimensions.pagePadding,
          32,
        ),
        children: [
          Card(
            color: AppColors.deepGreen,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ProfileAvatar(initials: initials),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: IconButton.filled(
                          tooltip: 'Change profile photo',
                          icon: const Icon(Icons.photo_camera_outlined),
                          iconSize: 17,
                          onPressed: () => _chooseProfileImage(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Your profile',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.inverseText),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: AppColors.inverseMutedText,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _emailText(
                                  user?.email,
                                  'Sign in to view your account',
                                ),
                                style: const TextStyle(
                                  color: AppColors.inverseMutedText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inverseText.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _roleLabel(user?.role.value),
                            style: TextStyle(color: AppColors.inverseText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text(
            'Account details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Column(
              children: [
                _ProfileDetailTile(
                  icon: Icons.person_outline,
                  assetName: 'profile',
                  label: 'Name',
                  value: user?.name ?? 'Not available',
                ),
                const Divider(height: 1, indent: 56),
                _ProfileDetailTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _emailText(user?.email, 'Not available'),
                  trailing: IconButton(
                    tooltip: _emailVisible ? 'Hide email' : 'Show email',
                    icon: Icon(
                      _emailVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _emailVisible = !_emailVisible);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text('Farm workspace', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const PigWorldIcon('farm'),
                  title: const Text('Farms'),
                  subtitle: Text(
                    farm?.name ?? 'Complete setup to connect a farm',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${session?.farms.length ?? 0}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.deepGreen,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => context.go(AppRoutes.farmSelection),
                ),
                if (isFarmOwner) ...[
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const PigWorldIcon('subscribtion'),
                    title: const Text('Subscription'),
                    subtitle: Text(
                      farm?.subscriptionPlan ?? 'No active subscription',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(AppRoutes.billing),
                  ),
                  const Divider(height: 1, indent: 56),
                  farmAccess!.when(
                    loading: () => const ListTile(
                      leading: PigWorldIcon('farmmembers'),
                      title: Text('Farm members'),
                      trailing: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (error, _) => ListTile(
                      leading: const PigWorldIcon('farmmembers'),
                      title: const Text('Farm members'),
                      subtitle: Text('Could not load member count: $error'),
                      trailing: const Icon(Icons.error_outline),
                    ),
                    data: (state) => ListTile(
                      leading: const PigWorldIcon('farmmembers'),
                      title: const Text('Farm members'),
                      subtitle: Text(
                        '${state.members.length} member${state.members.length == 1 ? '' : 's'} have access',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go(AppRoutes.farmManagement),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _emailText(String? email, String fallback) =>
      email == null || email.isEmpty
      ? fallback
      : _emailVisible
      ? email
      : '••••••••';

  Future<void> _chooseProfileImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    try {
      final selected = await ref
          .read(profileImageProvider.notifier)
          .chooseImage(source: source);
      if (context.mounted && !selected) return;
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile photo updated.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update profile photo.')),
        );
      }
    }
  }

  String _roleLabel(String? role) => switch (role) {
    'farmOwner' => 'Farm owner',
    'farmManager' => 'Farm manager',
    'farmWorker' => 'Farm worker',
    _ => 'Farm member',
  };
}

class _ProfileDetailTile extends StatelessWidget {
  const _ProfileDetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.assetName,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? assetName;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: assetName == null
        ? Icon(icon, color: AppColors.primaryGreen)
        : PigWorldIcon(assetName!, size: 24),
    title: Text(label, style: Theme.of(context).textTheme.bodySmall),
    subtitle: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
    trailing: trailing,
  );
}
