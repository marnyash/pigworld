import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your message has been sent to the support team.'),
      ),
    );
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Customer Care'),
      leading: IconButton(
        tooltip: 'Back to home',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(AppRoutes.home),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        32,
      ),
      children: [
        Card(
          color: AppColors.deepGreen,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.support_agent_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We are here to help',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Usually replies within one business day',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text('Get help quickly', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _ContactCard(
                icon: Icons.menu_book_outlined,
                label: 'Help centre',
                onTap: () => _showMessage(
                  context,
                  'Help centre articles will be available soon.',
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _ContactCard(
                icon: Icons.email_outlined,
                label: 'Email us',
                onTap: () => _showMessage(
                  context,
                  'Email support will be connected soon.',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text('Common questions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        Card(
          child: ExpansionPanelList.radio(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            children: [
              ExpansionPanelRadio(
                canTapOnHeader: true,
                value: 1,
                headerBuilder: (_, isExpanded) => ListTile(
                  title: const Text('How do I change my server address?'),
                  trailing: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primaryGreen,
                  ),
                ),
                body: const _FaqBody(
                  'Open Settings from your profile to update the server address.',
                ),
              ),
              ExpansionPanelRadio(
                canTapOnHeader: true,
                value: 2,
                headerBuilder: (_, isExpanded) => ListTile(
                  title: const Text('How do I manage my team?'),
                  trailing: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primaryGreen,
                  ),
                ),
                body: const _FaqBody(
                  'Use Farm members in the menu to review team access and policies.',
                ),
              ),
              ExpansionPanelRadio(
                canTapOnHeader: true,
                value: 3,
                headerBuilder: (_, isExpanded) => ListTile(
                  title: const Text('How do I reset my password?'),
                  trailing: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primaryGreen,
                  ),
                ),
                body: const _FaqBody(
                  'Choose Forgot password on the sign-in page to request a reset link.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text('Send a message', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          ),
        ),
      ],
    ),
  );

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class _FaqBody extends StatelessWidget {
  const _FaqBody(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(text),
    ),
  );
}
