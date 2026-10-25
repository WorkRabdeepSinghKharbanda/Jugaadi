import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'motion.dart';

enum NeuVariant { raised, pressed, flat }

/// Charcoal neumorphic card with a 1 px gradient hairline edge. `gradientBorder` paints an
/// accent gradient edge (CRED reward-card look). `onTap` makes it a tappable surface with
/// scale + shadow-compress press feedback.
class NeuCard extends StatefulWidget {
  const NeuCard({
    super.key,
    required this.child,
    this.variant = NeuVariant.raised,
    this.gradientBorder = false,
    this.padding = AppSpacing.card,
    this.radius = AppRadius.md,
    this.onTap,
    this.color,
  });

  final Widget child;
  final NeuVariant variant;
  final bool gradientBorder;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;

  @override
  State<NeuCard> createState() => _NeuCardState();
}

class _NeuCardState extends State<NeuCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fill =
        widget.color ??
        switch (widget.variant) {
          NeuVariant.raised => c.surface,
          NeuVariant.pressed => c.surfaceLow,
          NeuVariant.flat => c.surface,
        };
    final shadows = widget.variant != NeuVariant.raised
        ? AppShadows.none
        : (_down ? AppShadows.compressed(c) : AppShadows.raised(c));
    final edgeGradient = widget.gradientBorder ? c.accentGradient : c.hairline;

    final body = AnimatedContainer(
      duration: AppDurations.of(context, AppDurations.fast),
      curve: AppDurations.curve,
      padding: EdgeInsets.all(widget.gradientBorder ? 1.5 : 1),
      decoration: BoxDecoration(
        gradient: edgeGradient,
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: widget.gradientBorder ? AppShadows.accentGlow(c) : shadows,
      ),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(widget.radius - 1),
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return body;
    return Pressable(
      onTap: () {
        AppHaptics.tick();
        widget.onTap!();
      },
      onPressedChanged: (v) => setState(() => _down = v),
      child: body,
    );
  }
}

/// Scale-on-press wrapper with a selection haptic; kept for callers outside NeuCard.
Widget pressable({required VoidCallback onTap, required Widget child}) =>
    Pressable(
      onTap: () {
        AppHaptics.tick();
        onTap();
      },
      child: child,
    );
