import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import '../providers/finance_provider.dart';
import '../widgets/atm_card_view.dart';
import '../widgets/transaction_row.dart';
import '../widgets/home_components.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _MonthPicker(
          selectedMonth: provider.selectedMonth,
          onChanged: provider.setSelectedMonth,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: const Icon(LucideIcons.userCircle),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              _buildHeader(context, provider),
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
          if (provider.isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FinanceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()},',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        Text(
          provider.userDisplayName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your money is organised for ${DateFormat('MMMM').format(provider.selectedMonth)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: onSeeAll,
            label: const Text('See all', style: TextStyle(fontSize: 13)),
            icon: const Icon(LucideIcons.chevronRight, size: 14),
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
    return ActionChip(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select Month', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final month = DateTime(DateTime.now().year, index + 1);
                        final isSelected = month.month == selectedMonth.month;
                        return ListTile(
                          title: Text(DateFormat('MMMM').format(month)),
                          selected: isSelected,
                          trailing: isSelected ? const Icon(LucideIcons.check) : null,
                          onTap: () {
                            onChanged(month);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(DateFormat('MMMM').format(selectedMonth)),
          const SizedBox(width: 4),
          const Icon(LucideIcons.chevronDown, size: 14),
        ],
      ),
      avatar: const Icon(LucideIcons.calendar, size: 16),
    );
  }
}

class _EmptyActivityList extends StatelessWidget {
  const _EmptyActivityList();

  @override
  Widget build(BuildContext context) {
    return MaterialCard(
      child: Column(
        children: [
          Icon(LucideIcons.inbox, size: 32, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Start by adding your first entry.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
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
    return MaterialCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          Icon(LucideIcons.sparkles, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Ready to track?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to unlock deep insights.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)),
          ),
          const SizedBox(height: 24),
          PrimaryButton(title: 'Add Transaction', action: onAdd),
        ],
      ),
    );
  }
}
