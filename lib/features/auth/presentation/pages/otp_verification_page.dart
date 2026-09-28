import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_providers.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.challengeId,
    required this.destination,
    required this.rememberMe,
  });

  final String challengeId;
  final String destination;
  final bool rememberMe;

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!(_formKey.currentState?.validate() ?? false) || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final session = await ref.read(verifyLoginOtpUseCaseProvider)(
        widget.challengeId,
        _otpController.text.trim(),
      );
      await ref.read(authServiceProvider).setRememberMe(widget.rememberMe);
      await ref.read(sessionManagerProvider).markActive();
      ref.read(authProvider.notifier).setSession(session);
      if (mounted) context.go(AppRoutes.home);
    } on Object {
      if (mounted) {
        setState(() => _error = 'That code is invalid or expired. Request a new sign-in code and try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('OTP verification')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter the 6-digit code sent to ${widget.destination.isEmpty ? 'your registered email' : widget.destination}.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final code = value?.trim() ?? '';
                  if (code.isEmpty) return 'Enter the OTP code';
                  if (!RegExp(r'^\d{6}$').hasMatch(code)) {
                    return 'Enter the 6-digit code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _submitting ? null : _verify,
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify and sign in'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
