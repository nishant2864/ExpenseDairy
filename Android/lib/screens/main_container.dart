import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'insights_screen.dart';
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
    const InsightsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5)),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: const Color(0xFF16213E).withOpacity(0.4),
              elevation: 0,
              selectedItemColor: const Color(0xFF4F8EF7),
              unselectedItemColor: Colors.white.withOpacity(0.4),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
              items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              activeIcon: Icon(LucideIcons.home, color: Color(0xFF4F8EF7)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.arrowLeftRight),
              activeIcon: Icon(LucideIcons.arrowLeftRight, color: Color(0xFF4F8EF7)),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.pieChart),
              activeIcon: Icon(LucideIcons.pieChart, color: Color(0xFF4F8EF7)),
              label: 'Insights',
            ),
            ],
          ),
        ),
      ),
    ),
    floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(kind: 'expense'),
              fullscreenDialog: true,
            ),
          ),
          backgroundColor: const Color(0xFF4F8EF7),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(LucideIcons.plus, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
