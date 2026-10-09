import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/theme/tokens.dart';
import '../../core/update_location.dart';
import '../../core/widgets/widgets.dart';
import '../job_detail_screen.dart';
import 'job_applicants_screen.dart';
import 'post_job_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/jobs/mine');
    return data as List<dynamic>;
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text('My jobs'),
        actions: [
          IconButton(icon: const Icon(Icons.location_on_outlined), tooltip: 'Update location', onPressed: () => editLocation(context)),
        ],
      ),
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
                      ErrorStrip('${snapshot.error}'),
                      const SizedBox(height: AppSpacing.md),
                      NeuButton(label: 'Retry', expand: false, onPressed: _refresh),
                    ],
                  ),
                ),
              );
            }
            final jobs = snapshot.data!;
            if (jobs.isEmpty) {
              return const EmptyState(icon: Icons.work_outline_rounded, text: 'No jobs posted yet');
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
                      if (job['status'] == 'open') {
                        final hired = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => JobApplicantsScreen(jobId: job['id'])),
                        );
                        if (hired == true) _refresh();
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
                            ],
                          ),
                        ),
                        PillBadge.status(job['status'] as String),
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
