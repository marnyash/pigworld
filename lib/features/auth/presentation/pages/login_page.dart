import 'package:flutter/material.dart';
import '../widgets/biometric_button.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Image.asset('assets/images/logo.jpeg', height: 120),
          const SizedBox(height: 24),
          Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Sign in to manage your Pig World farm.'),
          const SizedBox(height: 24),
          LoginForm(onSubmit: (email, password, rememberMe) async => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication API is not configured yet.')))),
          const SizedBox(height: 12),
          BiometricButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric sign-in is not configured yet.')))),
        ]))))),
      );
}
