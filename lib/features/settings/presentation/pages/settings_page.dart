import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _serverUrl;

  @override
  void initState() {
    super.initState();
    _serverUrl = TextEditingController(text: ApiConfig.baseUrl);
    Future<void>(() async {
      final saved = await ServerAddressStorage.read();
      if (mounted && saved != null) _serverUrl.text = saved;
    });
  }

  @override
  void dispose() {
    _serverUrl.dispose();
    super.dispose();
  }

  Future<void> _saveServerUrl() async {
    final value = _serverUrl.text.trim();
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a complete server URL.')),
      );
      return;
    }
    await ServerAddressStorage.write(value);
    ref.invalidate(serverUrlProvider);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Server address saved.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Connection', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
          'Point the app at your farm server on a LAN, tunnel, or public domain.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _serverUrl,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'API server URL',
            hintText: 'https://example.com/api/v1',
            prefixIcon: Icon(Icons.public),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _saveServerUrl,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save server address'),
        ),
      ],
    ),
  );
}
