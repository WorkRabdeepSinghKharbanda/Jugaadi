import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../job_detail_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
    final data = await ApiClient(Config.apiBaseUrl).get('/jobs/nearby', {
      'lat': position.latitude,
      'lng': position.longitude,
    });
    return data as List<dynamic>;
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby jobs')),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final jobs = snapshot.data!;
            if (jobs.isEmpty) return const Center(child: Text('No open jobs nearby'));
            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, i) {
                final job = jobs[i] as Map<String, dynamic>;
                return ListTile(
                  title: Text(job['title']),
                  subtitle: Text('${job['skill_needed']} · ${job['start_date']} → ${job['end_date']}'),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job, isOwner: false)),
                    );
                    _refresh();
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
