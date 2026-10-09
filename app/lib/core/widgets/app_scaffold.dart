import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'neu_button.dart';

/// Safe-area scaffold with the standard gutter and an optional large title row
/// (back button + headline + actions). `fullBleed` drops the gutter.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.subtitle,
    this.onBack,
    this.actions = const [],
    this.fullBleed = false,
    this.scroll = false,
    this.bottom,
    this.resizeForKeyboard = false,
  });

  final Widget body;
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool fullBleed;
  final bool scroll;
  final Widget? bottom;
  final bool resizeForKeyboard;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final header = title == null && onBack == null && actions.isEmpty
        ? null
        : Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onBack != null || actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Row(
                      children: [
                        if (onBack != null) NeuIconButton(icon: Icons.arrow_back_rounded, semanticLabel: 'Back', onPressed: onBack),
                        const Spacer(),
                        for (final a in actions) Padding(padding: const EdgeInsets.only(left: AppSpacing.sm), child: a),
                      ],
                    ),
                  ),
                if (title != null) Text(title!, style: AppText.headline.copyWith(color: c.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(subtitle!, style: AppText.body.copyWith(color: c.textSecondary)),
                ],
              ],
            ),
          );

    Widget content = fullBleed ? body : Padding(padding: AppSpacing.screen, child: body);
    if (scroll) content = SingleChildScrollView(child: content);

    return Scaffold(
      backgroundColor: c.bg,
      resizeToAvoidBottomInset: resizeForKeyboard,
      body: SafeArea(
        bottom: bottom == null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) header,
            Expanded(child: content),
            if (bottom != null)
              SafeArea(
                top: false,
                child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md), child: bottom),
              ),
          ],
        ),
      ),
    );
  }
}
