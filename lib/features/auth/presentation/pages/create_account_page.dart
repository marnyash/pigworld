import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create account')),
        body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
          Text('Join Pig World Smart', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Set up your account to start managing your farm.'),
          const SizedBox(height: 28),
          const TextField(decoration: InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Email or phone number', prefixIcon: Icon(Icons.contact_mail_outlined))),
          const SizedBox(height: 16),
          const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
          const SizedBox(height: 24),
          FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account creation will be connected soon.'))), child: const Text('Create account')),
          TextButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Back to sign in')),
        ])),
      );
}