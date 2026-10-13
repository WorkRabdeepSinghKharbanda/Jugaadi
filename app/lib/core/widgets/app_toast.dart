import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum ToastTone { success, error, info, warning }

OverlayEntry? _currentToastEntry;

/// Top-of-screen, auto-dismissing toast — not Material's bottom SnackBar.
/// Colors come from the app's own palette tokens, never a literal Color/Colors.*.
/// A new toast replaces whatever's currently showing.
void showAppToast(
  BuildContext context,
  String message, {
  ToastTone tone = ToastTone.success,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  _currentToastEntry?.remove();
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      message: message,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
      onDone: () {
        if (_currentToastEntry == entry) _currentToastEntry = null;
        entry.remove();
      },
    ),
  );
  _currentToastEntry = entry;
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.tone,
    required this.onDone,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final ToastTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: AppDurations.curve,
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: AppDurations.curve));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    final duration = widget.actionLabel != null
        ? const Duration(seconds: 5)
        : const Duration(seconds: 3);
    _timer = Timer(duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    _timer?.cancel();
    await _ctrl.animateTo(
      0,
      duration: AppDurations.of(context, AppDurations.fast),
    );
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fill, iconColor, icon, shadow) = switch (widget.tone) {
      ToastTone.success => (
        c.surface,
        c.accent,
        Icons.check_circle_rounded,
        AppShadows.accentGlow(c),
      ),
      ToastTone.info => (
        c.surface,
        c.textSecondary,
        Icons.info_outline_rounded,
        AppShadows.floating(c),
      ),
      ToastTone.error => (
        c.dangerSoft,
        c.danger,
        Icons.error_outline_rounded,
        AppShadows.floating(c),
      ),
      ToastTone.warning => (
        c.surface,
        c.warning,
        Icons.warning_amber_rounded,
        AppShadows.floating(c),
      ),
    };
    final border = switch (widget.tone) {
      ToastTone.success => Border.fromBorderSide(
        BorderSide.none,
      ), // gradient border drawn separately below
      ToastTone.info => Border.all(color: c.outline, width: 1),
      ToastTone.error => Border.all(color: c.danger, width: 1.5),
      ToastTone.warning => Border.all(color: c.warning, width: 1.5),
    };

    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.sm,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding: widget.tone == ToastTone.success
                  ? const EdgeInsets.all(1.5)
                  : null,
              decoration: widget.tone == ToastTone.success
                  ? BoxDecoration(
                      gradient: c.accentGradient,
                      borderRadius: AppRadius.mdAll,
                      boxShadow: shadow,
                    )
                  : BoxDecoration(
                      color: fill,
                      borderRadius: AppRadius.mdAll,
                      border: border,
                      boxShadow: shadow,
                    ),
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: AppSpacing.card,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 20, color: iconColor),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: AppText.body.copyWith(
                            color: c.textPrimary,
                            fontSize: 17,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.actionLabel != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () {
                            widget.onAction?.call();
                            _dismiss();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Text(
                              widget.actionLabel!.toUpperCase(),
                              style: AppText.label.copyWith(color: c.accent),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
