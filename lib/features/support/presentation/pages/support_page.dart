import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../notifications/data/notifications_api.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

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

  Future<void> _openContact(Uri uri, String service) async {
    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This device cannot open $service.')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!mounted) return;
    if (launched) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open $service on this device.')),
    );
  }

  Future<void> callVeterinary() =>
      _openContact(Uri.parse('tel:+254705030550'), 'the phone app');

  void _openLiveChat() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const _LiveChatPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final notifications =
            ref.watch(notificationsProvider).valueOrNull ??
            const <FarmNotification>[];
        final crmMessage = notifications.cast<FarmNotification?>().firstWhere(
          (notification) => notification?.type == 'crm_message',
          orElse: () => null,
        );
        final customerCareName = crmMessage?.title.trim().isNotEmpty == true
            ? crmMessage!.title.trim()
            : 'Customer Care';

        return Scaffold(
          endDrawer: _SupportDrawer(
            onOpenContact: _openContact,
            onCall: callVeterinary,
          ),
          appBar: AppBar(
            title: const Text('Customer Support'),
            leading: IconButton(
              tooltip: 'Back to home',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(AppRoutes.home),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  tooltip: 'Guidance and contacts',
                  icon: const Icon(Icons.menu_open),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ],
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
              _SupportHeader(
                customerCareName: customerCareName,
                onEmergencyCall: callVeterinary,
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              Text('Live chat', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimensions.spacingMedium),
              _LiveChatPreview(
                customerCareName: customerCareName,
                message: crmMessage?.body,
                onOpenChat: _openLiveChat,
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              Text(
                'Contact Options',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              _ContactOptionsSection(onOpenContact: _openContact),
              const SizedBox(height: AppDimensions.spacingLarge),
              _EmergencyVeterinaryCard(onCall: callVeterinary),
              const SizedBox(height: AppDimensions.spacingLarge),
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              _FAQSection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              Text(
                'Submit a Ticket',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
              Text(
                'User Guide & Tutorials',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              _UserGuideSection(),
            ],
          ),
        );
      },
    );
  }
}

class _LiveChatPage extends StatefulWidget {
  const _LiveChatPage();

