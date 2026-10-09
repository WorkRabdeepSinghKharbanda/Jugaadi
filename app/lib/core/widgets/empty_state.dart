import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Centered icon + message for empty lists.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: c.textTertiary),
            const SizedBox(height: AppSpacing.sm),
            Text(text, style: AppText.body.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
