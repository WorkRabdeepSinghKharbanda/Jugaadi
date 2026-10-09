import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum ToastTone { success, error, info }

/// Top-right, auto-dismissing toast (2s) — not Material's bottom SnackBar.
/// Colors come from the app's own palette (live/danger/accent), not generic red/green.
void showAppToast(BuildContext context, String message, {ToastTone tone = ToastTone.success}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => _Toast(message: message, tone: tone, onDone: () => entry.remove()));
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({required this.message, required this.tone, required this.onDone});
  final String message;
  final ToastTone tone;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: AppDurations.base);
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, -0.3), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: AppDurations.curve));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    _timer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      await _ctrl.reverse();
      widget.onDone();
    });
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
    final (bg, fg, icon) = switch (widget.tone) {
      ToastTone.success => (c.live.withValues(alpha: 0.16), c.live, Icons.check_circle_rounded),
      ToastTone.error => (c.dangerSoft, c.danger, Icons.error_rounded),
      ToastTone.info => (c.surfaceHigh, c.accent, Icons.info_rounded),
    };
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.sm,
      right: AppSpacing.gutter,
      left: AppSpacing.gutter,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _ctrl,
          child: SlideTransition(
            position: _slide,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: bg == c.surfaceHigh ? c.outline : fg.withValues(alpha: 0.4)),
                  boxShadow: AppShadows.floating(c),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(child: Text(widget.message, style: AppText.bodySmall.copyWith(color: c.textPrimary))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
