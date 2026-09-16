import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class PaymentMethodPage extends ConsumerStatefulWidget {
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
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  String _selectedMethod = 'M-Pesa';
  bool _isSubmitting = false;

  Future<void> _handleProceed() async {
    final amount = widget.selectedPlan['amount'];
    final currency = widget.selectedPlan['currency'] ?? 'KES';
    final planCode = widget.selectedPlan['code'] ?? widget.selectedPlan['name'];
    final selectedFarm = ref.read(authProvider).valueOrNull?.selectedFarm;

    if (_selectedMethod != 'M-Pesa') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_selectedMethod is not available for this payment flow yet.',
          ),
        ),
      );
      return;
    }

    if (selectedFarm == null || selectedFarm.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a farm before starting the payment.'),
        ),
      );
      return;
    }

    if (planCode == null || planCode.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This plan is missing its payment code.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await ref
          .read(dioProvider)
          .post(
            '/farms/${selectedFarm.id}/subscription/payment',
            data: {'plan': planCode.toString()},
          );

      final payment = response.data['payment'] is Map
          ? Map<String, dynamic>.from(response.data['payment'] as Map)
          : <String, dynamic>{};

      if (!mounted) return;

      final resultDescription =
          (payment['result_description'] ??
                  'M-Pesa prompt sent. Check your phone and enter your PIN.')
              .toString();

      context.go(
        AppRoutes.paymentStatus,
        extra: {
          'amount': amount,
          'currency': currency,
          'payment_method': _selectedMethod,
          'merchant_request_id': payment['merchant_request_id'] ?? '',
          'checkout_request_id': payment['checkout_request_id'] ?? '',
          'result_description': resultDescription,
        },
      );
    } on DioException catch (error) {
      if (!mounted) return;
      final message = error.response?.data is Map
          ? (error.response!.data['message'] ??
                error.response!.data['error'] ??
                'Unable to start the M-Pesa payment.')
          : 'Unable to start the M-Pesa payment.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message.toString())));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start the M-Pesa payment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

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
                  onPressed: _isSubmitting ? null : _handleProceed,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Proceed'),
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
            RadioGroup<String>(
              groupValue: selected,
              onChanged: (choice) => onSelected(choice ?? value),
              child: Radio<String>(value: value),
            ),
          ],
        ),
      ),
    );
  }
}
