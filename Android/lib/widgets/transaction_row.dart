import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import 'home_components.dart';
import 'ui_elements.dart';

class TransactionRow extends StatelessWidget {
  final TransactionItem item;
  const TransactionRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final isExpense = item.kind == TransactionKind.expense;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MaterialCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        cornerRadius: 12,
        child: Row(
          children: [
            CategoryIcon(
              symbol: item.categorySymbol,
              colors: item.categoryColors,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.categoryTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.note.isEmpty ? 'No note' : item.note,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${currencyFormat.format(item.amount)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isExpense ? colorScheme.error : const Color(0xFF2EC4B6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, h:mm a').format(item.date),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
