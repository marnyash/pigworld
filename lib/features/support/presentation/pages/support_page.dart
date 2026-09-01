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
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedCategory = 'General';

  @override
  void dispose() {
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void submitTicket() {
    if (subjectController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Your ticket has been submitted. We will respond shortly.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    subjectController.clear();
    descriptionController.clear();
    setState(() => selectedCategory = 'General');
  }

  void callVeterinary() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Initiating emergency veterinary call...'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Customer Support'),
      leading: IconButton(
        tooltip: 'Back to home',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(AppRoutes.home),
      ),
      centerTitle: true,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        32,
      ),
      children: [
        // Support Header
        _SupportHeader(),
        const SizedBox(height: AppDimensions.spacingLarge),

        // Quick Actions
        Text('Get Help Quickly', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        _QuickActionsSection(
          onOpenChat: () => _showMessage(context, 'Opening live chat...'),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),

        // Contact Options
        Text('Contact Options', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        _ContactOptionsSection(),
        const SizedBox(height: AppDimensions.spacingLarge),

        // Emergency Veterinary Help
        _EmergencyVeterinaryCard(onCall: callVeterinary),
        const SizedBox(height: AppDimensions.spacingLarge),

        // FAQ Section
        Text(
          'Frequently Asked Questions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        _FAQSection(),
        const SizedBox(height: AppDimensions.spacingLarge),

        // Submit a Ticket
        Text('Submit a Ticket', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        _TicketSubmissionForm(
          subjectController: subjectController,
          descriptionController: descriptionController,
          selectedCategory: selectedCategory,
          onCategoryChanged: (value) {
            setState(() => selectedCategory = value ?? 'General');
          },
          onSubmit: submitTicket,
        ),
        const SizedBox(height: AppDimensions.spacingLarge),

        // User Guide
        Text(
          'User Guide & Tutorials',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        _UserGuideSection(),
      ],
    ),
  );
}

// Support Header Widget
class _SupportHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.deepGreen,
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      'We\'re Here to Help',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Online',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium,
              vertical: AppDimensions.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(AppDimensions.radius),
            ),
            child: Text(
              '⏱️ Average response time: 2-4 hours',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

// Quick Actions Section
class _QuickActionsSection extends StatelessWidget {
  final VoidCallback onOpenChat;

  const _QuickActionsSection({required this.onOpenChat});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ActionCard(
          icon: Icons.chat_bubble_outline,
          label: 'Live Chat',
          onTap: onOpenChat,
        ),
      ),
      const SizedBox(width: AppDimensions.spacingMedium),
      Expanded(
        child: _ActionCard(
          icon: Icons.help_outline,
          label: 'FAQ',
          onTap: () {},
        ),
      ),
      const SizedBox(width: AppDimensions.spacingMedium),
      Expanded(
        child: _ActionCard(
          icon: Icons.video_library_outlined,
          label: 'Tutorials',
          onTap: () {},
        ),
      ),
    ],
  );
}

// Action Card Widget
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    ),
  );
}

// Contact Options Section
class _ContactOptionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _ContactOptionTile(
        icon: Icons.phone_outlined,
        title: 'Call Support',
        subtitle: '+1 (800) 123-4567',
        actionLabel: 'Call',
        onTap: () => _showMessage(context, 'Initiating call to support...'),
      ),
      _ContactOptionTile(
        icon: Icons.chat_outlined,
        title: 'WhatsApp',
        subtitle: 'Message us on WhatsApp',
        actionLabel: 'Open',
        onTap: () => _showMessage(context, 'Opening WhatsApp...'),
      ),
      _ContactOptionTile(
        icon: Icons.email_outlined,
        title: 'Email Support',
        subtitle: 'support@pigworld.com',
        actionLabel: 'Email',
        onTap: () => _showMessage(context, 'Opening email client...'),
      ),
      Card(
        color: AppColors.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMedium),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.primaryGreen),
              const SizedBox(width: AppDimensions.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Hours',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Text(
                      'Monday - Friday: 8:00 AM - 6:00 PM (Local Time)\nWeekends: 10:00 AM - 4:00 PM',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// Contact Option Tile
class _ContactOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  const _ContactOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
    child: ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: OutlinedButton(onPressed: onTap, child: Text(actionLabel)),
    ),
  );
}

// Emergency Veterinary Help Card
class _EmergencyVeterinaryCard extends StatelessWidget {
  final VoidCallback onCall;

