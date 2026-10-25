import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'motion.dart';
import 'unread_dot.dart';

class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showDot = false,
    this.semanticsLabel,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// Unread dot on the icon; [semanticsLabel] then carries the words for screen readers.
  final bool showDot;
  final String? semanticsLabel;
}

/// Floating pill bottom bar over blurred content. Place it in a Stack above the page (or Scaffold.extendBody);
/// pages add [GlassNavBar.height] bottom padding so content scrolls beneath it.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });
  final List<GlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Bar height plus its bottom margin, for content padding.
  static const double height = 72 + 2 * AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.md,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillAll,
            boxShadow: AppShadows.floating(c),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: c.surfaceHigh.withValues(alpha: 0.78),
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(color: c.edge),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavButton(
                          item: items[i],
                          selected: i == selectedIndex,
                          onTap: () {
                            if (i != selectedIndex) AppHaptics.tick();
                            onSelected(i);
                          },
                        ),
                      ),
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: item.semanticsLabel ?? item.label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.of(context),
          curve: AppDurations.curve,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? c.accentSoft : Colors.transparent,
            borderRadius: AppRadius.pillAll,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    selected ? item.activeIcon : item.icon,
                    size: 24,
                    color: selected ? c.accent : c.textSecondary,
                  ),
                  if (item.showDot)
                    const Positioned(top: -2, right: -3, child: UnreadDot()),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodySmall.copyWith(
                  fontSize: 11,
                  color: selected ? c.accent : c.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
