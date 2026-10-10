import 'package:flutter/material.dart';
import '../job_status.dart';
import '../theme/tokens.dart';

enum PillTone { accent, live, neutral, danger }

/// Small uppercase status pill (job status, verification, applicant state).
class PillBadge extends StatelessWidget {
  const PillBadge({super.key, required this.label, this.tone = PillTone.neutral, this.icon});

  const PillBadge.verified({super.key})
      : label = 'Verified',
        tone = PillTone.live,
        icon = Icons.verified_rounded;

  /// Maps a jobs/job_applications `status` column value to a styled pill. Accepts either a
  /// [JobStatus] or [ApplicationStatus] name — they're the only two status concepts this is
  /// ever called with.
  factory PillBadge.status(String status) {
    final tone = switch (JobStatus.fromString(status)) {
      JobStatus.open => PillTone.accent,
      JobStatus.hired => PillTone.live,
      JobStatus.removed => PillTone.danger,
      JobStatus.done => PillTone.neutral,
      null => switch (ApplicationStatus.fromString(status)) {
          ApplicationStatus.accepted => PillTone.live,
          ApplicationStatus.rejected => PillTone.danger,
          ApplicationStatus.pending || null => PillTone.neutral,
        },
    };
    return PillBadge(label: status, tone: tone);
  }

  final String label;
  final PillTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      PillTone.accent => (c.accent, c.onAccent),
      PillTone.live => (c.live.withValues(alpha: 0.16), c.live),
      PillTone.danger => (c.dangerSoft, c.danger),
      PillTone.neutral => (c.surfaceHigh, c.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs + 1),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pillAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 3)],
          Text(label.toUpperCase(), style: AppText.label.copyWith(color: fg)),
        ],
      ),
    );
  }
}
