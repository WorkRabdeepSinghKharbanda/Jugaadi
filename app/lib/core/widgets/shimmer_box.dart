import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Skeleton block. Sweeps a highlight across; static under reduced motion. Wrapped in a RepaintBoundary so the
/// animation does not repaint its neighbours.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadius.sm,
  });
  final double? width;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppDurations.shimmer,
  );
  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce && _animating) {
      _ctrl.stop();
      _animating = false;
    } else if (!reduce && !_animating) {
      _ctrl.repeat();
      _animating = true;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      excludeSemantics: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final x = -1.0 + 3 * _ctrl.value;
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                gradient: LinearGradient(
                  begin: Alignment(x - 1, 0),
                  end: Alignment(x, 0),
                  colors: [c.surfaceHigh, c.surfaceTop, c.surfaceHigh],
                  stops: const [0.2, 0.5, 0.8],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
