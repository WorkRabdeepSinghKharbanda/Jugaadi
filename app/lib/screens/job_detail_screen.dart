import 'package:flutter/material.dart';
import '../api_client.dart';
import '../config.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/widgets.dart';
import 'plans_screen.dart';

/// Shared by owner and worker — the API response already includes hired_workers (owner view,
/// one per accepted applicant on this job) / owner (worker view, once this worker is accepted),
/// so there's no separate "reveal contact" endpoint to call.
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
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _reviewSubmitting = false;
  bool _reviewDone = false;
  String? _reviewTargetWorkerId;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    job = widget.job;
    _refreshDetail();
  }

  // The map passed in on navigation is whatever partial row the caller had (nearby list, my
  // applications, my jobs) — only a real GET /jobs/:id carries hired_workers/owner contact
  // reveal and my_application_status, so fetch it once the screen opens instead of relying on
  // stale/partial data for the whole screen lifetime.
  Future<void> _refreshDetail() async {
    try {
      final fresh = await ApiClient(Config.apiBaseUrl).get('/jobs/${job['id']}') as Map<String, dynamic>;
      if (mounted) setState(() => job = {...job, ...fresh});
    } catch (_) {
      // keep showing the partial data passed in — not worth surfacing an error for this
    }
  }

  Future<void> _complete() async {
    setState(() => _loading = true);
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${job['id']}/complete');
      if (!mounted) return;
      showAppToast(context, 'Job marked complete');
      setState(() => job = {...job, 'status': 'done'});
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      showAppToast(context, 'Pick a star rating first', tone: ToastTone.error);
      return;
    }
    if (widget.isOwner && _reviewTargetWorkerId == null) {
      showAppToast(context, 'Pick which worker to rate', tone: ToastTone.error);
      return;
    }
    setState(() => _reviewSubmitting = true);
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${job['id']}/review', {
        'rating': _rating,
        if (_commentController.text.trim().isNotEmpty) 'comment': _commentController.text.trim(),
        if (widget.isOwner) 'worker_id': _reviewTargetWorkerId,
      });
      if (!mounted) return;
      showAppToast(context, 'Review submitted');
      setState(() => _reviewDone = true);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        if (mounted) setState(() => _reviewDone = true);
      } else if (mounted) {
        showAppToast(context, '$e', tone: ToastTone.error);
      }
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    } finally {
      if (mounted) setState(() => _reviewSubmitting = false);
    }
  }

  Future<void> _apply() async {
    setState(() => _loading = true);
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${job['id']}/apply');
      if (!mounted) return;
      showAppToast(context, 'Applied successfully');
      setState(() => job = {...job, 'my_application_status': 'pending'});
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'plan_limit') {
        showAppToast(context, e.message, tone: ToastTone.error);
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlansScreen(role: 'worker')));
      } else if (e.code == 'already_applied') {
        setState(() => job = {...job, 'my_application_status': 'pending'});
      } else {
        showAppToast(context, e.message, tone: ToastTone.error);
      }
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
    final photoUrls = (job['photo_urls'] as List<dynamic>?)?.cast<String>() ?? const [];
    final hiredWorkers = (job['hired_workers'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? const [];
    final ownerContact = job['owner'] as Map<String, dynamic>?;
    final isHiredAsWorker = !widget.isOwner && ownerContact != null;
    final myApplicationStatus = job['my_application_status'] as String?;
    _reviewTargetWorkerId ??= hiredWorkers.isNotEmpty ? hiredWorkers.first['worker_id'] as String? : null;

    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      scroll: true,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(job['title'] as String? ?? '', style: AppText.headline)),
                PillBadge.status(status),
              ],
            ),
            if (photoUrls.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photoUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: AppRadius.mdAll,
                    child: Image.network(photoUrls[i], width: 140, height: 140, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
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
            if (widget.isOwner && hiredWorkers.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(hiredWorkers.length > 1 ? 'Hired workers' : 'Hired worker'),
              for (final w in hiredWorkers) ...[
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
                            Text(w['full_name'] as String? ?? '-', style: AppText.title),
                            const SizedBox(height: 4),
                            Text(w['phone'] as String? ?? '-', style: AppText.body.copyWith(color: c.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
            if (isHiredAsWorker) ...[
              const SizedBox(height: AppSpacing.lg),
              SectionHeader('Owner contact'),
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
                          Text(ownerContact['full_name'] as String? ?? '-', style: AppText.title),
                          const SizedBox(height: 4),
                          Text(ownerContact['phone'] as String? ?? '-', style: AppText.body.copyWith(color: c.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (status == 'done' && (widget.isOwner ? hiredWorkers.isNotEmpty : isHiredAsWorker) && !_reviewDone) ...[
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(widget.isOwner ? 'Rate a worker' : 'Rate the owner'),
              NeuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isOwner && hiredWorkers.length > 1) ...[
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _reviewTargetWorkerId,
                        dropdownColor: c.surfaceHigh,
                        items: hiredWorkers
                            .map((w) => DropdownMenuItem(value: w['worker_id'] as String, child: Text(w['full_name'] as String? ?? '-')))
                            .toList(),
                        onChanged: (v) => setState(() => _reviewTargetWorkerId = v),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (i) => IconButton(
                          icon: Icon(i < _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: c.accent, size: 32),
                          onPressed: () => setState(() => _rating = i + 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    NeuTextField(label: 'Comment (optional)', controller: _commentController, icon: Icons.chat_bubble_outline_rounded),
                    const SizedBox(height: AppSpacing.md),
                    NeuButton(label: 'Submit review', loading: _reviewSubmitting, onPressed: _submitReview),
                  ],
                ),
              ),
            ],
            if (status == 'done' && _reviewDone) ...[
              const SizedBox(height: AppSpacing.lg),
              ErrorStrip('You\'ve already reviewed this job', warning: true),
            ],
            const SizedBox(height: AppSpacing.xl),
            if (!widget.isOwner && status == 'open')
              NeuButton(
                label: myApplicationStatus == 'rejected'
                    ? 'Not selected'
                    : myApplicationStatus != null
                        ? 'Applied'
                        : 'Apply',
                icon: myApplicationStatus != null ? Icons.check_rounded : Icons.send_rounded,
                loading: _loading,
                onPressed: myApplicationStatus != null ? null : _apply,
              ),
            if (widget.isOwner && status == 'hired') NeuButton(label: 'Mark complete', icon: Icons.check_circle_outline_rounded, loading: _loading, onPressed: _complete),
          ],
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
