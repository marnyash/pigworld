import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/error_handler.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _submitting = false;
  bool _codeSent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(forgotPasswordUseCaseProvider)(_email.text.trim());
      if (mounted) setState(() => _codeSent = true);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _verifyCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final email = _email.text.trim();
      final code = _code.text.trim();
      await ref.read(verifyPasswordResetCodeUseCaseProvider)(
        email: email,
        code: code,
      );
      if (!mounted) return;
      final resetRoute = Uri(
        path: AppRoutes.resetPassword,
        queryParameters: {'token': code, 'email': email},
      );
      context.go(resetRoute.toString());
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Forgot password')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _codeSent
                        ? 'Enter the 6-digit code sent to your email. No reset link is sent.'
                        : 'Enter your account email. We will email you a one-time code to verify it and continue in the app.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    enabled: !_codeSent && !_submitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: _codeSent
                        ? TextInputAction.next
                        : TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        (value == null ||
                            !RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(value.trim()))
                        ? 'Enter a valid email.'
                        : null,
                    onFieldSubmitted: (_) =>
                        !_codeSent && !_submitting ? _requestCode() : null,
                  ),
                  if (_codeSent) ...[
                    const SizedBox(height: 16),
                    AutofillGroup(
                      child: TextFormField(
                        controller: _code,
                        enabled: !_submitting,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          labelText: '6-digit code',
                        ),
                        validator: (value) =>
                            value == null || !RegExp(r'^\d{6}$').hasMatch(value)
                            ? 'Enter the 6-digit code.'
                            : null,
                        onFieldSubmitted: (_) =>
                            _submitting ? null : _verifyCode(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'If this address is registered, a code has been sent. Codes expire after 10 minutes.',
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _submitting
                        ? null
                        : _codeSent
                        ? _verifyCode
                        : _requestCode,
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_codeSent ? 'Verify code' : 'Send reset code'),
                  ),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => context.go(AppRoutes.login),
                    child: const Text('Back to sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
