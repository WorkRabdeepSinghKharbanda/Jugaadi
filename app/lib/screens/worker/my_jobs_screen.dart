import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('My applications')),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _future = _load()),
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final applications = snapshot.data!;
            if (applications.isEmpty) return const Center(child: Text('No applications yet'));
            return ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, i) {
                final entry = applications[i] as Map<String, dynamic>;
                final job = entry['job'] as Map<String, dynamic>;
                return ListTile(
                  title: Text(job['title']),
                  subtitle: Text('Application: ${entry['status']} · Job: ${job['status']}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => JobDetailScreen(job: job, isOwner: false)),
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
