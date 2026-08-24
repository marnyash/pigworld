import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../domain/entities/customer.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({required this.customer, required this.onTap, super.key});

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(customer.status);
    final subtitleParts = [
      if (customer.company != null && customer.company!.isNotEmpty)
        customer.company!,
      if (customer.phone != null && customer.phone!.isNotEmpty) customer.phone!,
    ];

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium,
          vertical: AppDimensions.spacingSmall,
        ),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(_typeIcon(customer.type), color: statusColor),
        ),
        title: Text(customer.name),
        subtitle: subtitleParts.isEmpty
            ? null
            : Text(subtitleParts.join(' • ')),
        trailing: Chip(
          label: Text(customer.status.label),
          backgroundColor: statusColor.withValues(alpha: 0.12),
          labelStyle: TextStyle(color: statusColor),
        ),
      ),
    );
  }

  IconData _typeIcon(CustomerType type) => switch (type) {
    CustomerType.lead => Icons.person_search_outlined,
    CustomerType.buyer => Icons.shopping_bag_outlined,
    CustomerType.supplier => Icons.local_shipping_outlined,
  };

  Color _statusColor(CustomerStatus status) => switch (status) {
    CustomerStatus.new_ => AppColors.warning,
    CustomerStatus.contacted => AppColors.primaryGreen,
    CustomerStatus.qualified => AppColors.deepGreen,
    CustomerStatus.won => AppColors.success,
    CustomerStatus.lost => AppColors.danger,
  };
}
