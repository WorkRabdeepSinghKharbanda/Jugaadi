import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'neu_card.dart';

/// Red-tinted inline error/warning strip. `warning` switches to amber.
class ErrorStrip extends StatelessWidget {
  const ErrorStrip(this.message, {super.key, this.warning = false});
  final String message;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = warning ? c.warning : c.danger;
    return NeuCard(
      variant: NeuVariant.flat,
      color: warning ? c.warning.withValues(alpha: 0.12) : c.dangerSoft,
      radius: AppRadius.sm,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
      child: Row(
        children: [
          Icon(warning ? Icons.wifi_tethering_error_rounded : Icons.error_outline_rounded, color: fg, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: AppText.bodySmall.copyWith(color: fg))),
        ],
      ),
    );
  }
}
