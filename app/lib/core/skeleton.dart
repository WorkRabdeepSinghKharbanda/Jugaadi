import 'package:flutter/material.dart';
import 'theme/tokens.dart';
import 'widgets/shimmer_box.dart';

/// Shimmering placeholder cards shown while a list loads (instead of a lone spinner).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.md,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: AppRadius.mdAll,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 180, height: 16),
            SizedBox(height: AppSpacing.sm),
            ShimmerBox(width: 110, height: 12),
            SizedBox(height: AppSpacing.sm),
            ShimmerBox(width: 150, height: 12),
          ],
        ),
      ),
    );
  }
}
