import 'package:flutter/material.dart';
import '../api_client.dart';
import '../config.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/widgets.dart';

/// Shared by owner and worker — the API response already includes
/// hired_worker/owner contact info once status is 'hired', so there's
/// no separate "reveal contact" endpoint to call.
class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.job, required this.isOwner});

  final Map<String, dynamic> job;
  final bool isOwner;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Map<String, dynamic> job;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    job = widget.job;
  }

  Future<void> _complete() async {
    setState(() => _loading = true);
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${job['id']}/complete');
      if (!mounted) return;
      showAppToast(context, 'Job marked complete');
      setState(() => job = {...job, 'status': 'completed'});
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply() async {
    setState(() => _loading = true);
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${job['id']}/apply');
      if (!mounted) return;
      showAppToast(context, 'Applied successfully');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final status = job['status'] as String;
    final contact = widget.isOwner ? job['hired_worker'] as Map<String, dynamic>? : job['owner'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(title: Text(job['title'] as String? ?? '')),
      body: SingleChildScrollView(
        padding: AppSpacing.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: Text(job['title'] as String? ?? '', style: AppText.headline)),
                PillBadge.status(status),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            NeuCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(icon: Icons.build_outlined, label: 'Skill', value: job['skill_needed'] as String? ?? '-'),
                  const SizedBox(height: AppSpacing.md),
                  _DetailRow(icon: Icons.date_range_rounded, label: 'Dates', value: '${job['start_date']} → ${job['end_date']}'),
                  if (job['daily_wage'] != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _DetailRow(icon: Icons.payments_outlined, label: 'Wage', value: '${job['daily_wage']}/day'),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: job['address_text'] as String? ?? '-'),
                ],
              ),
            ),
            if (contact != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(widget.isOwner ? 'Hired worker' : 'Owner contact'),
              NeuCard(
                gradientBorder: true,
                child: Row(
                  children: [
                    Icon(Icons.phone_rounded, color: c.accent),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact['full_name'] as String? ?? '-', style: AppText.title),
                          const SizedBox(height: 4),
                          Text(contact['phone'] as String? ?? '-', style: AppText.body.copyWith(color: c.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            if (!widget.isOwner && status == 'open') NeuButton(label: 'Apply', icon: Icons.send_rounded, loading: _loading, onPressed: _apply),
            if (widget.isOwner && status == 'hired') NeuButton(label: 'Mark complete', icon: Icons.check_circle_outline_rounded, loading: _loading, onPressed: _complete),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: c.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: AppText.label.copyWith(color: c.textTertiary)),
              const SizedBox(height: 2),
              Text(value, style: AppText.body),
            ],
          ),
        ),
      ],
    );
  }
}
