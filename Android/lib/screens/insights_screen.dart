import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../models/finance_models.dart';
import '../providers/finance_provider.dart';
import '../widgets/ui_elements.dart';
import '../widgets/home_components.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final hasTransactions = provider.transactions.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: hasTransactions ? ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SummaryRingCard(
            income: provider.monthlySnapshot.income,
            expenses: provider.monthlySnapshot.expenses,
            formatCurrency: provider.formatCurrency,
          ),
          const SizedBox(height: 20),
          CategoryBreakdownCard(
            title: 'Expense categories',
            items: provider.monthlyTotalsByCategory(TransactionKind.expense),
            formatCurrency: provider.formatCurrency,
          ),
          const SizedBox(height: 20),
          CategoryBreakdownCard(
            title: 'Income sources',
            items: provider.monthlyTotalsByCategory(TransactionKind.income),
            formatCurrency: provider.formatCurrency,
          ),
          const SizedBox(height: 40),
        ],
      ) : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: MaterialCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.pieChart, color: Theme.of(context).colorScheme.outline, size: 64),
              const SizedBox(height: 20),
              Text(
                'Insights appear after your first entries',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Add income and expenses first. Then this tab will animate your monthly balance and category breakdown.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryRingCard extends StatelessWidget {
  final double income;
  final double expenses;
  final String Function(double) formatCurrency;

  const SummaryRingCard({
    super.key,
    required this.income,
    required this.expenses,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expenses;
    final incomeRatio = total > 0 ? income / total : 0.0;
    final expenseRatio = total > 0 ? expenses / total : 0.0;

    return MaterialCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Balance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 50,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: income > 0 ? income : 1,
                        color: const Color(0xFF2EC4B6),
                        radius: 12,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: expenses > 0 ? expenses : 1,
                        color: const Color(0xFFFF6B6B),
                        radius: 12,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  children: [
                    _RingStatRow(
                      label: 'Income',
                      value: formatCurrency(income),
                      color: const Color(0xFF2EC4B6),
                      percentage: (incomeRatio * 100).toInt(),
                    ),
                    const SizedBox(height: 16),
                    _RingStatRow(
                      label: 'Expenses',
                      value: formatCurrency(expenses),
                      color: const Color(0xFFFF6B6B),
                      percentage: (expenseRatio * 100).toInt(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final int percentage;

  const _RingStatRow({required this.label, required this.value, required this.color, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Text('$percentage%', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline)),
      ],
    );
  }
}

class CategoryBreakdownCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String Function(double) formatCurrency;

  const CategoryBreakdownCard({
    super.key,
    required this.title,
    required this.items,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final maxTotal = items.fold<double>(0, (prev, element) => math.max(prev, (element['total'] as double)));
    final colorScheme = Theme.of(context).colorScheme;

    return MaterialCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final double total = item['total'];
            final ratio = maxTotal > 0 ? total / maxTotal : 0.0;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CategoryIcon(symbol: item['symbol'], colors: item['colors'], size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['category'], style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                Text(formatCurrency(total), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation((item['colors'] as List<Color>).first),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < items.length - 1)
                  Divider(color: colorScheme.outlineVariant, indent: 50),
              ],
            );
          }),
        ],
      ),
    );
  }
}
