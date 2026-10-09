import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'profile_setup_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'What brings you here?',
      subtitle: 'Pick the side you\'re on — you can\'t switch later.',
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeuCard(
            gradientBorder: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileSetupScreen(role: 'owner')),
            ),
            child: Row(
              children: [
                Icon(Icons.storefront_rounded, color: context.colors.accent, size: 32),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('I need workers', style: AppText.title),
                      const SizedBox(height: 4),
                      Text('Post a job, hire nearby', style: AppText.bodySmall.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          NeuCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileSetupScreen(role: 'worker')),
            ),
            child: Row(
              children: [
                Icon(Icons.badge_outlined, color: context.colors.textPrimary, size: 32),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('I want work', style: AppText.title),
                      const SizedBox(height: 4),
                      Text('Find jobs nearby, apply fast', style: AppText.bodySmall.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.textTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
