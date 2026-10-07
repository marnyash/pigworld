import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../data/farm_finance_api.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/farm_access_provider.dart';
import '../../../../security/authorization/permissions.dart';
import '../../../../security/authorization/roles.dart';
import '../../../../shared/components/bottom_navigation.dart';
import '../providers/farm_finance_provider.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key, this.typeFilter});

  final String? typeFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).valueOrNull;
    final access = ref.watch(farmAccessProvider).valueOrNull;
    final role = session?.user.role;
    final permissions = session == null
        ? const <AppPermission>{}
        : access?.permissionsFor(session.user.id) ?? const <AppPermission>{};
    final hasFarm = session?.selectedFarm != null;
    final canView =
        role == UserRole.farmOwner ||
        role == UserRole.accountant ||
        permissions.contains(AppPermission.manageFinance);
    final canManage =
        hasFarm &&
        (role == UserRole.farmOwner ||
            role == UserRole.accountant ||
            permissions.contains(AppPermission.manageFinance));
    final finance = canView && hasFarm
        ? ref.watch(farmFinanceProvider)
        : const AsyncData<FarmFinanceState>(FarmFinanceState());
    final title = switch (typeFilter) {
      'income' => 'Income',
      'expense' => 'Expenses',
      _ => 'Finance',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(farmFinanceProvider.future),
        child: !canView || !hasFarm
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 140),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        !hasFarm
                            ? 'Select a farm to view its finances.'
                            : 'You do not have permission to view this farm’s finances.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
            : finance.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.pagePadding),
                  children: [
                    const SizedBox(height: 100),
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load farm finances.\n$error',
                      textAlign: TextAlign.center,
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => ref.invalidate(farmFinanceProvider),
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
                data: (state) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.pagePadding),
                  children: [
                    Card(
                      color: AppColors.deepGreen,
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppDimensions.spacingLarge,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session?.selectedFarm?.name ?? 'Farm finances',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: AppColors.inverseText),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Recorded income and expenses for this calendar month.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.inverseMutedText),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    Text(
                      'This month',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.spacingSmall),
                    if (state.totals.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text(
                            'No transactions recorded this month yet.',
                          ),
                        ),
                      )
                    else
                      ...state.totals.map(
                        (totals) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  totals.currency,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 10),
                                _SummaryLine(
                                  label: 'Income',
                                  value: _money(totals.currency, totals.income),
                                  color: AppColors.success,
                                ),
                                _SummaryLine(
                                  label: 'Expenses',
                                  value: _money(
                                    totals.currency,
                                    totals.expenses,
                                  ),
                                  color: AppColors.warning,
                                ),
                                const Divider(),
                                _SummaryLine(
                                  label: 'Net',
                                  value: _money(totals.currency, totals.profit),
                                  color: AppColors.primaryGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (canManage) ...[
                      const SizedBox(height: AppDimensions.spacingMedium),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _showTransactionDialog(
                                context,
                                ref,
                                type: 'income',
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Record income'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showTransactionDialog(
                                context,
                                ref,
                                type: 'expense',
                              ),
                              icon: const Icon(Icons.remove),
                              label: const Text('Record expense'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppDimensions.spacingLarge),
                    Text(
                      typeFilter == 'income'
                          ? 'Income history'
                          : typeFilter == 'expense'
                          ? 'Expense history'
                          : 'Transaction history',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.spacingSmall),
                    ...state.transactions
                        .where(
                          (transaction) =>
                              typeFilter == null ||
                              transaction.type == typeFilter,
                        )
                        .map(
                          (transaction) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    (transaction.type == 'income'
                                            ? AppColors.success
                                            : AppColors.warning)
                                        .withValues(alpha: 0.14),
                                child: Icon(
                                  transaction.type == 'income'
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: transaction.type == 'income'
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              title: Text(transaction.description),
                              subtitle: Text(
                                '${transaction.category} · ${_date(transaction.occurredAt)}',
                              ),
                              trailing: Text(
                                '${transaction.type == 'income' ? '+' : '−'}${_money(transaction.currency, transaction.amount)}',
                                style: TextStyle(
                                  color: transaction.type == 'income'
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    if (state.transactions
                        .where(
                          (transaction) =>
                              typeFilter == null ||
                              transaction.type == typeFilter,
                        )
                        .isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('No transactions recorded yet.'),
                        ),
                      ),
                    if (state.transactions.length >= 100)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Showing the 100 most recent transactions.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showTransactionDialog(
    BuildContext context,
    WidgetRef ref, {
    required String type,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => _TransactionDialog(
        type: type,
        onSave:
            ({
              required category,
              required description,
              required amount,
              required currency,
              required occurredAt,
            }) => ref
                .read(farmFinanceProvider.notifier)
                .record(
                  type: type,
                  category: category,
                  description: description,
                  amount: amount,
                  currency: currency,
                  occurredAt: occurredAt,
                ),
      ),
    );
  }

  static String _money(String currency, double amount) =>
      '$currency ${amount.toStringAsFixed(2)}';

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _TransactionDialog extends StatefulWidget {
  const _TransactionDialog({required this.type, required this.onSave});

  final String type;
  final Future<void> Function({
    required String category,
    required String description,
    required double amount,
    required String currency,
    required DateTime occurredAt,
  })
  onSave;

  @override
  State<_TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<_TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'KES');
  late DateTime _occurredAt;
  bool _saving = false;

  List<String> get _categories => widget.type == 'income'
      ? const ['Livestock sales', 'Animal products', 'Other income']
      : const [
          'Feed',
          'Veterinary',
          'Labor',
          'Transport',
          'Equipment',
          'Other',
        ];

  @override
  void initState() {
    super.initState();
    _occurredAt = DateTime.now();
    _categoryController.text = _categories.first;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.type == 'income' ? 'Record income' : 'Record expense'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _categoryController.text,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) _categoryController.text = value;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              maxLength: 255,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                return amount == null || amount <= 0 ? 'Enter an amount' : null;
              },
            ),
            TextFormField(
              controller: _currencyController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 3,
              decoration: const InputDecoration(
                labelText: 'Currency code',
                hintText: 'KES',
              ),
              validator: (value) =>
                  RegExp(r'^[A-Za-z]{3}$').hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Enter a 3-letter code',
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Transaction date'),
              subtitle: Text(FinancePage._date(_occurredAt)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _occurredAt,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null && mounted) {
                  setState(() => _occurredAt = date);
                }
              },
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
      ),
    ],
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        category: _categoryController.text,
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text),
        currency: _currencyController.text.trim().toUpperCase(),
        occurredAt: _occurredAt,
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save transaction: $error')),
      );
    }
  }
}
