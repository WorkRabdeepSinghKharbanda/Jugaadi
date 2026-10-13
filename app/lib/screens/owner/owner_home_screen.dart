import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/i18n/strings.dart';
import '../../core/job_status.dart';
import '../../core/theme/tokens.dart';
import '../../core/update_location.dart';
import '../../core/widgets/widgets.dart';
import '../../main.dart';
import '../admin/admin_home_screen.dart';
import '../job_detail_screen.dart';
import '../plans_screen.dart';
import '../profile_screen.dart';
import 'job_applicants_screen.dart';
import 'post_job_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  late Future<List<dynamic>> _future;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    try {
      final profile = await ApiClient(Config.apiBaseUrl).get('/profile/me') as Map<String, dynamic>;
      if (mounted) setState(() => _isAdmin = profile['is_admin'] == true);
    } catch (_) {
      // not critical — the admin icon just stays hidden
    }
  }

  Future<List<dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/jobs/mine');
    return data as List<dynamic>;
  }

  void _refresh() => setState(() { _future = _load(); });

  Future<void> _edit(Map<String, dynamic> job) async {
    final updated = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostJobScreen(existingJob: job)),
    );
    if (updated == true) _refresh();
  }

  Future<void> _remove(dynamic jobId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('remove_job_title')),
        content: Text(ctx.tr('remove_job_body')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(ctx.tr('cancel'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(ctx.tr('remove'))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/$jobId/remove');
      if (mounted) showAppToast(context, context.tr('job_removed'));
      _refresh();
    } catch (e) {
      if (mounted) showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      title: context.tr('my_jobs_title'),
      fullBleed: true,
      actions: [
        if (_isAdmin)
          NeuIconButton(
            icon: Icons.admin_panel_settings_outlined,
            semanticLabel: context.tr('admin_console'),
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminHomeScreen())),
          ),
        NeuIconButton(
          icon: Icons.swap_horiz_rounded,
          semanticLabel: context.tr('find_work_instead'),
          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const WorkerTabs())),
        ),
        NeuIconButton(
          icon: Icons.bolt_outlined,
          semanticLabel: context.tr('plan'),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlansScreen(role: 'owner'))),
        ),
        NeuIconButton(icon: Icons.location_on_outlined, semanticLabel: context.tr('update_location'), onPressed: () => editLocation(context)),
        NeuIconButton(
          icon: Icons.person_outline_rounded,
          semanticLabel: context.tr('profile_title'),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        onPressed: () async {
          final posted = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PostJobScreen()),
          );
          if (posted == true) _refresh();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        color: c.accent,
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator(color: c.accent));
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: AppSpacing.screen,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ErrorStrip(errorMessage(context, snapshot.error!)),
                      const SizedBox(height: AppSpacing.md),
                      NeuButton(label: context.tr('retry'), expand: false, onPressed: _refresh),
                    ],
                  ),
                ),
              );
            }
            final jobs = snapshot.data!;
            if (jobs.isEmpty) {
              return EmptyState(icon: Icons.work_outline_rounded, text: context.tr('no_jobs_posted_yet'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
              itemCount: jobs.length,
              itemBuilder: (context, i) {
                final job = jobs[i] as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: NeuCard(
                    onTap: () async {
                      if (job['status'] == JobStatus.open.name) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => JobApplicantsScreen(job: job)),
                        );
                        _refresh();
                      } else {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => JobDetailScreen(job: job, isOwner: true)),
                        );
                        _refresh();
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job['title'] as String, style: AppText.title),
                              const SizedBox(height: 4),
                              Text(job['skill_needed'] as String, style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                              if ((job['workers_needed'] as int? ?? 1) > 1) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${job['hired_count'] ?? 0}/${job['workers_needed']} ${context.tr('hired_suffix')}',
                                  style: AppText.bodySmall.copyWith(color: c.textTertiary),
                                ),
                              ],
                            ],
                          ),
                        ),
                        PillBadge.status(job['status'] as String),
                        if (job['status'] == JobStatus.open.name)
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, color: c.textSecondary),
                            onSelected: (action) {
                              if (action == 'edit') _edit(job);
                              if (action == 'remove') _remove(job['id']);
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'edit', child: Text(context.tr('edit'))),
                              PopupMenuItem(value: 'remove', child: Text(context.tr('remove'))),
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
      ),
    );
  }
}
