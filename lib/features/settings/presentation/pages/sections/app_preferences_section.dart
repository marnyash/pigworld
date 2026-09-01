import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/app/theme/app_dimensions.dart';
import 'package:proj/features/settings/presentation/providers/settings_providers.dart';

class AppPreferencesSection extends ConsumerWidget {
  const AppPreferencesSection({super.key});

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
                    'Language',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _buildDropdown(
                    context,
                    'Select Language',
                    prefs.language,
                    [('en', 'English'), ('sw', 'Kiswahili')],
                    (value) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .updateLanguage(value);
                    },
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dark Mode',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Switch(
                        value: prefs.isDarkMode,
                        onChanged: (value) {
                          ref
                              .read(userPreferencesProvider.notifier)
                              .updateTheme(value);
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Use dark theme for reduced eye strain',
                    style: Theme.of(context).textTheme.bodySmall,
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
                    'Measurement Units',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _buildDropdown(
                    context,
                    'Weight Unit',
                    prefs.weightUnit,
                    [('kg', 'Kilograms (kg)'), ('lb', 'Pounds (lb)')],
                    (value) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .updateWeightUnit(value);
                    },
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
                    'Date Format',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _buildDropdown(
                    context,
                    'Select Format',
                    prefs.dateFormat,
                    [
                      ('dd/MM/yyyy', 'DD/MM/YYYY'),
                      ('MM/dd/yyyy', 'MM/DD/YYYY'),
                      ('yyyy-MM-dd', 'YYYY-MM-DD'),
                    ],
                    (value) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .updateDateFormat(value);
                    },
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
                    'Currency',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _buildDropdown(
                    context,
                    'Select Currency',
                    prefs.currency,
                    [
                      ('KES', 'Kenyan Shilling (KES)'),
                      ('USD', 'US Dollar (USD)'),
                    ],
                    (value) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .updateCurrency(value);
                    },
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

  Widget _buildDropdown(
    BuildContext context,
    String label,
    String currentValue,
    List<(String, String)> options,
    Function(String) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: currentValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.tune),
      ),
      items: options
          .map(
            (option) =>
                DropdownMenuItem(value: option.$1, child: Text(option.$2)),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
