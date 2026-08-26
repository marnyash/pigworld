import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({required this.onSubmit, super.key});
  final Future<void> Function(String email, String password, bool rememberMe)
  onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      children: [
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email or phone number',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            final input = value?.trim() ?? '';
            final validEmail = RegExp(
              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
            ).hasMatch(input);
            final validPhone = RegExp(r'^\+?[0-9\s-]{8,}$').hasMatch(input);
            if (input.isEmpty) return 'Enter your email or phone number';
            if (!validEmail && !validPhone) {
              return 'Enter a valid email or phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Enter your password' : null,
        ),
        StatefulBuilder(
          builder: (context, setState) => CheckboxListTile(
            value: rememberMe,
            onChanged: (value) => setState(() => rememberMe = value ?? false),
            title: const Text('Remember me'),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  setState(() => isLoading = true);
                  try {
                    await widget.onSubmit(
                      emailController.text.trim(),
                      passwordController.text,
                      rememberMe,
                    );
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to sign in. Please try again.'),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => isLoading = false);
                  }
                },
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign in'),
        ),
      ],
    ),
  );
}
