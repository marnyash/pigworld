import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key, required this.selectedPlan});

  final Map<String, dynamic> selectedPlan;

  factory PaymentMethodPage.fromExtra(Object? extra) {
    final payload = extra is Map
        ? Map<String, dynamic>.from(extra)
        : <String, dynamic>{};
    return PaymentMethodPage(
      selectedPlan: Map<String, dynamic>.from(
        payload['selected_plan'] is Map
            ? payload['selected_plan'] as Map
            : <String, dynamic>{},
      ),
    );
  }

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String _selectedMethod = 'M-Pesa';

  @override
  Widget build(BuildContext context) {
    final amount = widget.selectedPlan['amount'];
    final currency = widget.selectedPlan['currency'] ?? 'KES';
    final planName = widget.selectedPlan['name'] ?? 'Selected plan';

    return Scaffold(
      appBar: AppBar(title: const Text('Payment method')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How would you like to pay?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Your selected plan: $planName',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.card_membership_outlined,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$amount $currency',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _PaymentOption(
                title: 'M-Pesa',
                subtitle: 'Pay directly from your phone wallet',
                value: 'M-Pesa',
                selected: _selectedMethod,
                onSelected: (value) => setState(() => _selectedMethod = value),
              ),
              const SizedBox(height: 12),
              _PaymentOption(
                title: 'Airtel Money',
                subtitle: 'Quick mobile money payment',
                value: 'Airtel Money',
                selected: _selectedMethod,
                onSelected: (value) => setState(() => _selectedMethod = value),
              ),
              const SizedBox(height: 12),
              _PaymentOption(
                title: 'Bank transfer',
                subtitle: 'Pay through your bank account',
                value: 'Bank transfer',
                selected: _selectedMethod,
                onSelected: (value) => setState(() => _selectedMethod = value),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(
                    AppRoutes.paymentStatus,
                    extra: {
                      'amount': amount,
                      'currency': currency,
                      'payment_method': _selectedMethod,
                      'result_description': _selectedMethod == 'M-Pesa'
                          ? 'M-Pesa prompt sent. Check your phone and enter your PIN.'
                          : _selectedMethod == 'Airtel Money'
                          ? 'Airtel Money request sent. Approve the transaction on your mobile wallet.'
                          : 'Bank transfer initiated. Complete the transfer using your bank app or branch.',
                    },
                  ),
                  child: const Text('Proceed'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value == 'M-Pesa'
                  ? Icons.phone_android_outlined
                  : value == 'Airtel Money'
                  ? Icons.account_balance_wallet_outlined
                  : Icons.account_balance_outlined,
              color: isSelected ? AppColors.primaryGreen : AppColors.text,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selected,
              onChanged: (choice) => onSelected(choice ?? value),
            ),
          ],
        ),
      ),
    );
  }
}
