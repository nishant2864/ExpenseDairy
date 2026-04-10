import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import 'home_components.dart' hide GlassCard;
import 'ui_elements.dart';

class TransactionRow extends StatelessWidget {
  final TransactionItem item;
  const TransactionRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);
    final isExpense = item.kind == TransactionKind.expense;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        cornerRadius: 16,
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
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.note.isEmpty ? 'No note' : item.note,
                    style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
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
                  style: TextStyle(
                    color: isExpense ? Colors.white : const Color(0xFF2EC4B6),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(item.date),
                  style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
