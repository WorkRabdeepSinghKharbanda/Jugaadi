import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/job_photos.dart';
import '../../core/services/place_gateway.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../auth/profile_setup_screen.dart';

const _kMaxJobPhotos = 6;

/// Create mode when [existingJob] is null; edit mode (PATCH, open jobs only) otherwise.
class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key, this.existingJob});

  final Map<String, dynamic>? existingJob;

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

const _kOtherSkill = 'Other';

class _PostJobScreenState extends State<PostJobScreen> {
  late final _titleController = TextEditingController(text: widget.existingJob?['title'] as String?);
  late final _wageController = TextEditingController(text: widget.existingJob?['daily_wage']?.toString());
  late final _workersNeededController = TextEditingController(text: '${widget.existingJob?['workers_needed'] ?? 1}');
  late final _customSkillController = TextEditingController(
    text: _initialSkillIsCustom ? (widget.existingJob?['skill_needed'] as String?) : null,
  );
  late String _skill = _initialSkillIsCustom ? _kOtherSkill : (widget.existingJob?['skill_needed'] as String? ?? kSkillOptions.first);
  DateTimeRange? _range;
  PlaceHit? _place;
  bool _loading = false;
  String? _error;
  late final _photoUrls = <String>[...(widget.existingJob?['photo_urls'] as List<dynamic>? ?? const [])];
  bool _uploadingPhotos = false;
  // Set once a brand-new job gets silently created (first "Add photos" tap needs a job id to
  // attach to) — from then on this screen behaves like edit mode even though it started as create.
  Map<String, dynamic>? _createdJob;

  // Whether this screen started in edit mode (controls title/copy — "workers needed" stays
  // create-only regardless of whether a job got silently created via the photo flow below).
  bool get _isEdit => widget.existingJob != null;
  Map<String, dynamic>? get _job => widget.existingJob ?? _createdJob;
  bool get _hasJobId => _job != null;
  bool get _initialSkillIsCustom {
    final existing = widget.existingJob?['skill_needed'] as String?;
    return existing != null && !kSkillOptions.contains(existing);
  }

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

  /// Validates the form same as a real submit, and returns the field body — used both by the
  /// final submit and by the "silently create so photos have somewhere to attach" path.
  Map<String, dynamic>? _buildBodyOrShowError() {
    if (_range == null) {
      setState(() => _error = 'Pick start and end dates');
      return null;
    }
    if (_place == null) {
      setState(() => _error = 'Set the job location first');
      return null;
    }
    final skillNeeded = _skill == _kOtherSkill ? _customSkillController.text.trim() : _skill;
    if (skillNeeded.isEmpty) {
      setState(() => _error = 'Type the skill needed');
      return null;
    }
    return {
      'title': _titleController.text.trim(),
      'skill_needed': skillNeeded,
      'lat': _place!.latitude,
      'lng': _place!.longitude,
      'address_text': _place!.label,
      'start_date': _range!.start.toIso8601String().split('T').first,
      'end_date': _range!.end.toIso8601String().split('T').first,
      if (_wageController.text.trim().isNotEmpty) 'daily_wage': num.tryParse(_wageController.text.trim()),
      if (!_isEdit) 'workers_needed': int.tryParse(_workersNeededController.text.trim()) ?? 1,
    };
  }

  Future<void> _addPhotos() async {
    if (!_hasJobId) {
      final body = _buildBodyOrShowError();
      if (body == null) return;
      setState(() => _uploadingPhotos = true);
      try {
        final created = await ApiClient(Config.apiBaseUrl).post('/jobs', body) as Map<String, dynamic>;
        setState(() => _createdJob = created);
      } catch (e) {
        if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
        if (mounted) setState(() => _uploadingPhotos = false);
        return;
      }
    } else {
      setState(() => _uploadingPhotos = true);
    }
    try {
      final uploaded = await pickAndUploadJobPhotos('${_job!['id']}', remaining: _kMaxJobPhotos - _photoUrls.length);
      if (mounted) setState(() => _photoUrls.addAll(uploaded));
    } catch (e) {
      if (mounted) showAppToast(context, '$e', tone: ToastTone.error);
    } finally {
      if (mounted) setState(() => _uploadingPhotos = false);
    }
  }

  Future<void> _submit() async {
    final body = _buildBodyOrShowError();
    if (body == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ApiClient(Config.apiBaseUrl);
      if (_hasJobId) {
        await api.patch('/jobs/${_job!['id']}', body);
      } else {
        await api.post('/jobs', body);
      }
      if (!mounted) return;
      showAppToast(context, _hasJobId ? 'Job updated' : 'Job posted successfully');
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e is ApiException ? e.message : '$e');
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
            items: [...kSkillOptions, _kOtherSkill].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _skill = v!),
            dropdownColor: c.surfaceHigh,
          ),
          if (_skill == _kOtherSkill) ...[
            const SizedBox(height: AppSpacing.md),
            NeuTextField(label: 'Specify skill', controller: _customSkillController, hint: 'Type the skill needed'),
          ],
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
          if (!_isEdit) ...[
            const SizedBox(height: AppSpacing.md),
            NeuTextField(
              label: 'Workers needed',
              controller: _workersNeededController,
              icon: Icons.groups_outlined,
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SectionHeader('Photos (${_photoUrls.length}/$_kMaxJobPhotos)'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final url in _photoUrls)
                ClipRRect(
                  borderRadius: AppRadius.smAll,
                  child: Image.network(url, width: 88, height: 88, fit: BoxFit.cover),
                ),
              if (_photoUrls.length < _kMaxJobPhotos)
                NeuButton(
                  label: 'Add',
                  icon: Icons.add_a_photo_outlined,
                  variant: NeuButtonVariant.ghost,
                  expand: false,
                  height: 88,
                  loading: _uploadingPhotos,
                  onPressed: _addPhotos,
                ),
            ],
          ),
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
          NeuButton(label: _hasJobId ? 'Save changes' : 'Post job', icon: Icons.check_rounded, loading: _loading, onPressed: _submit),
        ],
      ),
    );
  }
}
