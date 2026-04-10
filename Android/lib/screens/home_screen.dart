import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/atm_card_view.dart';
import '../widgets/transaction_row.dart';
import '../widgets/home_components.dart' hide GlassCard;
import '../widgets/ui_elements.dart';
import 'profile_screen.dart';
import 'transactions_screen.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final snapshot = provider.monthlySnapshot;
    final recent = provider.recentTransactions;
    final hasTransactions = provider.hasTransactions;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: _MonthPicker(
            selectedMonth: provider.selectedMonth,
            onChanged: provider.setSelectedMonth,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(LucideIcons.userCircle, size: 26, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const AppBackdrop(),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                _buildHeader(provider),
                const SizedBox(height: 24),
                ATMCardView(snapshot: snapshot),
                const SizedBox(height: 28),
                if (hasTransactions) ...[
                  QuickStatsRow(snapshot: snapshot),
                  const SizedBox(height: 32),
                  SpendingChartCard(
                    items: provider.monthlyTotalsByCategory(TransactionKind.expense),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionHeader(
                    context,
                    'Recent activity',
                    onSeeAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                    ),
                  ),
                  if (recent.isEmpty)
                    const _EmptyActivityList()
                  else
                    ...recent.take(3).map((item) => TransactionRow(item: item)),
                ] else
                    _FirstRunCard(onAdd: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddTransactionScreen(kind: 'expense')),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(FinanceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()},',
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        Text(
          provider.userDisplayName,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your money is organised for ${DateFormat('MMMM').format(provider.selectedMonth)}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Row(
              children: [
                Text(
                  'See all',
                  style: TextStyle(color: Color(0xFF4F8EF7), fontWeight: FontWeight.w600, fontSize: 13),
                ),
                SizedBox(width: 4),
                Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF4F8EF7)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onChanged;

  const _MonthPicker({required this.selectedMonth, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         showModalBottomSheet(
           context: context,
           backgroundColor: const Color(0xFF16213E),
           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
           builder: (context) {
             return Padding(
               padding: const EdgeInsets.symmetric(vertical: 20),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Text('Select Month', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                   const SizedBox(height: 14),
                   ...List.generate(12, (index) {
                     final month = DateTime(DateTime.now().year, index + 1);
                     final isSelected = month.month == selectedMonth.month;
                     return ListTile(
                       title: Text(
                         DateFormat('MMMM').format(month),
                         style: TextStyle(color: isSelected ? const Color(0xFF4F8EF7) : Colors.white),
                       ),
                       trailing: isSelected ? const Icon(LucideIcons.check, color: Color(0xFF4F8EF7), size: 18) : null,
                       onTap: () {
                         onChanged(month);
                         Navigator.pop(context);
                       },
                     );
                   }),
                 ],
               ),
             );
           },
         );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('MMMM').format(selectedMonth),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(width: 4),
            const Icon(LucideIcons.chevronDown, size: 14, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivityList extends StatelessWidget {
  const _EmptyActivityList();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Icon(LucideIcons.inbox, size: 32, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          const Text(
            'No transactions yet',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Start by adding your first income or expense and the monthly story will build itself.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _FirstRunCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _FirstRunCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: const Color(0xFF4F8EF7).withOpacity(0.12),
      child: Column(
        children: [
          const Icon(LucideIcons.sparkles, size: 40, color: Color(0xFF4F8EF7)),
          const SizedBox(height: 16),
          const Text(
            'Ready to track?',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to unlock deep insights and beautiful visualisations.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 14),
          ),
          const SizedBox(height: 24),
          PrimaryButton(title: 'Add Transaction', action: onAdd),
        ],
      ),
    );
  }
}
