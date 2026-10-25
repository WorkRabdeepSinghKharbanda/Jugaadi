import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// Haptic vocabulary: a tick on selection, a firmer pulse on a committed action.
class AppHaptics {
  AppHaptics._();
  static void tick() => unawaited(HapticFeedback.selectionClick());
  static void success() => unawaited(HapticFeedback.mediumImpact());
}

/// Entrance: fade + 16 px upward slide. Pass `index` for the 40 ms stagger. Instant under reduced motion.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _ctrl,
    curve: AppDurations.curve,
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final delay = AppDurations.stagger(widget.index);
    if (MediaQuery.disableAnimationsOf(context)) {
      _ctrl.value = 1;
    } else if (delay == Duration.zero) {
      _ctrl.forward();
    } else {
      _timer = Timer(delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (_, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - _t.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Tap feedback: scale 0.97 while pressed. [onTap] null = inert (no feedback, no semantics button).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.onPressedChanged,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// Lets the child compress its shadow while pressed.
  final ValueChanged<bool>? onPressedChanged;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
    widget.onPressedChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: AppDurations.of(context, AppDurations.fast),
          curve: AppDurations.curve,
          child: widget.child,
        ),
      ),
    );
  }
}
