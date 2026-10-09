import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'neu_card.dart';

enum NeuButtonVariant { primary, ghost, danger }

/// Primary (amber gradient), ghost (outlined charcoal) or danger button.
/// `loading` shows a spinner and blocks taps; `onPressed == null` disables.
class NeuButton extends StatelessWidget {
  const NeuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NeuButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.height = 56,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final NeuButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final double height;
  final bool expand;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isPrimary = variant == NeuButtonVariant.primary;
    final fg = switch (variant) {
      NeuButtonVariant.primary => c.onAccent,
      NeuButtonVariant.ghost => c.textPrimary,
      NeuButtonVariant.danger => c.danger,
    };
    final decoration = BoxDecoration(
      gradient: isPrimary ? c.accentGradient : null,
      color: isPrimary ? null : (variant == NeuButtonVariant.danger ? c.dangerSoft : c.surface),
      borderRadius: AppRadius.mdAll,
      border: isPrimary ? null : Border.all(color: variant == NeuButtonVariant.danger ? c.danger.withValues(alpha: 0.4) : c.outline),
      boxShadow: !_enabled ? AppShadows.none : (isPrimary ? AppShadows.accentGlow(c) : AppShadows.raised(c)),
    );

    final content = loading
        ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: fg))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, color: fg, size: 22), const SizedBox(width: AppSpacing.sm)],
              Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.button.copyWith(color: fg))),
            ],
          );

    Widget body = AnimatedOpacity(
      duration: AppDurations.of(context),
      opacity: _enabled ? 1 : 0.55,
      child: AnimatedContainer(
        duration: AppDurations.of(context),
        curve: AppDurations.curve,
        height: height,
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: decoration,
        alignment: Alignment.center,
        child: content,
      ),
    );
    body = Semantics(button: true, enabled: _enabled, child: body);
    return _enabled ? pressable(onTap: onPressed!, child: body) : body;
  }
}

/// 48dp round icon-only button.
class NeuIconButton extends StatelessWidget {
  const NeuIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.loading = false,
    this.color,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? color;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final body = Semantics(
      button: true,
      enabled: _enabled,
      label: semanticLabel,
      child: Tooltip(
        message: semanticLabel,
        excludeFromSemantics: true,
        child: AnimatedContainer(
          duration: AppDurations.of(context),
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle, border: Border.all(color: c.outline), boxShadow: _enabled ? AppShadows.raised(c) : AppShadows.none),
          child: loading
              ? Padding(padding: const EdgeInsets.all(AppSpacing.md - 2), child: CircularProgressIndicator(strokeWidth: 2.5, color: c.accent))
              : Icon(icon, color: _enabled ? (color ?? c.textPrimary) : c.textTertiary, size: 22),
        ),
      ),
    );
    return _enabled ? pressable(onTap: onPressed!, child: body) : body;
  }
}
