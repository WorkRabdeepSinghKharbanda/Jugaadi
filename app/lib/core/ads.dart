import 'package:flutter/widgets.dart';

// Ads are switched OFF. Real implementation: .claude/docs/ads/ads.dart.disabled.
// To enable, follow "Enabling Free-plan ads" in .claude/docs/RUNNING.md.
Future<bool> shouldShowAds() async => false;

class NativeAdCard extends StatelessWidget {
  const NativeAdCard({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
