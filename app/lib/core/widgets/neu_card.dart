import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum NeuVariant { raised, pressed, flat }

/// Charcoal neumorphic card. `gradientBorder` paints an accent gradient edge
/// (CRED reward-card look). `onTap` makes it a tappable surface with press feedback.
class NeuCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final c = context.colors;
    final fill = color ??
        switch (variant) {
          NeuVariant.raised => c.surface,
          NeuVariant.pressed => c.surfaceLow,
          NeuVariant.flat => c.surface,
        };
    final shadows = variant == NeuVariant.raised ? AppShadows.raised(c) : AppShadows.none;
    final border = variant == NeuVariant.pressed ? Border.all(color: c.outline) : null;

    Widget body = AnimatedContainer(
      duration: AppDurations.of(context),
      curve: AppDurations.curve,
      padding: padding,
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(radius), boxShadow: shadows, border: border),
      child: child,
    );

    if (gradientBorder) {
      body = Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(gradient: c.accentGradient, borderRadius: BorderRadius.circular(radius + 1.5), boxShadow: AppShadows.accentGlow(c)),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(radius)),
          child: child,
        ),
      );
    }

    if (onTap == null) return body;
    return _Pressable(onTap: onTap!, child: body);
  }
}

class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: AppDurations.of(context, AppDurations.fast),
        curve: AppDurations.curve,
        child: widget.child,
      ),
    );
  }
}

Widget pressable({required VoidCallback onTap, required Widget child}) => _Pressable(onTap: onTap, child: child);
