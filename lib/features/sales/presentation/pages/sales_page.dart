import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/components/bottom_navigation.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sales = <_SaleRecord>[
      const _SaleRecord(
        invoice: 'INV-2026-001',
        pigId: 'PG-104',
        customer: 'John Kamau',
        phone: '+254 712 345 678',
        weight: '92 kg',
        amount: 'KSh 28,000',
        method: 'M-Pesa',
        ref: 'TJA89KLM2',
        date: '1 Sept 2026',
        status: 'Paid',
      ),
      const _SaleRecord(
        invoice: 'INV-2026-002',
        pigId: 'PG-118',
        customer: 'Mary Wanjiru',
        phone: '+254 722 447 198',
        weight: '84 kg',
        amount: 'KSh 24,500',
        method: 'Cash',
        ref: '-',
        date: '4 Sept 2026',
        status: 'Partial',
      ),
      const _SaleRecord(
        invoice: 'INV-2026-003',
        pigId: 'PG-133',
        customer: 'Samuel Otieno',
        phone: '+254 734 561 225',
        weight: '76 kg',
        amount: 'KSh 20,700',
        method: 'Bank',
        ref: 'BK-201932',
        date: '8 Sept 2026',
        status: 'Unpaid',
      ),
    ];

    final customers = <_CustomerSummary>[
      const _CustomerSummary(
        name: 'John Kamau',
        phone: '+254 712 345 678',
        email: 'john.kamau@gmail.com',
        purchases: 6,
        balance: 'KSh 0',
      ),
      const _CustomerSummary(
        name: 'Mary Wanjiru',
        phone: '+254 722 447 198',
        email: 'maryw@gmail.com',
        purchases: 4,
        balance: 'KSh 8,200',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        leading: IconButton(
          tooltip: 'Open menu',
          icon: const Icon(Icons.menu),
          onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New sale form is ready for the next build step.'),
          ),
        ),
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Create New Sale'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          _HeaderCard(
            title: 'Sales Overview',
            subtitle: 'Pig sales, customer balances, and profit tracking.',
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          const _OverviewGrid(),
          const SizedBox(height: AppDimensions.spacingLarge),
          _SectionHeader(title: 'New Sale'),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'Select Pig',
                          value: 'PG-104',
                          icon: Icons.pets_outlined,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingMedium),
                      Expanded(
                        child: _FormField(
                          label: 'Customer',
                          value: 'John Kamau',
                          icon: Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'Selling Price',
                          value: 'KSh 28,000',
                          icon: Icons.attach_money_outlined,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingMedium),
                      Expanded(
                        child: _FormField(
                          label: 'Weight',
                          value: '92 kg',
                          icon: Icons.monitor_weight_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  DropdownButtonFormField<String>(
                    initialValue: 'M-Pesa',
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'M-Pesa', child: Text('M-Pesa')),
                      DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sale completed and herd inventory updated.',
                              ),
                            ),
                          ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete Sale'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          _SectionHeader(title: 'Customers'),
          const SizedBox(height: AppDimensions.spacingMedium),
          ...customers.map(
            (customer) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spacingMedium,
              ),
              child: _CustomerCard(customer: customer),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          _SectionHeader(title: 'Sales History'),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMedium),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search invoice, pig ID, customer…',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          ...sales.map(
            (sale) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.spacingMedium,
              ),
              child: _SalesHistoryCard(sale: sale),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          _SectionHeader(title: 'Payments'),
          const SizedBox(height: AppDimensions.spacingMedium),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLarge),
              child: Column(
                children: [
                  _PaymentRow(
                    label: 'Outstanding balance',
                    value: 'KSh 8,200',
                    tone: AppColors.warning,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _PaymentRow(
                    label: 'This month received',
                    value: 'KSh 52,400',
                    tone: AppColors.success,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  _PaymentRow(
                    label: 'M-Pesa ref',
                    value: 'TJA89KLM2',
                    tone: AppColors.info,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          _SectionHeader(title: 'Revenue Analytics'),
          const SizedBox(height: AppDimensions.spacingMedium),
          const Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: SizedBox(height: 180, child: _RevenueChart()),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          const _AnalyticsStatsRow(),
          const SizedBox(height: AppDimensions.spacingLarge),
          const _InventorySyncCard(),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.deepGreen,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.point_of_sale,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      const _MetricCard(
        label: "Today's Sales",
        value: 'KSh 42,000',
        color: AppColors.success,
      ),
      const _MetricCard(
        label: 'Monthly Revenue',
        value: 'KSh 318,500',
        color: AppColors.primaryGreen,
      ),
      const _MetricCard(label: 'Pigs Sold', value: '17', color: AppColors.info),
      const _MetricCard(
        label: 'Outstanding',
        value: 'KSh 26,400',
        color: AppColors.warning,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimensions.spacingMedium,
      crossAxisSpacing: AppDimensions.spacingMedium,
      // A square tile leaves room when labels such as "Monthly Revenue"
      // wrap on compact phone layouts.
      childAspectRatio: 1,
      children: items,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final _CustomerSummary customer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                customer.name.substring(0, 1),
                style: const TextStyle(
                  color: AppColors.deepGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(customer.phone),
                  const SizedBox(height: 2),
                  Text(
                    customer.email,
                    style: TextStyle(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoPill(
                        label: 'Purchases',
                        value: '${customer.purchases}',
                      ),
                      const SizedBox(width: 8),
                      _InfoPill(label: 'Balance due', value: customer.balance),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: AppColors.mutedText),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesHistoryCard extends StatelessWidget {
  const _SalesHistoryCard({required this.sale});

  final _SaleRecord sale;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (sale.status) {
      'Paid' => AppColors.success,
      'Partial' => AppColors.warning,
      _ => AppColors.danger,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    sale.invoice,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    sale.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _StatPair(label: 'Pig', value: sale.pigId),
                _StatPair(label: 'Customer', value: sale.customer),
                _StatPair(label: 'Date', value: sale.date),
                _StatPair(label: 'Amount', value: sale.amount),
                _StatPair(label: 'Method', value: sale.method),
                _StatPair(label: 'M-Pesa Ref', value: sale.ref),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPair extends StatelessWidget {
  const _StatPair({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            value,
            style: TextStyle(color: tone, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RevenuePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _RevenuePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = AppColors.text.withValues(alpha: 0.08);
    final linePaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final values = [0.25, 0.4, 0.32, 0.52, 0.74, 0.62, 0.9];
    for (var row = 1; row < 5; row++) {
      final y = size.height * row / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = size.width * index / (values.length - 1);
      final y = size.height - (size.height * values[index]);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final textStyle = TextStyle(color: AppColors.mutedText, fontSize: 10);
    for (var index = 0; index < labels.length; index++) {
      final x = size.width * index / (labels.length - 1);
      final textPainter = TextPainter(
        text: TextSpan(text: labels[index], style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - (textPainter.width / 2), size.height - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnalyticsStatsRow extends StatelessWidget {
  const _AnalyticsStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MetricPill(label: 'Avg. selling price', value: 'KSh 26,700'),
        ),
        SizedBox(width: AppDimensions.spacingMedium),
        Expanded(
          child: _MetricPill(label: 'Profit vs expense', value: '+18.4%'),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySyncCard extends StatelessWidget {
  const _InventorySyncCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Row(
          children: [
            const Icon(Icons.sync_alt_outlined, color: AppColors.deepGreen),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Text(
                'Sold pigs are automatically removed from active herd inventory while keeping the full history of each sale record intact.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.deepGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerSummary {
  const _CustomerSummary({
    required this.name,
    required this.phone,
    required this.email,
    required this.purchases,
    required this.balance,
  });

  final String name;
  final String phone;
  final String email;
  final int purchases;
  final String balance;
}

class _SaleRecord {
  const _SaleRecord({
    required this.invoice,
    required this.pigId,
    required this.customer,
    required this.phone,
    required this.weight,
    required this.amount,
    required this.method,
    required this.ref,
    required this.date,
    required this.status,
  });

  final String invoice;
  final String pigId;
  final String customer;
  final String phone;
  final String weight;
  final String amount;
  final String method;
  final String ref;
  final String date;
  final String status;
}
