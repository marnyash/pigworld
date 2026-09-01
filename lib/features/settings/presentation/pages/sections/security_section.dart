import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/settings/presentation/providers/settings_providers.dart';

class SecuritySection extends ConsumerWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securitySettings = ref.watch(securitySettingsProvider);

    return securitySettings.when(
      data: (settings) => ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          // Password & PIN Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password & PIN',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _SecurityTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      // TODO: Show change password dialog
                    },
                  ),
                  const Divider(),
                  _SecurityTile(
                    icon: Icons.numbers,
                    title: 'Set 4-Digit PIN',
                    onTap: () {
                      // TODO: Show PIN setup dialog
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // Biometric Security
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biometric Login',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  SwitchListTile(
                    title: const Text('Fingerprint Login'),
                    subtitle: const Text('Use fingerprint to unlock the app'),
                    value: settings.hasBiometricEnabled,
                    onChanged: (value) {
                      ref
                          .read(securitySettingsProvider.notifier)
                          .updateBiometric(value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Face ID Login'),
                    subtitle: const Text(
                      'Use face recognition to unlock the app',
                    ),
                    value: settings.biometricTypes.contains('face'),
                    onChanged: (value) {
                      // TODO: Handle face ID
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // Two-Factor Authentication
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
                        'Two-Factor Authentication',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Switch(
                        value: settings.hasTwoFactorAuth,
                        onChanged: (value) {
                          ref
                              .read(securitySettingsProvider.notifier)
                              .updateTwoFactorAuth(value);
                        },
                      ),
                    ],
                  ),
                  if (settings.hasTwoFactorAuth) ...[
                    const SizedBox(height: AppDimensions.spacingMedium),
                    Text(
                      'Two-factor authentication is enabled. You will receive a code via SMS or email when logging in.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // Session Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  if (settings.lastPasswordChange != null)
                    Text(
                      'Last password changed: ${settings.lastPasswordChange}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  FilledButton(
                    onPressed: () {
                      // TODO: Sign out from all devices
                    },
                    child: const Text('Sign Out From All Devices'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Error loading security settings: $err')),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primaryGreen),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
