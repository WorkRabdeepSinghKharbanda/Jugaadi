import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'motion.dart';

/// Signature commit control (send request, approve, pay). Drag the thumb past [threshold] of the track to confirm:
/// tick haptic at half-way, success haptic on confirm. Screen readers get a plain button that confirms on
/// activate. While [loading] the thumb stays at the end with a spinner; when loading ends without the parent
/// leaving the screen (error) the thumb springs back so the user can retry.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.enabled = true,
    this.loading = false,
    this.threshold = 0.9,
  });

  final String label;
  final VoidCallback onConfirmed;
  final bool enabled;
  final bool loading;
  final double threshold;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  static const double _thumb = 56;
  static const double _pad = 4;
  double _dx = 0;
  bool _dragging = false;
  bool _done = false;
  bool _pastHalf = false;

  @override
  void didUpdateWidget(SlideToConfirm old) {
    super.didUpdateWidget(old);
    if (old.loading && !widget.loading && _done) {
      setState(() {
        _done = false;
        _dx = 0;
      });
    }
  }

  void _confirm(double max) {
    if (_done) return;
    setState(() {
      _done = true;
      _dx = max;
      _dragging = false;
    });
    AppHaptics.success();
    widget.onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final active = widget.enabled && !_done && !widget.loading;
    return LayoutBuilder(
      builder: (context, box) {
        final max = (box.maxWidth - _thumb - 2 * _pad).clamp(
          1.0,
          double.infinity,
        );
        final progress = (_dx / max).clamp(0.0, 1.0);
        return Semantics(
          button: true,
          enabled: active,
          label: widget.label,
          onTap: active ? () => _confirm(max) : null,
          excludeSemantics: true,
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.4,
            child: Container(
              height: _thumb + 2 * _pad,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: AppRadius.pillAll,
                border: Border.all(
                  color: Color.lerp(c.outline, c.accent, progress)!,
                ),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Filled trail behind the thumb.
                  AnimatedContainer(
                    duration: _dragging
                        ? Duration.zero
                        : AppDurations.of(context),
                    curve: AppDurations.curve,
                    width: _dx + _thumb + _pad * 2,
                    decoration: BoxDecoration(
                      color: c.accentSoft,
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _thumb + _pad * 2,
                      ),
                      child: Opacity(
                        opacity: 1 - progress * 0.8,
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.button.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: _dragging
                        ? Duration.zero
                        : AppDurations.of(context),
                    curve: AppDurations.curve,
                    left: _pad + _dx,
                    child: GestureDetector(
                      key: const ValueKey('slide-thumb'),
                      onHorizontalDragStart: active
                          ? (_) => setState(() => _dragging = true)
                          : null,
                      onHorizontalDragUpdate: active
                          ? (d) {
                              setState(
                                () => _dx = (_dx + d.delta.dx).clamp(0.0, max),
                              );
                              final half = _dx / max >= 0.5;
                              if (half != _pastHalf) {
                                _pastHalf = half;
                                AppHaptics.tick();
                              }
                            }
                          : null,
                      onHorizontalDragEnd: active
                          ? (_) {
                              if (_dx / max >= widget.threshold) {
                                _confirm(max);
                              } else {
                                setState(() {
                                  _dragging = false;
                                  _dx = 0;
                                  _pastHalf = false;
                                });
                              }
                            }
                          : null,
                      child: Container(
                        width: _thumb,
                        height: _thumb,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: c.accentGradient,
                          boxShadow: AppShadows.accentGlow(c),
                        ),
                        child: widget.loading
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: c.onAccent,
                                ),
                              )
                            : Icon(
                                _done
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                color: c.onAccent,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
