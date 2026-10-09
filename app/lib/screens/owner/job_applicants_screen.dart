import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final applicants = snapshot.data!;
          if (applicants.isEmpty) return const Center(child: Text('No applicants yet'));
          return ListView.builder(
            itemCount: applicants.length,
            itemBuilder: (context, i) {
              final a = applicants[i] as Map<String, dynamic>;
              final worker = a['worker'] as Map<String, dynamic>?;
              return ListTile(
                title: Text(worker?['full_name'] ?? 'Unknown'),
                subtitle: Text(worker?['is_verified'] == true ? 'Verified' : 'Pending verification'),
                trailing: ElevatedButton(
                  onPressed: () => _hire(a['worker_id']),
                  child: const Text('Hire'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
