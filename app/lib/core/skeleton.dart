import 'package:flutter/material.dart';
import 'theme/tokens.dart';

/// Pulsing placeholder cards shown while a list loads (instead of a lone spinner).
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_pulse),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
        itemCount: widget.itemCount,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: c.surface, borderRadius: AppRadius.mdAll),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(c, 180, 16),
              const SizedBox(height: AppSpacing.sm),
              _bar(c, 110, 12),
              const SizedBox(height: AppSpacing.sm),
              _bar(c, 150, 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(AppColors c, double w, double h) =>
      Container(width: w, height: h, decoration: BoxDecoration(color: c.surfaceHigh, borderRadius: BorderRadius.circular(6)));
}
