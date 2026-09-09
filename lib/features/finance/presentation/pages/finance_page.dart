import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/components/bottom_navigation.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Finance'),
      leading: IconButton(
        tooltip: 'Open menu',
        icon: const Icon(Icons.menu),
        onPressed: () => navigationScaffoldKey.currentState?.openDrawer(),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: [
        Card(
          color: AppColors.deepGreen,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLarge),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.inverseText.withValues(
                    alpha: 0.18,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.inverseText,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farm finances',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.inverseText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Track this month's income, costs, and profit.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inverseMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        const Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Income',
                value: '\$12,480',
                color: AppColors.success,
              ),
            ),
            SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: _MetricCard(
                label: 'Expenses',
                value: '\$7,260',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        const _MetricCard(
          label: 'Net profit',
          value: '\$5,220',
          color: AppColors.primaryGreen,
          showTrend: true,
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text('Cash flow', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.spacingMedium),
        const Card(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: SizedBox(height: 210, child: _CashFlowChart()),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        Text(
          'Monthly performance',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(height: 180, child: _PerformanceChart()),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        FilledButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction history is coming soon.'),
            ),
          ),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('View transaction history'),
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    this.showTrend = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool showTrend;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          if (showTrend) ...[
            const Spacer(),
            const Icon(Icons.trending_up, color: AppColors.success),
          ],
        ],
      ),
    ),
  );
}

class _CashFlowChart extends StatelessWidget {
  const _CashFlowChart();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _CashFlowPainter(), child: const SizedBox.expand());
}

class _PerformanceChart extends StatelessWidget {
  const _PerformanceChart();

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _PerformancePainter(),
    child: const SizedBox.expand(),
  );
}

class _CashFlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = AppColors.text.withValues(alpha: 0.1);
    final income = Paint()
      ..color = AppColors.success
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final expenses = Paint()
      ..color = AppColors.warning
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var row = 1; row < 5; row++) {
      final y = size.height * row / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    _drawLine(canvas, size, [0.32, 0.44, 0.38, 0.56, 0.68, 0.82], income);
    _drawLine(canvas, size, [0.62, 0.54, 0.67, 0.48, 0.58, 0.42], expenses);
  }

  void _drawLine(Canvas canvas, Size size, List<double> values, Paint paint) {
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = size.width * index / (values.length - 1);
      final y = size.height * values[index];
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PerformancePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = AppColors.text.withValues(alpha: 0.1);
    final bar = Paint()..color = AppColors.primaryGreen;
    const values = [0.42, 0.52, 0.47, 0.65, 0.72, 0.88];
    for (var row = 1; row < 5; row++) {
      final y = size.height * row / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final slot = size.width / values.length;
    for (var index = 0; index < values.length; index++) {
      final barHeight = size.height * values[index];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          index * slot + slot * 0.2,
          size.height - barHeight,
          slot * 0.6,
          barHeight,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, bar);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
