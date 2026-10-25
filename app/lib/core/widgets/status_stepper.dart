import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Request progress: sent, approved, call, done. [current] is the index of the active step; earlier steps are
/// complete. [failed] paints the active step as danger (declined / expired).
class StatusStepper extends StatelessWidget {
  const StatusStepper({
    super.key,
    required this.steps,
    required this.current,
    this.failed = false,
  });
  final List<String> steps;
  final int current;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label:
          '${steps[current.clamp(0, steps.length - 1)]}, ${current + 1}/${steps.length}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: i == 0
                            ? const SizedBox.shrink()
                            : _Line(
                                done: i <= current,
                                color: failed && i == current
                                    ? c.danger
                                    : c.accent,
                              ),
                      ),
                      _Node(
                        done: i < current,
                        active: i == current,
                        failed: failed && i == current,
                      ),
                      Expanded(
                        child: i == steps.length - 1
                            ? const SizedBox.shrink()
                            : _Line(done: i < current, color: c.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    steps[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall.copyWith(
                      fontSize: 12,
                      color: i <= current
                          ? (failed && i == current ? c.danger : c.textPrimary)
                          : c.textTertiary,
                      fontWeight: i == current
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.done, required this.color});
  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(height: 2, color: done ? color : c.outline);
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.done, required this.active, required this.failed});
  final bool done;
  final bool active;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = failed ? c.danger : c.accent;
    return AnimatedContainer(
      duration: AppDurations.of(context),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? color
            : (active ? color.withValues(alpha: 0.18) : c.surfaceHigh),
        border: Border.all(
          color: done || active ? color : c.outline,
          width: active ? 2 : 1,
        ),
      ),
      child: done
          ? Icon(Icons.check_rounded, size: 14, color: c.onAccent)
          : (failed ? Icon(Icons.close_rounded, size: 14, color: color) : null),
    );
  }
}
