// Visual smoke check for the design refresh: renders key new components in dark and
// light themes to goldens (test/goldens/). Regenerate: flutter test --update-goldens.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jugaadi/core/theme/app_theme.dart';
import 'package:jugaadi/core/theme/tokens.dart';
import 'package:jugaadi/core/widgets/widgets.dart';

Widget _sample() => Builder(builder: (context) {
      final c = context.colors;
      return Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            Text('Nearby tasks', style: AppText.headline.copyWith(color: c.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            NeuCard(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unload tempo truck', style: AppText.title.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Loading & unloading', style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                  const SizedBox(height: 4),
                  Text('₹700/day  ·  2.3 km away', style: AppText.bodySmall.copyWith(color: c.accent, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            NeuCard(
              gradientBorder: true,
              child: Text('Pro — ₹199/month', style: AppText.title.copyWith(color: c.textPrimary)),
            ),
            const SizedBox(height: AppSpacing.md),
            NeuButton(label: 'Post a task', onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            SlideToConfirm(label: 'Slide to apply', onConfirmed: () {}),
            const SizedBox(height: AppSpacing.md),
            StatusStepper(steps: const ['Applied', 'Hired', 'Done'], current: 1),
            const SizedBox(height: AppSpacing.md),
            const Row(children: [ShimmerBox(width: 180), SizedBox(width: 8), ShimmerBox(width: 60)]),
          ],
        ),
        bottomNavigationBar: GlassNavBar(
          selectedIndex: 0,
          onSelected: (_) {},
          items: const [
            GlassNavItem(icon: Icons.search_rounded, activeIcon: Icons.search_rounded, label: 'Nearby'),
            GlassNavItem(icon: Icons.work_outline_rounded, activeIcon: Icons.work_rounded, label: 'My jobs', showDot: true),
          ],
        ),
      );
    });

void main() {
  for (final (name, theme) in [('dark', AppTheme.dark), ('light', AppTheme.light)]) {
    testWidgets('design system renders in $name theme', (tester) async {
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 2.5;
      await tester.pumpWidget(MaterialApp(theme: theme, home: _sample()));
      await tester.pump(const Duration(milliseconds: 600));
      await expectLater(find.byType(Scaffold).first, matchesGoldenFile('goldens/design_$name.png'));
    });
  }
}
