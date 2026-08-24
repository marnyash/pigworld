import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your message has been sent to the support team.')));
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Support'),
          leading: IconButton(
            tooltip: 'Back to home',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.support_agent_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('How can we help?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Send a message to the Pig World Smart support team.'),
            const SizedBox(height: 24),
            TextField(
              controller: messageController,
              minLines: 6,
              maxLines: 10,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Your message',
                hintText: 'Tell us what you need help with',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: sendMessage,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Send message'),
            ),
          ],
        ),
      );
}
