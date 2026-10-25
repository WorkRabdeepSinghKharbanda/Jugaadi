import 'package:flutter/material.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import 'profile_setup_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.tr('role_select_title'),
      subtitle: context.tr('role_select_subtitle'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeuCard(
            gradientBorder: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileSetupScreen(role: 'owner'),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.storefront_rounded,
                  color: context.colors.accent,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('i_need_workers'), style: AppText.title),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('post_job_hire_nearby'),
                        style: AppText.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          NeuCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileSetupScreen(role: 'worker'),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.badge_outlined,
                  color: context.colors.textPrimary,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('i_want_work'), style: AppText.title),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('find_jobs_apply_fast'),
                        style: AppText.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
