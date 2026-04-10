import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/finance_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_container.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return MaterialApp(
      title: 'Expense Diary',
      debugShowCheckedModeBanner: false,
      themeMode: provider.appearance,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F8EF7),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        useMaterial3: true,
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F8EF7),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFEBF4F6),
        useMaterial3: true,
      ),
      home: provider.hasCompletedOnboarding 
          ? const MainContainer() 
          : const OnboardingScreen(),
    );
  }
}
