import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_colors.dart';
import 'package:proj/app/theme/app_dimensions.dart';

class ConnectedDevicesSection extends ConsumerWidget {
  const ConnectedDevicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: [
        // Available Device Types
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Devices',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                _DeviceTile(
                  icon: Icons.nfc,
                  title: 'RFID Scanner',
                  subtitle: 'Scan animal tags and equipment',
                  isConnected: false,
                  onTap: () {
                    // TODO: Pair RFID scanner
                  },
                ),
                const Divider(),
                _DeviceTile(
                  icon: Icons.scale,
                  title: 'Weighing Scale',
                  subtitle: 'Connect Bluetooth weighing scale',
                  isConnected: false,
                  onTap: () {
                    // TODO: Pair weighing scale
                  },
                ),
                const Divider(),
                _DeviceTile(
                  icon: Icons.location_on,
                  title: 'GPS Tracker',
                  subtitle: 'Track animal locations',
                  isConnected: false,
                  onTap: () {
                    // TODO: Configure GPS tracker
                  },
                ),
                const Divider(),
                _DeviceTile(
                  icon: Icons.camera_alt,
                  title: 'Camera',
                  subtitle: 'Enable camera permissions',
                  isConnected: true,
                  onTap: () {
                    // TODO: Manage camera permissions
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        // Permissions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Permissions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                SwitchListTile(
                  title: const Text('Camera'),
                  subtitle: const Text('Allow access to device camera'),
                  value: true,
                  onChanged: (_) {},
                ),
                SwitchListTile(
                  title: const Text('Bluetooth'),
                  subtitle: const Text('Allow Bluetooth device connections'),
                  value: true,
                  onChanged: (_) {},
                ),
                SwitchListTile(
                  title: const Text('Location'),
                  subtitle: const Text('Allow access to device location'),
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
      ],
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isConnected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isConnected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primaryGreen),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: isConnected
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Connected',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.success),
            ),
          )
        : const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
