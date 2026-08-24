import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Forgot password')), body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [const TextField(decoration: InputDecoration(labelText: 'Email')), const SizedBox(height: 16), FilledButton(onPressed: () {}, child: const Text('Send reset link'))])));
}