  const _EmergencyVeterinaryCard({required this.onCall});

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.danger,
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emergency_outlined,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Veterinary Help',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'One-tap call for urgent veterinary assistance',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.phone),
              label: const Text('Call Emergency Vet Now'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// FAQ Section
class _FAQSection extends StatefulWidget {
  @override
  State<_FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<_FAQSection> {
  final _faqItems = [
    {
      'category': 'Breeding',
      'question': 'How do I track breeding cycles?',
      'answer':
          'Use the Breeding section to log breeding dates, sire information, and expected due dates. The app will send notifications for important milestones.',
    },
    {
      'category': 'Vaccination',
      'question': 'How do I schedule vaccinations?',
      'answer':
          'Navigate to Health & Vaccination and add vaccination records. Set reminders for upcoming vaccinations to ensure your herd stays healthy.',
    },
    {
      'category': 'Feed',
      'question': 'How do I manage feed inventory?',
      'answer':
          'Use the Feed Management section to log feed purchases and consumption. The app will help you track feed costs and optimize inventory levels.',
    },
    {
      'category': 'Payments',
      'question': 'How do I track payments and expenses?',
      'answer':
          'All transactions are logged in the Reports section. You can filter by date, category, or animal ID for detailed financial tracking.',
    },
    {
      'category': 'Account',
      'question': 'How do I reset my password?',
      'answer':
          'Use the "Forgot Password" option on the login page. You\'ll receive an email with a reset link. If you don\'t receive it, check your spam folder.',
    },
    {
      'category': 'Account',
      'question': 'How do I change my server address?',
      'answer':
          'Open Settings from your profile menu and select "Server Settings". Enter the new server address and save.',
    },
  ];

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionPanelList.radio(
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.zero,
      dividerColor: AppColors.outline,
      children: List.generate(_faqItems.length, (index) {
        final item = _faqItems[index];
        return ExpansionPanelRadio(
          canTapOnHeader: true,
          value: index,
          headerBuilder: (context, isExpanded) => ListTile(
            title: Text(item['question']!),
            subtitle: Text(
              item['category']!,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.primaryGreen),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.primaryGreen,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(item['answer']!),
          ),
        );
      }),
    ),
  );
}

// Ticket Submission Form
class _TicketSubmissionForm extends StatelessWidget {
  final TextEditingController subjectController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final Function(String?) onCategoryChanged;
  final VoidCallback onSubmit;

  const _TicketSubmissionForm({
    required this.subjectController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSubmit,
  });

  final _categories = const [
    'General',
    'Breeding',
    'Vaccination',
    'Feed',
    'Payments',
    'Technical Issue',
    'Other',
  ];

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            onChanged: onCategoryChanged,
            items: _categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            decoration: const InputDecoration(
              hintText: 'Select a category',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text('Subject', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: subjectController,
            decoration: const InputDecoration(
              hintText: 'Brief description of your issue',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text('Description', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Provide details about your issue',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text('Attachment', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                _showMessage(context, 'Photo attachment feature coming soon'),
            icon: const Icon(Icons.attach_file),
            label: const Text('Attach Photo'),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Submit Ticket'),
            ),
          ),
        ],
      ),
    ),
  );
}

// User Guide Section
class _UserGuideSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _GuideTile(
        icon: Icons.play_circle_outline,
        title: 'Getting Started',
        description: 'Learn the basics of using Pig World Smart',
        onTap: () => _showMessage(context, 'Video tutorial loading...'),
      ),
      _GuideTile(
        icon: Icons.show_chart_outlined,
        title: 'Understanding Reports',
        description: 'Make sense of your farm data and analytics',
        onTap: () => _showMessage(context, 'Video tutorial loading...'),
      ),
      _GuideTile(
        icon: Icons.people_outline,
        title: 'Managing Team Access',
        description: 'Set up and manage farm workers and managers',
        onTap: () => _showMessage(context, 'Video tutorial loading...'),
      ),
      _GuideTile(
        icon: Icons.mediation_outlined,
        title: 'Best Practices',
        description: 'Tips for optimal farm management',
        onTap: () => _showMessage(context, 'Video tutorial loading...'),
      ),
    ],
  );
}

// Guide Tile Widget
class _GuideTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _GuideTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radius),
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.mutedText,
            ),
          ],
        ),
      ),
    ),
  );
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
