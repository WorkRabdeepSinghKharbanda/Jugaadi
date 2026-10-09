import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('My jobs')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final posted = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PostJobScreen()),
          );
          if (posted == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final jobs = snapshot.data!;
            if (jobs.isEmpty) return const Center(child: Text('No jobs posted yet'));
            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, i) {
                final job = jobs[i] as Map<String, dynamic>;
                return ListTile(
                  title: Text(job['title']),
                  subtitle: Text('${job['skill_needed']} · ${job['status']}'),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
