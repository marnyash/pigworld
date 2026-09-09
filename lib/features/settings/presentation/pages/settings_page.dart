import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/auth/domain/entities/farm.dart';
import 'package:proj/features/auth/domain/entities/session.dart';
import 'package:proj/features/auth/domain/entities/user.dart';
import 'package:proj/features/auth/presentation/providers/auth_provider.dart';
import 'package:proj/features/auth/presentation/providers/auth_providers.dart';
import 'package:proj/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:proj/features/settings/data/settings_api.dart';
import 'package:proj/features/settings/presentation/providers/settings_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Future<void> _changeLanguage(String language) async {
    await ref.read(userPreferencesProvider.notifier).updateLanguage(language);
    ref
        .read(onboardingProvider.notifier)
        .setLanguage(
          name: language == 'sw' ? 'Swahili' : 'English',
          code: language,
        );
    if (!mounted) return;
    _showMessage(
      'Language changed to ${SettingsHelper.getLanguageName(language)}.',
    );
  }

  Future<void> _changeProfileName(Session? session) async {
    if (session == null) return;
    final name = await _editTextDialog(
      'Change profile name',
      'Profile name',
      session.user.name,
    );
    if (name == null || !mounted) return;
    try {
      await SettingsApi(ref.read(dioProvider)).updateDisplayName(name);
      if (!mounted) return;
      final user = session.user;
      ref
          .read(authProvider.notifier)
          .setSession(
            Session(
              accessToken: session.accessToken,
              refreshToken: session.refreshToken,
              user: User(
                id: user.id,
                name: name,
                email: user.email,
                phone: user.phone,
                role: user.role,
              ),
              farms: session.farms,
              selectedFarm: session.selectedFarm,
            ),
          );
      _showMessage('Profile name updated.');
    } catch (_) {
      _showMessage('Could not update your profile name.', isError: true);
    }
  }

  Future<void> _changeFarmName(Session? session, Farm? farm) async {
    if (session == null || farm == null) return;
    final name = await _editTextDialog(
      'Change farm name',
      'Farm name',
      farm.name,
    );
    if (name == null || !mounted) return;
    try {
      await SettingsApi(
        ref.read(dioProvider),
      ).renameFarm(farmId: farm.id, name: name);
      if (!mounted) return;
      final renamedFarm = Farm(
        id: farm.id,
        name: name,
        location: farm.location,
        inviteCode: farm.inviteCode,
        motherPigCount: farm.motherPigCount,
        registeredPigletCount: farm.registeredPigletCount,
        pregnantPigCount: farm.pregnantPigCount,
        subscriptionPlan: farm.subscriptionPlan,
      );
      ref
          .read(authProvider.notifier)
          .setSession(
            Session(
              accessToken: session.accessToken,
              refreshToken: session.refreshToken,
              user: session.user,
              farms: [
                for (final item in session.farms)
                  item.id == farm.id ? renamedFarm : item,
              ],
              selectedFarm: renamedFarm,
            ),
          );
      _showMessage('Farm name updated.');
    } catch (_) {
      _showMessage('Could not update the farm name.', isError: true);
    }
  }

  Future<void> _setNewPassword() async {
    final passwords = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _PasswordDialog(),
    );
    if (passwords == null || !mounted) return;
    try {
      await SettingsApi(ref.read(dioProvider)).changePassword(
        currentPassword: passwords.$1,
        newPassword: passwords.$2,
      );
      if (mounted) {
        _showMessage('Password updated.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Could not update the password. Check your current password.',
          isError: true,
        );
      }
    }
  }

  Future<String?> _editTextDialog(
    String title,
    String label,
    String initialValue,
  ) => showDialog<String>(
    context: context,
    builder: (_) =>
        _TextEditDialog(title: title, label: label, initialValue: initialValue),
  );

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(userPreferencesProvider).valueOrNull;
    final session = ref.watch(authProvider).valueOrNull;
    final farm = session?.selectedFarm ?? session?.farms.firstOrNull;
    final notificationSound = preferences?.notificationSound ?? 'default';
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Change language'),
              subtitle: Text(
                SettingsHelper.getLanguageName(preferences?.language ?? 'en'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showLanguagePicker,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text(
            'Account settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Column(
              children: [
                _SettingsAction(
                  icon: Icons.person_outline,
                  title: 'Change profile name',
                  onTap: () => _changeProfileName(session),
                ),
                const Divider(height: 1),
                _SettingsAction(
                  icon: Icons.agriculture_outlined,
                  title: 'Change farm name',
                  onTap: farm == null
                      ? null
                      : () => _changeFarmName(session, farm),
                ),
                const Divider(height: 1),
                _SettingsAction(
                  icon: Icons.lock_outline,
                  title: 'Set new password',
                  onTap: _setNewPassword,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text(
            'Farm configuration',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Column(
              children: [
                _SettingsAction(
                  icon: Icons.location_on_outlined,
                  title: 'Farm location',
                  subtitle: farm?.location ?? 'Add your farm location',
                  onTap: () =>
                      _showMessage('Farm location settings are coming soon.'),
                ),
                const Divider(height: 1),
                _SettingsAction(
                  icon: Icons.straighten_outlined,
                  title: 'Herd units',
                  subtitle: 'Kg, breeding cycles, and display units',
                  onTap: () =>
                      _showMessage('Herd units settings are coming soon.'),
                ),
                const Divider(height: 1),
                _SettingsAction(
                  icon: Icons.access_time_outlined,
                  title: 'Timezone & date format',
                  subtitle: 'Local farm time and reporting format',
                  onTap: () =>
                      _showMessage('Timezone settings are coming soon.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text(
            'Billing & subscription',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Column(
              children: [
                _SettingsAction(
                  icon: Icons.credit_card_outlined,
                  title: 'Current plan',
                  subtitle: farm?.subscriptionPlan ?? 'Starter plan',
                  onTap: () => _showMessage(
                    'Subscription management is ready for the next milestone.',
                  ),
                ),
                const Divider(height: 1),
                _SettingsAction(
                  icon: Icons.autorenew_outlined,
                  title: 'Auto-renewal',
                  subtitle: 'Enabled',
                  onTap: () =>
                      _showMessage('Auto-renewal settings are coming soon.'),
                ),
                const Divider(height: 1),
                _SettingsAction(
                  icon: Icons.receipt_long_outlined,
                  title: 'Billing history',
                  subtitle: 'View invoices and payment activity',
                  onTap: () => _showMessage('Billing history is coming soon.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text(
            'Security & sessions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Column(
              children: [
                _SettingsAction(
                  icon: Icons.devices_outlined,
                  title: 'Active devices',
                  subtitle: 'Manage sign-ins across your devices',
                  onTap: () =>
                      _showMessage('Device management is coming soon.'),
                ),
                const Divider(height: 1),
                _SettingsAction(
                  icon: Icons.logout_outlined,
                  title: 'Sign out of all devices',
                  subtitle: 'Require re-login everywhere',
                  onTap: () => _showMessage('Session reset is coming soon.'),
                ),
                const Divider(height: 1),
                _SettingsAction(
                  icon: Icons.security_outlined,
                  title: 'Privacy and access',
                  subtitle: 'Role-based controls and session policy',
                  onTap: () =>
                      _showMessage('Access policy settings are coming soon.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: ListTile(
              leading: const Icon(Icons.volume_up_outlined),
              title: const Text('Notification sound'),
              subtitle: Text(_notificationSoundLabel(notificationSound)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showNotificationSoundPicker,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguagePicker() => showDialog<void>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('Change language'),
      children: [
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(dialogContext);
            _changeLanguage('en');
          },
          child: const Text('English'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(dialogContext);
            _changeLanguage('sw');
          },
          child: const Text('Kiswahili'),
        ),
      ],
    ),
  );

  String _notificationSoundLabel(String sound) => switch (sound) {
    'chime' => 'Chime',
    'alert' => 'Alert',
    'silent' => 'Silent',
    _ => 'Phone default',
  };

  Future<void> _showNotificationSoundPicker() => showDialog<void>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('Notification sound'),
      children: [
        for (final option in const [
          ('default', 'Phone default'),
          ('chime', 'Chime'),
          ('alert', 'Alert'),
          ('silent', 'Silent'),
        ])
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref
                  .read(userPreferencesProvider.notifier)
                  .updateNotificationSound(option.$1);
            },
            child: Text(option.$2),
          ),
      ],
    ),
  );
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primaryGreen),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _TextEditDialog extends StatefulWidget {
  const _TextEditDialog({
    required this.title,
    required this.label,
    required this.initialValue,
  });
  final String title;
  final String label;
  final String initialValue;
  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (_) => _save(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();
  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _currentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  @override
  void dispose() {
    _currentController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _updatePassword() {
    final password = _passwordController.text;
    if (password.length >= 8 && password == _confirmationController.text) {
      Navigator.pop(context, (_currentController.text, password));
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Set new password'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _currentController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Current password'),
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New password'),
        ),
        TextField(
          controller: _confirmationController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm new password'),
          onSubmitted: (_) => _updatePassword(),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _updatePassword, child: const Text('Update')),
    ],
  );
}
