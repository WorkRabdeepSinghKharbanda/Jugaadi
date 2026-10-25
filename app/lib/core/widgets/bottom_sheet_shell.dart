import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Shows [builder] inside a [BottomSheetShell]-styled modal sheet. Secondary actions live in sheets, not dialogs.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: builder,
  );
}

/// 32 px top radius, drag handle, optional title. Content scrolls if taller than the viewport.
class BottomSheetShell extends StatelessWidget {
  const BottomSheetShell({super.key, required this.child, this.title});
  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadius.sheetTop,
        border: Border(top: BorderSide(color: c.edge)),
        boxShadow: AppShadows.floating(c),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.md + insets,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: c.outline,
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
              ),
              if (title != null) ...[
                Semantics(
                  header: true,
                  child: Text(
                    title!,
                    style: AppText.title.copyWith(color: c.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
