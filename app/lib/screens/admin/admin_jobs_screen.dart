import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';

const _kJobStatuses = ['open', 'hired', 'done', 'removed'];

class AdminJobsScreen extends StatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  State<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends State<AdminJobsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/admin/jobs');
    return data as List<dynamic>;
  }

  void _refresh() => setState(() { _future = _load(); });

  Future<void> _forceStatus(Map<String, dynamic> job, String status) async {
    try {
      await ApiClient(Config.apiBaseUrl).patch('/admin/jobs/${job['id']}', {'status': status});
      if (mounted) showAppToast(context, 'Status set to $status');
      _refresh();
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    }
  }

  Future<void> _delete(Map<String, dynamic> job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this job permanently?'),
        content: const Text('This removes the job and cannot be undone (unlike a normal "remove").'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient(Config.apiBaseUrl).delete('/admin/jobs/${job['id']}');
      if (mounted) showAppToast(context, 'Job deleted');
      _refresh();
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return RefreshIndicator(
      color: c.accent,
      onRefresh: () async => _refresh(),
      child: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(color: c.accent));
          }
          if (snapshot.hasError) {
            return Center(child: ErrorStrip('${snapshot.error}'));
          }
          final jobs = snapshot.data!;
          if (jobs.isEmpty) return const EmptyState(icon: Icons.work_outline_rounded, text: 'No jobs');
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
            itemCount: jobs.length,
            itemBuilder: (context, i) {
              final job = jobs[i] as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(job['title'] as String? ?? '-', style: AppText.title)),
                          PillBadge.status(job['status'] as String),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: job['status'] as String,
                              dropdownColor: c.surfaceHigh,
                              items: _kJobStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) {
                                if (v != null && v != job['status']) _forceStatus(job, v);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: c.danger),
                            onPressed: () => _delete(job),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
