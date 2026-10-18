import 'package:flutter/material.dart';
import '../api_client.dart';
import '../config.dart';
import 'i18n/strings.dart';
import 'skeleton.dart';
import 'theme/tokens.dart';
import 'widgets/widgets.dart';

const _reasons = ['spam', 'scam', 'abusive', 'wrong_info', 'other'];

/// Reason picker + optional details, then POST /reports. [targetType] is 'job' or 'user'.
Future<void> showReportSheet(BuildContext context, {required String targetType, required Object targetId}) async {
  final sent = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ReportSheet(targetType: targetType, targetId: '$targetId'),
  );
  if (sent == true && context.mounted) showAppToast(context, context.tr('report_sent'));
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.targetType, required this.targetId});
  final String targetType;
  final String targetId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _details = TextEditingController();
  String? _reason;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() { _sending = true; _error = null; });
    try {
      await ApiClient(Config.apiBaseUrl).post('/reports', {
        'target_type': widget.targetType,
        'target_id': widget.targetId,
        'reason': _reason,
        if (_details.text.trim().isNotEmpty) 'details': _details.text.trim(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _sending = false; _error = errorMessage(context, e); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.lg),
        decoration: BoxDecoration(color: c.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: AppSpacing.lg), decoration: BoxDecoration(color: c.outline, borderRadius: BorderRadius.circular(2)))),
              Text(widget.targetType == 'job' ? context.tr('report_job') : context.tr('report_user'), style: AppText.title),
              const SizedBox(height: AppSpacing.xs),
              Text(context.tr('report_why'), style: AppText.bodySmall.copyWith(color: c.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              for (final r in _reasons)
                InkWell(
                  onTap: () => setState(() => _reason = r),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Row(
                      children: [
                        Icon(_reason == r ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: _reason == r ? c.accent : c.textTertiary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(context.tr('reason_$r'), style: AppText.body.copyWith(color: c.textPrimary))),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              NeuTextField(label: context.tr('report_details_hint'), controller: _details, maxLines: 3),
              if (_error != null) ...[const SizedBox(height: AppSpacing.sm), ErrorStrip(_error!)],
              const SizedBox(height: AppSpacing.md),
              NeuButton(label: context.tr('send_report'), icon: Icons.flag_outlined, loading: _sending, onPressed: _reason == null ? null : _send),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirm, then POST /blocks/:userId. Returns true if the block went through.
Future<bool> confirmAndBlock(BuildContext context, {required String userId}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.tr('block_confirm_title')),
      content: Text(ctx.tr('block_confirm_body')),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(ctx.tr('cancel'))),
        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(ctx.tr('block_user'))),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;
  try {
    await ApiClient(Config.apiBaseUrl).post('/blocks/$userId');
    if (context.mounted) showAppToast(context, context.tr('user_blocked'));
    return true;
  } catch (e) {
    if (context.mounted) showAppToast(context, errorMessage(context, e), tone: ToastTone.error);
    return false;
  }
}

/// Profile → "Blocked people": list with an unblock button each.
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late Future<List<dynamic>> _future = _load();

  Future<List<dynamic>> _load() async => await ApiClient(Config.apiBaseUrl).get('/blocks') as List<dynamic>;

  Future<void> _unblock(String id) async {
    try {
      await ApiClient(Config.apiBaseUrl).delete('/blocks/$id');
      if (mounted) showAppToast(context, context.tr('user_unblocked'));
      setState(() => _future = _load());
    } catch (e) {
      if (mounted) showAppToast(context, errorMessage(context, e), tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      title: context.tr('blocked_users'),
      fullBleed: true,
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const SkeletonList(itemCount: 4);
          if (snap.hasError) {
            return Center(child: Padding(padding: AppSpacing.screen, child: Column(mainAxisSize: MainAxisSize.min, children: [
              ErrorStrip(errorMessage(context, snap.error!)),
              const SizedBox(height: AppSpacing.md),
              NeuButton(label: context.tr('retry'), expand: false, onPressed: () => setState(() => _future = _load())),
            ])));
          }
          final rows = snap.data!;
          if (rows.isEmpty) return EmptyState(icon: Icons.block_rounded, text: context.tr('no_blocked_users'));
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
            itemCount: rows.length,
            itemBuilder: (_, i) {
              final r = rows[i] as Map<String, dynamic>;
              final name = (r['blocked'] as Map<String, dynamic>?)?['full_name'] as String? ?? context.tr('unknown');
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: NeuCard(
                  child: Row(children: [
                    Expanded(child: Text(name, style: AppText.title.copyWith(color: c.textPrimary))),
                    NeuButton(label: context.tr('unblock'), expand: false, height: 40, variant: NeuButtonVariant.ghost, onPressed: () => _unblock(r['blocked_id'] as String)),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
