import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../security/authorization/roles.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({super.key});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  static const _roles = [
    (
      UserRole.farmOwner,
      'Farm owner',
      'Create a new farm and control its policies.',
    ),
    (
      UserRole.farmManager,
      'Farm manager',
      'Join an existing farm with an owner-shared code.',
    ),
    (
      UserRole.farmWorker,
      'Farm worker',
      'Join an existing farm with an owner-shared code.',
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _farmName = TextEditingController();
  final _inviteCode = TextEditingController();
  UserRole _role = UserRole.farmOwner;
  bool _submitting = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedRoles = ref.read(onboardingProvider).roles;
    if (selectedRoles.isNotEmpty) {
      _role = selectedRoles.first;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _farmName.dispose();
    _inviteCode.dispose();
    super.dispose();
  }

  bool get _needsInviteCode => _role != UserRole.farmOwner;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final session = await ref.read(registerUseCaseProvider)(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        role: _role,
        farmName: _role == UserRole.farmOwner ? _farmName.text.trim() : null,
        inviteCode: _needsInviteCode ? _inviteCode.text.trim() : null,
        motherPigCount: ref.read(onboardingProvider).motherPigCount,
        pigletGroups: ref.read(onboardingProvider).pigletGroups.map((group) => group.toJson()).toList(),
        pregnantPigCount: ref.read(onboardingProvider).pregnantPigCount,
      );
      ref.read(authProvider.notifier).setSession(session);
      if (mounted) {
        context.go(_role == UserRole.farmOwner ? AppRoutes.subscription : AppRoutes.home);
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Join Pig World Smart',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Set up your account to start managing your farm.'),
            const SizedBox(height: 24),
            Text(
              'Account type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._roles.map((entry) {
              final (role, title, description) = entry;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<UserRole>(
                  value: role,
                  // ignore: deprecated_member_use
                  groupValue: _role,
                  // ignore: deprecated_member_use
                  onChanged: (value) => setState(() => _role = value ?? _role),
                  title: Text(title),
                  subtitle: Text(description),
                ),
              );
            }),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter your full name.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.contact_mail_outlined),
              ),
              validator: (value) => (value == null || !value.contains('@'))
                  ? 'Enter a valid email.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (value) => (value == null || value.length < 8)
                  ? 'Use at least 8 characters.'
                  : null,
            ),
            const SizedBox(height: 16),
            if (_role == UserRole.farmOwner)
              TextFormField(
                controller: _farmName,
                decoration: const InputDecoration(
                  labelText: 'Farm name',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Name your farm.'
                    : null,
              )
            else
              TextFormField(
                controller: _inviteCode,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Owner invite code',
                  prefixIcon: Icon(Icons.link),
                  helperText:
                      'Ask your farm owner for the code shown on their farm settings.',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter the invite code from your farm owner.'
                    : null,
              ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create account'),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    ),
  );
}
