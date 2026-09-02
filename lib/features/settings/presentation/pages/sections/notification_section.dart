import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/settings/presentation/providers/settings_providers.dart';

class NotificationSection extends ConsumerWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(userPreferencesProvider);

    return preferences.when(
      data: (prefs) => ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Preferences',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  ..._buildNotificationTiles(context, ref, prefs),
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
                    'Notification Channels',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    value: true,
                    onChanged: (_) {},
                  ),
                  SwitchListTile(
                    title: const Text('SMS Notifications'),
                    value: false,
                    onChanged: (_) {},
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    value: true,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  List<Widget> _buildNotificationTiles(
    BuildContext context,
    WidgetRef ref,
    prefs,
  ) {
    final notifications = [
      (
        'vaccinations',
        'Vaccination Reminders',
        'Get alerts for vaccination schedules',
      ),
      (
        'feeding',
        'Feeding Reminders',
        'Reminders for feeding times and amounts',
      ),
      ('breeding', 'Breeding Alerts', 'Alerts for breeding seasons'),
      (
        'lowStock',
        'Low Stock Alerts',
        'Notifications when feed or supplies are low',
      ),
      ('sales', 'Sales Notifications', 'Updates on sales and orders'),
      ('payments', 'Payment Notifications', 'Alerts for payments and invoices'),
    ];

    return notifications.map((tuple) {
      final (type, title, subtitle) = tuple;
      return Column(
        children: [
          SwitchListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            value: prefs.notifications[type] ?? true,
            onChanged: (value) {
              ref
                  .read(userPreferencesProvider.notifier)
                  .updateNotificationToggle(type, value);
            },
          ),
          if (type != 'payments') const Divider(),
        ],
      );
    }).toList();
  }
}
