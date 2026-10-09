import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../job_detail_screen.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/applications/mine');
    return data as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      title: 'My applications',
      fullBleed: true,
      body: RefreshIndicator(
        color: c.accent,
        onRefresh: () async => setState(() { _future = _load(); }),
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
                      NeuButton(label: 'Retry', expand: false, onPressed: () => setState(() { _future = _load(); })),
                    ],
                  ),
                ),
              );
            }
            final applications = snapshot.data!;
            if (applications.isEmpty) return const EmptyState(icon: Icons.inbox_outlined, text: 'No applications yet');
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
              itemCount: applications.length,
              itemBuilder: (context, i) {
                final entry = applications[i] as Map<String, dynamic>;
                final job = entry['job'] as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: NeuCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job, isOwner: false)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job['title'] as String, style: AppText.title),
                              const SizedBox(height: 4),
                              Text('Job: ${job['status']}', style: AppText.bodySmall.copyWith(color: c.textSecondary)),
                            ],
                          ),
                        ),
                        PillBadge.status(entry['status'] as String),
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
