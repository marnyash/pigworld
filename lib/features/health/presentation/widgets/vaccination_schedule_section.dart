import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../providers/health_providers.dart';

class VaccinationScheduleSection extends ConsumerWidget {
  const VaccinationScheduleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(vaccinationScheduleProvider)
      .when(
        data: (vaccinations) {
          if (vaccinations.isEmpty) {
            return Card(
              color: AppColors.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                child: Text(
                  'No vaccinations due at this time',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.text),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vaccinations.length,
            itemBuilder: (context, index) =>
                _VaccinationCard(record: vaccinations[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Card(
          color: AppColors.dangerContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            child: Text(
              'Failed to load vaccinations',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ),
      );
}

class _VaccinationCard extends StatelessWidget {
  final dynamic record;

  const _VaccinationCard({required this.record});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vaccines, color: AppColors.info),
              const SizedBox(width: AppDimensions.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pig ${record.pigId}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    if (record.medication != null)
                      Text(
                        record.medication ?? 'Vaccination',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Due: ${record.nextCheckupDate?.toString().split(' ')[0] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (record.veterinarian != null)
                    Text(
                      'Vet: ${record.veterinarian}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              FilledButton(onPressed: () {}, child: const Text('Mark Done')),
            ],
          ),
        ],
      ),
    ),
  );
}
