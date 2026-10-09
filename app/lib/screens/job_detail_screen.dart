import 'package:flutter/material.dart';
import '../api_client.dart';
import '../config.dart';

/// Shared by owner and worker — the API response already includes
/// hired_worker/owner contact info once status is 'hired', so there's
/// no separate "reveal contact" endpoint to call.
class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.job, required this.isOwner});

  final Map<String, dynamic> job;
  final bool isOwner;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Map<String, dynamic> job;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    job = widget.job;
  }

  Future<void> _complete() async {
    setState(() => _loading = true);
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${job['id']}/complete');
      if (!mounted) return;
      setState(() => job = {...job, 'status': 'completed'});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply() async {
    setState(() => _loading = true);
    try {
      await ApiClient(Config.apiBaseUrl).post('/jobs/${job['id']}/apply');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applied')));
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = job['status'] as String;
    return Scaffold(
      appBar: AppBar(title: Text(job['title'] ?? '')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skill: ${job['skill_needed']}'),
            Text('Dates: ${job['start_date']} → ${job['end_date']}'),
            if (job['daily_wage'] != null) Text('Wage: ${job['daily_wage']}/day'),
            Text('Address: ${job['address_text'] ?? '-'}'),
            Text('Status: $status'),
            const SizedBox(height: 16),
            if (!widget.isOwner && status == 'open')
              ElevatedButton(
                onPressed: _loading ? null : _apply,
                child: const Text('Apply'),
              ),
            if (widget.isOwner && status == 'hired')
              ElevatedButton(
                onPressed: _loading ? null : _complete,
                child: const Text('Mark Complete'),
              ),
          ],
        ),
      ),
    );
  }
}
