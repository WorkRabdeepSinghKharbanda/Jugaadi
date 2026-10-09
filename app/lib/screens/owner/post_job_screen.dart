import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/services/place_gateway.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../auth/profile_setup_screen.dart';

/// Create mode when [existingJob] is null; edit mode (PATCH, open jobs only) otherwise.
class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key, this.existingJob});

  final Map<String, dynamic>? existingJob;

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  late final _titleController = TextEditingController(text: widget.existingJob?['title'] as String?);
  late final _wageController = TextEditingController(text: widget.existingJob?['daily_wage']?.toString());
  late String _skill = widget.existingJob?['skill_needed'] as String? ?? kSkillOptions.first;
  DateTimeRange? _range;
  PlaceHit? _place;
  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.existingJob != null;

  @override
  void initState() {
    super.initState();
    final job = widget.existingJob;
    if (job != null) {
      _range = DateTimeRange(start: DateTime.parse(job['start_date'] as String), end: DateTime.parse(job['end_date'] as String));
      _place = PlaceHit(label: job['address_text'] as String? ?? '', latitude: (job['lat'] as num).toDouble(), longitude: (job['lng'] as num).toDouble());
    }
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (range != null) setState(() => _range = range);
  }

  Future<void> _pickLocation() async {
    final place = await LocationPickerSheet.show(context);
    if (place != null && mounted) setState(() => _place = place);
  }

  Future<void> _submit() async {
    if (_range == null) {
      setState(() => _error = 'Pick start and end dates');
      return;
    }
    if (_place == null) {
      setState(() => _error = 'Set the job location first');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final body = {
      'title': _titleController.text.trim(),
      'skill_needed': _skill,
      'lat': _place!.latitude,
      'lng': _place!.longitude,
      'address_text': _place!.label,
      'start_date': _range!.start.toIso8601String().split('T').first,
      'end_date': _range!.end.toIso8601String().split('T').first,
      if (_wageController.text.trim().isNotEmpty) 'daily_wage': num.tryParse(_wageController.text.trim()),
    };
    try {
      final api = ApiClient(Config.apiBaseUrl);
      if (_isEdit) {
        await api.patch('/jobs/${widget.existingJob!['id']}', body);
      } else {
        await api.post('/jobs', body);
      }
      if (!mounted) return;
      showAppToast(context, _isEdit ? 'Job updated' : 'Job posted successfully');
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
      title: _isEdit ? 'Edit job' : 'Post a job',
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
          Text('LOCATION', style: AppText.label.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          NeuCard(
            onTap: _pickLocation,
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: _place == null ? c.textSecondary : c.accent),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _place?.label ?? 'Tap to set job location',
                    style: AppText.body.copyWith(color: _place == null ? c.textTertiary : c.textPrimary),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.textTertiary),
              ],
            ),
          ),
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
          NeuButton(label: _isEdit ? 'Save changes' : 'Post job', icon: Icons.check_rounded, loading: _loading, onPressed: _submit),
        ],
      ),
    );
  }
}
