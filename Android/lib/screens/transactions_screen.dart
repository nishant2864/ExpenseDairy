import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/finance_provider.dart';
import '../widgets/transaction_row.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/ui_elements.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final transactions = provider.transactions.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.categoryTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             t.note.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Transactions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          const AppBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: transactions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) => TransactionRow(item: transactions[index]),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        cornerRadius: 18,
        child: Row(
          children: [
            Icon(LucideIcons.search, color: Colors.white.withOpacity(0.4), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.searchX, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 18),
          ),
        ],
      ),
    );
  }
}
