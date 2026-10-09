import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
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
    final c = context.colors;
    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      title: 'Post a job',
      scroll: true,
      resizeForKeyboard: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeuTextField(label: 'Title', controller: _titleController, icon: Icons.title_rounded),
          const SizedBox(height: AppSpacing.md),
          Text('SKILL NEEDED', style: AppText.label.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _skill,
            items: kSkillOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _skill = v!),
            dropdownColor: c.surfaceHigh,
          ),
          const SizedBox(height: AppSpacing.md),
          NeuTextField(label: 'Address', controller: _addressController, icon: Icons.location_on_outlined),
          const SizedBox(height: AppSpacing.md),
          NeuTextField(label: 'Daily wage (optional)', controller: _wageController, icon: Icons.payments_outlined, keyboardType: TextInputType.number),
          const SizedBox(height: AppSpacing.lg),
          NeuButton(
            label: _range == null
                ? 'Pick dates'
                : '${_range!.start.toIso8601String().split('T').first} → ${_range!.end.toIso8601String().split('T').first}',
            icon: Icons.date_range_rounded,
            variant: NeuButtonVariant.ghost,
            onPressed: _pickDates,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null) ...[
            ErrorStrip(_error!),
            const SizedBox(height: AppSpacing.lg),
          ],
          NeuButton(label: 'Post job', icon: Icons.check_rounded, loading: _loading, onPressed: _submit),
        ],
      ),
    );
  }
}
