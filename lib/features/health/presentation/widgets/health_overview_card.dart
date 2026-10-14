import 'package:flutter/material.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/pig_world_icon.dart';

class HealthOverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? assetName;
  final Color color;

  const HealthOverviewCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.assetName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radius),
            ),
            child: assetName == null
                ? Icon(icon, color: color, size: 32)
                : PigWorldIcon(assetName!, size: 32),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
