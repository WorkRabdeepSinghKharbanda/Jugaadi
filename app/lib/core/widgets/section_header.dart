import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Uppercase label row with optional trailing widget.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: Row(
        children: [
          Expanded(child: Text(title.toUpperCase(), style: AppText.label.copyWith(color: c.textSecondary))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
