import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import '../models/finance_models.dart';
import '../providers/finance_provider.dart';
import 'ui_elements.dart';


class QuickStatsRow extends StatelessWidget {
  final MonthlySnapshot snapshot;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  const QuickStatsRow({
    super.key,
    required this.snapshot,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Income',
            value: provider.formatCurrency(snapshot.income),
            icon: LucideIcons.arrowDownLeft,
            tint: const Color(0xFF2EC4B6),
            onTap: onIncomeTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Expenses',
            value: provider.formatCurrency(snapshot.expenses),
            icon: LucideIcons.arrowUpRight,
            tint: const Color(0xFFFF6B6B),
            onTap: onExpenseTap,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color tint;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: tint, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpendingChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const SpendingChartCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This month’s spending',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          const _EmptySpendingState()
        else
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final color = (data['colors'] as List<Color>).first;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data['total'],
                              color: color,
                              width: 16,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...items.take(3).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            CategoryIcon(
                              symbol: data['symbol'], 
                              colors: data['colors']
                            ),
                            const SizedBox(width: 12),
                            Text(
                              data['category'],
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              provider.formatCurrency(data['total']),
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (index < 2 && index < items.length - 1)
                        Divider(color: Colors.white.withOpacity(0.15), indent: 44),
                    ],
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final String symbol;
  final List<Color> colors;
  final double size;

  const CategoryIcon({super.key, required this.symbol, required this.colors, this.size = 40});

  IconData _getIconData(String s) {
    switch (s) {
      case 'fork.knife':
      case 'utensils': return LucideIcons.utensils;
      case 'airplane':
      case 'plane': return LucideIcons.plane;
      case 'bag':
      case 'shopping-bag': return LucideIcons.shoppingBag;
      case 'banknote': return LucideIcons.banknote;
      case 'laptopcomputer':
      case 'laptop': return LucideIcons.laptop;
      case 'bolt.fill':
      case 'zap': return LucideIcons.zap;
      case 'cross.case.fill':
      case 'briefcase-medical': return LucideIcons.briefcase;
      case 'lock.shield.fill':
      case 'shield-check': return LucideIcons.shieldCheck;
      default: return LucideIcons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cornerRadiusForSize(size)),
      ),
      child: Center(
        child: Icon(
          _getIconData(symbol),
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  double cornerRadiusForSize(double s) => s == 40 ? 10 : 12;
}

class _EmptySpendingState extends StatelessWidget {
  const _EmptySpendingState();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.barChart2, color: Colors.white.withOpacity(0.35), size: 24),
          const SizedBox(height: 12),
          const Text(
            'No spending yet',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Your category graph appears here as soon as you log expenses.',
            style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
