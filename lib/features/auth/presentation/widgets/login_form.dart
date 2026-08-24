import 'package:flutter/material.dart';
import 'password_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({required this.onSubmit, super.key});
  final Future<void> Function(String email, String password, bool rememberMe) onSubmit;
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    var rememberMe = false;
    return Form(
      child: Column(children: [
        TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
        const SizedBox(height: 16),
        PasswordField(controller: passwordController),
        StatefulBuilder(builder: (context, setState) => CheckboxListTile(value: rememberMe, onChanged: (value) => setState(() => rememberMe = value ?? false), title: const Text('Remember me'))),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => onSubmit(emailController.text.trim(), passwordController.text, rememberMe), child: const Text('Sign in')),
      ]),
    );
  }
}
