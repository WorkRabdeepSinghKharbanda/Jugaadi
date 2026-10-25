import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import '../api_client.dart';
import '../config.dart';
import '../core/i18n/lang.dart';
import '../core/safety.dart';
import '../core/i18n/strings.dart';
import '../core/job_status.dart';
import '../core/share_job.dart';
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
  bool _editingReview = false;
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
      final fresh =
          await ApiClient(Config.apiBaseUrl).get('/jobs/${job['id']}')
              as Map<String, dynamic>;
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
      showAppToast(context, context.tr('job_marked_complete'));
      setState(() => job = {...job, 'status': JobStatus.done.name});
    } catch (e) {
      if (mounted) {
        showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic>? get _myReview =>
      job['my_review'] as Map<String, dynamic>?;

  void _startEditReview() {
    final r = _myReview!;
    setState(() {
      _rating = r['rating'] as int;
      _commentController.text = (r['comment'] as String?) ?? '';
      _editingReview = true;
    });
  }

  Future<void> _submitReview() async {
    final isEdit = _myReview != null;
    if (_rating == 0) {
      showAppToast(
        context,
        context.tr('pick_star_rating'),
        tone: ToastTone.error,
      );
      return;
    }
    if (!isEdit && widget.isOwner && _reviewTargetWorkerId == null) {
      showAppToast(
        context,
        context.tr('pick_worker_to_rate'),
        tone: ToastTone.error,
      );
      return;
    }
    final comment = _commentController.text.trim();
    setState(() => _reviewSubmitting = true);
    try {
      final api = ApiClient(Config.apiBaseUrl);
      final path = '/jobs/${job['id']}/review';
      if (isEdit) {
        await api.patch(path, {
          'rating': _rating,
          'comment': comment.isEmpty ? null : comment,
        });
      } else {
        await api.post(path, {
          'rating': _rating,
          if (comment.isNotEmpty) 'comment': comment,
          if (widget.isOwner) 'worker_id': _reviewTargetWorkerId,
        });
      }
      if (!mounted) return;
      showAppToast(
        context,
        context.tr(isEdit ? 'review_updated' : 'review_submitted'),
      );
      setState(() {
        job = {
          ...job,
          'my_review': {
            ..._myReview ?? {},
            'rating': _rating,
            'comment': comment.isEmpty ? null : comment,
          },
        };
        _editingReview = false;
      });
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        await _refreshDetail();
      } else if (mounted) {
        showAppToast(context, e.message, tone: ToastTone.error);
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _reviewSubmitting = false);
    }
  }

  Future<void> _apply() async {
    setState(() => _loading = true);
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${job['id']}/apply');
      if (!mounted) return;
      showAppToast(context, context.tr('applied_successfully'));
      setState(
        () => job = {
          ...job,
          'my_application_status': ApplicationStatus.pending.name,
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'plan_limit') {
        showAppToast(context, e.message, tone: ToastTone.error);
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlansScreen(role: 'worker')),
        );
      } else if (e.code == 'already_applied') {
        setState(
          () => job = {
            ...job,
            'my_application_status': ApplicationStatus.pending.name,
          },
        );
      } else {
        showAppToast(context, e.message, tone: ToastTone.error);
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _sharing = false;

  Future<void> _share() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.image_outlined, color: ctx.colors.accent),
              title: Text(ctx.tr('share_image_option')),
              onTap: () => Navigator.of(ctx).pop('share'),
            ),
            ListTile(
              leading: Icon(Icons.copy_rounded, color: ctx.colors.accent),
              title: Text(ctx.tr('copy_text_option')),
              onTap: () => Navigator.of(ctx).pop('copy'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'copy') {
      await Clipboard.setData(
        ClipboardData(text: jobShareText(job, context.lang)),
      );
      if (mounted) showAppToast(context, context.tr('copied_to_clipboard'));
      return;
    }
    setState(() => _sharing = true);
    try {
      await shareJob(job, context.lang);
    } catch (e) {
      if (mounted) {
        showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final status = job['status'] as String;
    final photoUrls =
        (job['photo_urls'] as List<dynamic>?)?.cast<String>() ?? const [];
    final hiredWorkers =
        (job['hired_workers'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        const [];
    final ownerContact = job['owner'] as Map<String, dynamic>?;
    final isHiredAsWorker = !widget.isOwner && ownerContact != null;
    final myApplicationStatus = job['my_application_status'] as String?;
    _reviewTargetWorkerId ??= hiredWorkers.isNotEmpty
        ? hiredWorkers.first['worker_id'] as String?
        : null;

    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      scroll: true,
      actions: [
        if (!widget.isOwner && job['owner_id'] != null)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: c.textSecondary),
            onSelected: (action) async {
              final navigator = Navigator.of(context);
              if (action == 'report') {
                await showReportSheet(
                  context,
                  targetType: 'job',
                  targetId: job['id'],
                );
              } else if (await confirmAndBlock(
                context,
                userId: job['owner_id'] as String,
              )) {
                navigator.pop();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'report',
                child: Text(context.tr('report_job')),
              ),
              PopupMenuItem(
                value: 'block',
                child: Text(context.tr('block_user')),
              ),
            ],
          ),
        if (status == JobStatus.open.name)
          _sharing
              ? const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : NeuIconButton(
                  icon: Icons.share_rounded,
                  semanticLabel: context.tr('share_job'),
                  onPressed: _share,
                ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job['title'] as String? ?? '',
                  style: AppText.headline,
                ),
              ),
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
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: AppRadius.mdAll,
                  child: Image.network(
                    photoUrls[i],
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          NeuCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.build_outlined,
                  label: context.tr('skill'),
                  value: job['skill_needed'] as String? ?? '-',
                ),
                const SizedBox(height: AppSpacing.md),
                _DetailRow(
                  icon: Icons.date_range_rounded,
                  label: context.tr('dates'),
                  value: '${job['start_date']} → ${job['end_date']}',
                ),
                if (job['daily_wage'] != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    label: context.tr('wage'),
                    value:
                        '${job['daily_wage']}/${context.tr('share_per_day')}',
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: context.tr('address'),
                  value: job['address_text'] as String? ?? '-',
                ),
                if ((job['address_line2'] as String?)?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DetailRow(
                    icon: Icons.storefront_outlined,
                    label: context.tr('shop_landmark'),
                    value: job['address_line2'] as String,
                  ),
                ],
              ],
            ),
          ),
          if (!widget.isOwner &&
              myApplicationStatus != null &&
              myApplicationStatus != ApplicationStatus.rejected.name) ...[
            const SizedBox(height: AppSpacing.lg),
            NeuCard(
              variant: NeuVariant.pressed,
              child: StatusStepper(
                steps: [
                  context.tr('step_applied'),
                  context.tr('step_hired'),
                  context.tr('step_done'),
                ],
                current: status == JobStatus.done.name
                    ? 2
                    : (myApplicationStatus == ApplicationStatus.accepted.name
                          ? 1
                          : 0),
              ),
            ),
          ],
          if (widget.isOwner && hiredWorkers.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              hiredWorkers.length > 1
                  ? context.tr('hired_workers')
                  : context.tr('hired_worker'),
            ),
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
                          Text(
                            w['full_name'] as String? ?? '-',
                            style: AppText.title,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            w['phone'] as String? ?? '-',
                            style: AppText.body.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
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
            SectionHeader(context.tr('owner_contact')),
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
                        Text(
                          ownerContact['full_name'] as String? ?? '-',
                          style: AppText.title,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ownerContact['phone'] as String? ?? '-',
                          style: AppText.body.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (status == JobStatus.done.name &&
              (widget.isOwner ? hiredWorkers.isNotEmpty : isHiredAsWorker) &&
              (_myReview == null || _editingReview)) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              widget.isOwner
                  ? context.tr('rate_a_worker')
                  : context.tr('rate_the_owner'),
            ),
            NeuCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isOwner &&
                      hiredWorkers.length > 1 &&
                      _myReview == null) ...[
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _reviewTargetWorkerId,
                      dropdownColor: c.surfaceHigh,
                      items: hiredWorkers
                          .map(
                            (w) => DropdownMenuItem(
                              value: w['worker_id'] as String,
                              child: Text(w['full_name'] as String? ?? '-'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _reviewTargetWorkerId = v),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => IconButton(
                        icon: Icon(
                          i < _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: c.accent,
                          size: 32,
                        ),
                        onPressed: () => setState(() => _rating = i + 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  NeuTextField(
                    label: context.tr('comment_optional'),
                    controller: _commentController,
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  NeuButton(
                    label: context.tr(
                      _myReview == null ? 'submit_review' : 'update_review',
                    ),
                    loading: _reviewSubmitting,
                    onPressed: _submitReview,
                  ),
                  if (_editingReview) ...[
                    const SizedBox(height: AppSpacing.sm),
                    NeuButton(
                      label: context.tr('cancel'),
                      variant: NeuButtonVariant.ghost,
                      onPressed: () => setState(() => _editingReview = false),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (status == JobStatus.done.name &&
              _myReview != null &&
              !_editingReview) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(context.tr('your_review')),
            NeuCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < (_myReview!['rating'] as int)
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: c.accent,
                        size: 24,
                      ),
                    ),
                  ),
                  if ((_myReview!['comment'] as String?)?.isNotEmpty ??
                      false) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(_myReview!['comment'] as String, style: AppText.body),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  NeuButton(
                    label: context.tr('edit_review'),
                    icon: Icons.edit_outlined,
                    variant: NeuButtonVariant.ghost,
                    onPressed: _startEditReview,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          if (!widget.isOwner && status == JobStatus.open.name)
            myApplicationStatus == null
                ? SlideToConfirm(
                    label: context.tr('slide_to_apply'),
                    loading: _loading,
                    onConfirmed: _apply,
                  )
                : NeuButton(
                    label:
                        myApplicationStatus == ApplicationStatus.rejected.name
                        ? context.tr('not_selected')
                        : context.tr('applied'),
                    icon: Icons.check_rounded,
                    onPressed: null,
                  ),
          if (widget.isOwner && status == JobStatus.hired.name)
            NeuButton(
              label: context.tr('mark_complete'),
              icon: Icons.check_circle_outline_rounded,
              loading: _loading,
              onPressed: _complete,
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
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
              Text(
                label.toUpperCase(),
                style: AppText.label.copyWith(color: c.textTertiary),
              ),
              const SizedBox(height: 2),
              Text(value, style: AppText.body),
            ],
          ),
        ),
      ],
    );
  }
}
