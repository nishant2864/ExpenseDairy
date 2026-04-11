import 'package:flutter/material.dart';

class AppColors {
  static const Color accent = Color(0xFF09637E);
  // Using more standard Material 3 colors
  static Color getSurface(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color getOnSurface(BuildContext context) => Theme.of(context).colorScheme.onSurface;
}

class MaterialCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double cornerRadius;
  final Color? color;
  final double? elevation;

  const MaterialCard({
    super.key,
    required this.child,
    this.padding,
    this.cornerRadius = 16, // Material 3 standard
    this.color,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      color: color ?? Theme.of(context).colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// Keeping GlassCard for compatibility during migration, but it now looks standard
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double cornerRadius;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.cornerRadius = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialCard(
      padding: padding,
      cornerRadius: cornerRadius,
      color: color,
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback action;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.action,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : action,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
