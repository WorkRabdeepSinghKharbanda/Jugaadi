import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Small accent dot for "something new". Decorative: the owner widget carries the semantics label.
class UnreadDot extends StatelessWidget {
  const UnreadDot({super.key});
  static const double size = 10;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: Container(
        key: const ValueKey('unread-dot'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.accent,
          border: Border.all(color: c.surfaceHigh, width: 1.5),
        ),
      ),
    );
  }
}
