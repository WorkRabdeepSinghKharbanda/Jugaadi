import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';

class JobApplicantsScreen extends StatefulWidget {
  const JobApplicantsScreen({super.key, required this.jobId});

  final dynamic jobId;

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/jobs/${widget.jobId}/applicants');
    return data as List<dynamic>;
  }

  Future<void> _hire(String workerId) async {
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${widget.jobId}/hire/$workerId');
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(title: const Text('Applicants')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: c.accent));
          final applicants = snapshot.data!;
          if (applicants.isEmpty) return const EmptyState(icon: Icons.people_outline_rounded, text: 'No applicants yet');
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
            itemCount: applicants.length,
            itemBuilder: (context, i) {
              final a = applicants[i] as Map<String, dynamic>;
              final worker = a['worker'] as Map<String, dynamic>?;
              final verified = worker?['is_verified'] == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: NeuCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: c.surfaceHigh,
                        child: Icon(Icons.person_rounded, color: c.textSecondary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(worker?['full_name'] as String? ?? 'Unknown', style: AppText.title),
                            const SizedBox(height: 4),
                            verified ? const PillBadge.verified() : PillBadge(label: 'Pending verification'),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      NeuButton(label: 'Hire', expand: false, height: 44, onPressed: () => _hire(a['worker_id'] as String)),
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
