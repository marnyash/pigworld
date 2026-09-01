import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/settings/presentation/providers/settings_providers.dart';

class BackupSection extends ConsumerWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupSettings = ref.watch(backupSettingsProvider);

    return backupSettings.when(
      data: (settings) => ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          // Cloud Sync
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cloud Sync',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Automatically sync farm data to cloud',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Switch(
                        value: settings.cloudSyncEnabled,
                        onChanged: (value) {
                          ref
                              .read(backupSettingsProvider.notifier)
                              .updateCloudSync(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // Automatic Backup
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Automatic Backup',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create regular backups of your data',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Switch(
                        value: settings.automaticBackupEnabled,
                        onChanged: (value) {
                          ref
                              .read(backupSettingsProvider.notifier)
                              .updateAutoBackup(value);
                        },
                      ),
                    ],
                  ),
                  if (settings.automaticBackupEnabled) ...[
                    const SizedBox(height: AppDimensions.spacingMedium),
                    DropdownButtonFormField<String>(
                      initialValue: settings.backupFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Backup Frequency',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('Monthly'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(backupSettingsProvider.notifier)
                              .updateBackupFrequency(value);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // Offline Mode
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offline Mode',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Work without internet connection',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Switch(
                        value: settings.offlineModeEnabled,
                        onChanged: (value) {
                          ref
                              .read(backupSettingsProvider.notifier)
                              .updateOfflineMode(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // Backup Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backup Management',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  if (settings.lastBackupDate != null)
                    Text(
                      'Last backup: ${settings.lastBackupDate}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        // TODO: Implement backup now
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup started...')),
                        );
                      },
                      icon: const Icon(Icons.backup),
                      label: const Text('Backup Now'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement restore
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore Backup'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // Export Data
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Data',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Export as PDF
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export as PDF'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Export as Excel
                      },
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Export as Excel'),
                    ),
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
}
