import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/i18n/strings.dart';
import '../../core/job_photos.dart';
import '../../core/services/place_gateway.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../auth/profile_setup_screen.dart';
import '../plans_screen.dart';

const _kMaxJobPhotos = 6;

/// Create mode when [existingJob] is null; edit mode (PATCH, open jobs only) otherwise.
class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key, this.existingJob, this.repostFrom});

  final Map<String, dynamic>? existingJob;

  /// Prefills a NEW job from an old one (dates and photos are not copied).
  final Map<String, dynamic>? repostFrom;

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

const _kOtherSkill = 'Other';

class _PostJobScreenState extends State<PostJobScreen> {
  late final _titleController = TextEditingController(text: _seed?['title'] as String?);
  late final _addressLine2Controller = TextEditingController(text: _seed?['address_line2'] as String?);
  late final _wageController = TextEditingController(text: _seed?['daily_wage']?.toString());
  late final _workersNeededController = TextEditingController(text: '${_seed?['workers_needed'] ?? 1}');
  late final _customSkillController = TextEditingController(
    text: _initialSkillIsCustom ? (_seed?['skill_needed'] as String?) : null,
  );
  late String _skill = _initialSkillIsCustom ? _kOtherSkill : (_seed?['skill_needed'] as String? ?? kSkillOptions.first);
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
  Map<String, dynamic>? get _seed => widget.existingJob ?? widget.repostFrom;
  bool get _isEdit => widget.existingJob != null;
  Map<String, dynamic>? get _job => widget.existingJob ?? _createdJob;
  bool get _hasJobId => _job != null;
  bool get _initialSkillIsCustom {
    final existing = _seed?['skill_needed'] as String?;
    return existing != null && !kSkillOptions.contains(existing);
  }

  /// First unmet requirement, or null once the form is postable — same checks as
  /// [_buildBodyOrShowError], kept separate so the button/photos gate can run without
  /// triggering the inline `_error` strip on every keystroke.
  String? get _missingField {
    if (_titleController.text.trim().isEmpty) return context.tr('title_required');
    if (_skill == _kOtherSkill && _customSkillController.text.trim().isEmpty) return context.tr('specify_skill_needed');
    if (_place == null) return context.tr('set_job_location');
    if (_range == null) return context.tr('pick_start_end_dates');
    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressLine2Controller.dispose();
    _wageController.dispose();
    _workersNeededController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final job = _seed;
    if (job != null) {
      final existing = widget.existingJob;
      if (existing != null) {
        _range = DateTimeRange(start: DateTime.parse(existing['start_date'] as String), end: DateTime.parse(existing['end_date'] as String));
      }
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
    final missing = _missingField;
    if (missing != null) {
      showAppToast(context, missing, tone: ToastTone.error);
      return null;
    }
    final skillNeeded = _skill == _kOtherSkill ? _customSkillController.text.trim() : _skill;
    return {
      'title': _titleController.text.trim(),
      'skill_needed': skillNeeded,
      'lat': _place!.latitude,
      'lng': _place!.longitude,
      'address_text': _place!.label,
      'address_line2': _addressLine2Controller.text.trim().isEmpty ? null : _addressLine2Controller.text.trim(),
      'start_date': _range!.start.toIso8601String().split('T').first,
      'end_date': _range!.end.toIso8601String().split('T').first,
      if (_wageController.text.trim().isNotEmpty) 'daily_wage': num.tryParse(_wageController.text.trim()),
      if (!_isEdit) 'workers_needed': int.tryParse(_workersNeededController.text.trim()) ?? 1,
    };
  }

  Future<void> _addPhotos() async {
    if (!_hasJobId) {
      final missing = _missingField;
      if (missing != null) {
        showAppToast(context, missing, tone: ToastTone.error);
        return;
      }
      final body = _buildBodyOrShowError();
      if (body == null) return;
      setState(() => _uploadingPhotos = true);
      try {
        final created = await ApiClient(Config.apiBaseUrl).post('/jobs', body) as Map<String, dynamic>;
        setState(() => _createdJob = created);
      } catch (e) {
        if (mounted) showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
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
      if (mounted) showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
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
      showAppToast(context, _hasJobId ? context.tr('job_updated') : context.tr('job_posted_successfully'));
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'plan_limit') {
        showAppToast(context, e.message, tone: ToastTone.error);
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlansScreen(role: 'owner')));
      } else {
        setState(() => _error = e.message);
      }
    } catch (e) {
      setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      title: _isEdit ? context.tr('edit_job_title') : context.tr('post_a_job_title'),
      scroll: true,
      resizeForKeyboard: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeuTextField(label: context.tr('title_label'), controller: _titleController, icon: Icons.title_rounded),
          const SizedBox(height: AppSpacing.md),
          Text(context.tr('skill_needed_label'), style: AppText.label.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _skill,
            items: [...kSkillOptions, _kOtherSkill].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _skill = v!),
            dropdownColor: c.surfaceHigh,
          ),
          if (_skill == _kOtherSkill) ...[
            const SizedBox(height: AppSpacing.md),
            NeuTextField(label: context.tr('specify_skill'), controller: _customSkillController, hint: context.tr('type_skill_needed')),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(context.tr('location_label'), style: AppText.label.copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          NeuCard(
            onTap: _pickLocation,
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: _place == null ? c.textSecondary : c.accent),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _place?.label ?? context.tr('tap_to_set_job_location'),
                    style: AppText.body.copyWith(color: _place == null ? c.textTertiary : c.textPrimary),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          NeuTextField(
            label: context.tr('shop_name_address_optional'),
            controller: _addressLine2Controller,
            hint: context.tr('shop_address_hint'),
            icon: Icons.storefront_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          NeuTextField(label: context.tr('daily_wage_optional'), controller: _wageController, icon: Icons.payments_outlined, keyboardType: TextInputType.number),
          if (!_isEdit) ...[
            const SizedBox(height: AppSpacing.md),
            NeuTextField(
              label: context.tr('workers_needed_label'),
              controller: _workersNeededController,
              icon: Icons.groups_outlined,
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SectionHeader('${context.tr('photos_label')} (${_photoUrls.length}/$_kMaxJobPhotos)'),
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
                  label: context.tr('add'),
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
                ? context.tr('pick_dates')
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
          AnimatedBuilder(
            animation: Listenable.merge([_titleController, _customSkillController]),
            builder: (_, __) => NeuButton(
              label: _hasJobId ? context.tr('save_changes') : context.tr('post_job'),
              icon: Icons.check_rounded,
              loading: _loading,
              onPressed: _missingField != null ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
