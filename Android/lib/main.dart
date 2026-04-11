import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/finance_provider.dart';
import 'screens/launch_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_container.dart';
import 'widgets/ui_elements.dart';

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

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  bool _showLaunch = true;

  @override
  Widget build(BuildContext context) {
    if (_showLaunch) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: LaunchScreen(
          onFinish: () {
            setState(() {
              _showLaunch = false;
            });
          },
        ),
      );
    }

    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'Expense Diary',
          debugShowCheckedModeBanner: false,
          themeMode: provider.appearance,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.accent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: const TextTheme(
              displayLarge: TextStyle(color: Colors.white),
              displayMedium: TextStyle(color: Colors.white),
              displaySmall: TextStyle(color: Colors.white),
              headlineLarge: TextStyle(color: Colors.white),
              headlineMedium: TextStyle(color: Colors.white),
              headlineSmall: TextStyle(color: Colors.white),
              titleLarge: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              titleSmall: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
              labelLarge: TextStyle(color: Colors.white),
              labelMedium: TextStyle(color: Colors.white),
              labelSmall: TextStyle(color: Colors.white),
            ),
          ),
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.accent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: const TextTheme(
              displayLarge: TextStyle(color: Colors.black),
              displayMedium: TextStyle(color: Colors.black),
              displaySmall: TextStyle(color: Colors.black),
              headlineLarge: TextStyle(color: Colors.black),
              headlineMedium: TextStyle(color: Colors.black),
              headlineSmall: TextStyle(color: Colors.black),
              titleLarge: TextStyle(color: Colors.black),
              titleMedium: TextStyle(color: Colors.black),
              titleSmall: TextStyle(color: Colors.black),
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
              bodySmall: TextStyle(color: Colors.black),
              labelLarge: TextStyle(color: Colors.black),
              labelMedium: TextStyle(color: Colors.black),
              labelSmall: TextStyle(color: Colors.black),
            ),
          ),
          home: provider.hasCompletedOnboarding 
              ? const MainContainer() 
              : const OnboardingScreen(),
        );
      },
    );
  }
}
