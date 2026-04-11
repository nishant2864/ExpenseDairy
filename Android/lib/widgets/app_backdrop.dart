import 'package:flutter/material.dart';

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    // Standard Material 3 background
    return Container(
      color: Theme.of(context).colorScheme.surface,
    );
  }
}
