import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/auth/presentation/providers/auth_provider.dart';
import 'package:proj/shared/widgets/profile_avatar.dart';

class ProfileSection extends ConsumerStatefulWidget {
  const ProfileSection({super.key});

  @override
  ConsumerState<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<ProfileSection> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _farmNameController;
  late TextEditingController _farmLocationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _farmNameController = TextEditingController();
    _farmLocationController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = ref.watch(authProvider).valueOrNull;
    if (session != null) {
      _nameController.text = session.user.name;
      _emailController.text = session.user.email;
      _phoneController.text = session.user.phone ?? '';
      _farmNameController.text = session.selectedFarm?.name ?? '';
      _farmLocationController.text = session.selectedFarm?.location ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    _farmLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider).valueOrNull;
    final user = session?.user;
    final farm = session?.selectedFarm;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: [
        // Profile Photo Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Photo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.spacingLarge),
                Center(
                  child: Stack(
                    children: [
                      ProfileAvatar(
                        initials:
                            (user.name.isNotEmpty ? user.name.trim()[0] : '?')
                                .toUpperCase(),
                        radius: 50,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: FloatingActionButton.small(
                          backgroundColor: AppColors.primaryGreen,
                          onPressed: () {
                            // TODO: Implement photo upload
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Photo upload coming soon'),
                              ),
                            );
                          },
                          child: const Icon(Icons.camera_alt),
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
        // Owner Information
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owner Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Owner Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        // Farm Information
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                TextField(
                  controller: _farmNameController,
                  decoration: const InputDecoration(
                    labelText: 'Farm Name',
                    prefixIcon: Icon(Icons.agriculture),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                TextField(
                  controller: _farmLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Farm Location',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                if (farm?.inviteCode != null) ...[
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppDimensions.radius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite Code',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                farm!.inviteCode!,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // TODO: Copy to clipboard
                              },
                              icon: const Icon(Icons.copy_outlined),
                            ),
                          ],
                        ),
                        Text(
                          'Share this code with farm managers and workers',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        FilledButton(
          onPressed: () {
            // TODO: Save profile changes
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profile updated')));
          },
          child: const Text('Save Changes'),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
      ],
    );
  }
}