  @override
  State<_LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<_LiveChatPage> {
  final _messageController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _recorder = AudioRecorder();
  XFile? _photo;
  PlatformFile? _document;
  String? _voicePath;
  bool _isRecording = false;

  bool get _hasAttachment =>
      _photo != null || _document != null || _voicePath != null;

  @override
  void dispose() {
    _messageController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final photo = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (!mounted || photo == null) return;
    setState(() => _photo = photo);
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(withData: false);
    if (!mounted || result == null || result.files.isEmpty) return;
    setState(() => _document = result.files.single);
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/pigworld_chat_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    if (mounted) setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _voicePath = path;
    });
  }

  void _clearAttachment() {
    setState(() {
      _photo = null;
      _document = null;
      _voicePath = null;
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty && !_hasAttachment) return;

    final attachmentLabel = _photo != null
        ? 'photo'
        : _document != null
        ? 'document'
        : _voicePath != null
        ? 'voice note'
        : null;
    final suffix = attachmentLabel == null ? '' : ' with $attachmentLabel';

    _messageController.clear();
    _clearAttachment();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message$suffix sent to Customer Care.')),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Photo from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickDocument();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryGreen,
            child: Icon(Icons.support_agent, color: Colors.white, size: 19),
          ),
          SizedBox(width: 10),
          Text('Customer Care'),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Close chat',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F6EC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryGreen,
                        child: Icon(Icons.support_agent, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Customer Care is online. Please leave a message and our team will reply as soon as possible.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: const Text('How can we help with your farm today?'),
                  ),
                ),
              ],
            ),
          ),
          if (_hasAttachment)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _AttachmentPreview(
                photo: _photo,
                document: _document,
                voicePath: _voicePath,
                onRemove: _clearAttachment,
              ),
            ),
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Attach photo or document',
                    onPressed: _showAttachmentOptions,
                    icon: const Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: _isRecording
                            ? 'Recording voice note...'
                            : 'Type a message',
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: _isRecording
                        ? 'Stop voice recording'
                        : 'Record voice message',
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    color: _isRecording ? AppColors.danger : null,
                    icon: Icon(
                      _isRecording ? Icons.stop_circle : Icons.mic_none,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send message',
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.photo,
    required this.document,
    required this.voicePath,
    required this.onRemove,
  });

  final XFile? photo;
  final PlatformFile? document;
  final String? voicePath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = photo != null
        ? photo!.name
        : document != null
        ? document!.name
        : 'Voice note';
    final icon = photo != null
        ? Icons.image_outlined
        : document != null
        ? Icons.insert_drive_file_outlined
        : Icons.mic_none;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            tooltip: 'Remove attachment',
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _SupportDrawer extends StatelessWidget {
  const _SupportDrawer({required this.onOpenContact, required this.onCall});

  final Future<void> Function(Uri uri, String service) onOpenContact;
  final Future<void> Function() onCall;

  @override
  Widget build(BuildContext context) => Drawer(
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(
                Icons.support_agent_outlined,
                size: 28,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Support Center',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Open live chat'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _LiveChatPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Call support'),
            onTap: () async {
              Navigator.of(context).pop();
              await onOpenContact(
                Uri.parse('tel:+254705030550'),
                'the phone app',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_hospital_outlined),
            title: const Text('Vet emergency'),
            onTap: () async {
              Navigator.of(context).pop();
              await onCall();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ'),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Open the FAQ section below.')),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _LiveChatPreview extends StatelessWidget {
  const _LiveChatPreview({
    required this.customerCareName,
    required this.message,
    required this.onOpenChat,
  });

  final String customerCareName;
  final String? message;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          color: const Color(0xFFE7F6EC),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primaryGreen,
                child: Icon(Icons.support_agent, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerCareName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Customer Care · online',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, color: AppColors.primaryGreen),
            ],
          ),
        ),
        Container(
          color: const Color(0xFFF3FBF5),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Text('Hi there! We\'re here to help with your farm.'),
                ),
              ),
              if (message != null && message!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Text(message!),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onOpenChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Continue live chat'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Support Header Widget
class _SupportHeader extends StatelessWidget {
  const _SupportHeader({
    required this.customerCareName,
    required this.onEmergencyCall,
  });

  final String customerCareName;
  final VoidCallback onEmergencyCall;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Card(
        color: AppColors.deepGreen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingLarge,
            AppDimensions.spacingLarge,
            88,
            AppDimensions.spacingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.inverseText.withValues(
                      alpha: 0.18,
                    ),
                    child: const Icon(
                      Icons.support_agent_outlined,
                      color: AppColors.inverseText,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We\'re here to help',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.inverseText),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Online',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.inverseMutedText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customerCareName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.inverseText,
                                fontWeight: FontWeight.w600,
                              ),
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
                  color: AppColors.inverseText.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radius),
                ),
                child: Text(
                  'Average response time: 2-4 hours',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.inverseText),
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        right: 18,
        bottom: 18,
        child: FloatingActionButton(
          heroTag: 'support-emergency-vet',
          mini: true,
          backgroundColor: AppColors.danger,
          foregroundColor: AppColors.inverseText,
          tooltip: 'Call emergency vet',
          onPressed: onEmergencyCall,
          child: const Icon(Icons.phone_in_talk_outlined),
        ),
      ),
    ],
  );
}

// Contact Options Section
class _ContactOptionsSection extends StatelessWidget {
  const _ContactOptionsSection({required this.onOpenContact});

  final Future<void> Function(Uri uri, String service) onOpenContact;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _ContactOptionTile(
        icon: Icons.phone_outlined,
        title: 'Call Support',
        subtitle: '+254705030550',
        actionLabel: 'Call',
        onTap: () =>
            onOpenContact(Uri.parse('tel:+254705030550'), 'the phone app'),
      ),
      _ContactOptionTile(
        icon: Icons.chat_outlined,
        title: 'WhatsApp',
        subtitle: '+254705030550',
        actionLabel: 'Open',
        onTap: () =>
            onOpenContact(Uri.parse('https://wa.me/254705030550'), 'WhatsApp'),
      ),
      _ContactOptionTile(
        icon: Icons.email_outlined,
        title: 'Email Support',
        subtitle: 'info@pigworld.com',
        actionLabel: 'Email',
        onTap: () => onOpenContact(
          Uri(
            scheme: 'mailto',
            path: 'info@pigworld.com',
            queryParameters: {'subject': 'PigWorld support request'},
          ),
          'the email app',
        ),
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
                color: AppColors.inverseText,
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
                        color: AppColors.inverseText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Urgent veterinary assistance: +254705030550',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inverseMutedText,
                      ),
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
                backgroundColor: AppColors.inverseText,
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
