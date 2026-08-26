import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
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
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: [
        Card(
          color: AppColors.deepGreen,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_done_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Point the app at your farm server on a LAN, tunnel, or public domain.',
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API server URL',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _serverUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.public),
                    hintText: 'https://example.com/api/v1',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saveServerUrl,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save server address'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick tips',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _TipRow(
                  icon: Icons.wifi_tethering,
                  text: 'Use the LAN IP for local testing.',
                ),
                const SizedBox(height: 8),
                _TipRow(
                  icon: Icons.security,
                  text: 'Keep the URL secure and include /api/v1.',
                ),
                const SizedBox(height: 8),
                _TipRow(
                  icon: Icons.sync,
                  text: 'Save changes and refresh the app if needed.',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: AppColors.primaryGreen),
      const SizedBox(width: 10),
      Expanded(child: Text(text)),
    ],
  );
}
