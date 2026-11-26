import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/error_handler.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_providers.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({
    required this.token,
    required this.email,
    super.key,
  });

  final String token;
  final String email;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _submitting = false;
  bool _reset = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(resetPasswordUseCaseProvider)(
        token: widget.token,
        email: widget.email,
        password: _password.text,
      );
      ref.read(authProvider.notifier).clearSession();
      TextInput.finishAutofillContext(shouldSave: true);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
      if (mounted) setState(() => _submitting = false);
      return;
    }

    try {
      final challenge = await ref.read(loginUseCaseProvider)(
        widget.email,
        _password.text,
      );
      if (!mounted) return;
      final otpRoute = Uri(
        path: AppRoutes.otpVerification,
        queryParameters: {
          'challengeId': challenge.id,
          'destination': challenge.destination,
          'rememberMe': 'false',
        },
      );
      context.go(otpRoute.toString());
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _reset = true;
          _error =
              'Your password was updated, but automatic sign-in could not start: ${error.message}';
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetCodeIsValid = widget.token.isNotEmpty && widget.email.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _reset
                  ? _buildSuccess(context)
                  : !resetCodeIsValid
                  ? _buildInvalidCode(context)
                  : AutofillGroup(child: _buildForm(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Set a new password for ${widget.email}.'),
        const SizedBox(height: 20),
        TextFormField(
          controller: _password,
          obscureText: true,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          decoration: const InputDecoration(labelText: 'New password'),
          validator: (value) => (value == null || value.length < 8)
              ? 'Use at least 8 characters.'
              : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirmation,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          decoration: const InputDecoration(labelText: 'Confirm new password'),
          validator: (value) =>
              value != _password.text ? 'Passwords do not match.' : null,
          onFieldSubmitted: (_) => _submitting ? null : _submit(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save new password'),
        ),
      ],
    ),
  );

  Widget _buildSuccess(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_error != null) ...[
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 12),
      ],
      const Text(
        'Your password has been updated.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () => context.go(AppRoutes.login),
        child: const Text('Back to sign in'),
      ),
    ],
  );

  Widget _buildInvalidCode(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'This reset code is incomplete or expired. Request a new code to continue.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () => context.go(AppRoutes.forgotPassword),
        child: const Text('Request a new code'),
      ),
    ],
  );
}
