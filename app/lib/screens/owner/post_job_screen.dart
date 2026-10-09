import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../auth/profile_setup_screen.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _wageController = TextEditingController();
  String _skill = kSkillOptions.first;
  DateTimeRange? _range;
  bool _loading = false;
  String? _error;

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (range != null) setState(() => _range = range);
  }

  Future<void> _submit() async {
    if (_range == null) {
      setState(() => _error = 'Pick start and end dates');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      await ApiClient(Config.apiBaseUrl).post('/jobs', {
        'title': _titleController.text.trim(),
        'skill_needed': _skill,
        'lat': position.latitude,
        'lng': position.longitude,
        'address_text': _addressController.text.trim(),
        'start_date': _range!.start.toIso8601String().split('T').first,
        'end_date': _range!.end.toIso8601String().split('T').first,
        if (_wageController.text.trim().isNotEmpty) 'daily_wage': num.tryParse(_wageController.text.trim()),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            DropdownButtonFormField<String>(
              value: _skill,
              items: kSkillOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _skill = v!),
              decoration: const InputDecoration(labelText: 'Skill needed'),
            ),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address')),
            TextField(
              controller: _wageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Daily wage (optional)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _pickDates,
              child: Text(_range == null
                  ? 'Pick dates'
                  : '${_range!.start.toIso8601String().split('T').first} → ${_range!.end.toIso8601String().split('T').first}'),
            ),
            const SizedBox(height: 16),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator() : const Text('Post job'),
            ),
          ],
        ),
      ),
    );
  }
}
