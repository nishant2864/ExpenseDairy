import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/finance_provider.dart';
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'insights_screen.dart';
import 'advisor_screen.dart';
import 'add_transaction_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const AdvisorScreen(),
    const InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.arrowLeftRight),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.brainCircuit),
            label: 'Advisor',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.pieChart),
            label: 'Insights',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSmartLog(context),
        label: const Text('Smart Log'),
        icon: const Icon(LucideIcons.sparkles),
      ),
    );
  }

  void _showSmartLog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SmartLogOverlay(),
    );
  }
}

class SmartLogOverlay extends StatefulWidget {
  const SmartLogOverlay({super.key});

  @override
  State<SmartLogOverlay> createState() => _SmartLogOverlayState();
}

class _SmartLogOverlayState extends State<SmartLogOverlay> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.sparkles, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'AI Smart Log',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Just type what happened, and I\'ll handle the rest.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g., Spent ₹2500 on dinner at Taj',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () async {
                  if (_controller.text.trim().isEmpty) return;
                  final provider = Provider.of<FinanceProvider>(context, listen: false);
                  Navigator.pop(context);
                  await provider.addSmartTransaction(_controller.text.trim());
                },
                child: const Text('Add with AI'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(kind: 'expense'),
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: const Text('Use standard form'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
