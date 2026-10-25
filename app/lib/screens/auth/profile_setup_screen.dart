import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/i18n/strings.dart';
import '../../core/services/place_gateway.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../main.dart';

const kSkillOptions = [
  'loading-unloading',
  'helper',
  'cleaning',
  'cook',
  'delivery',
  'packing',
  'driver',
  'electrician',
  'plumber',
  'carpenter',
  'painter',
  'security-guard',
  'gardener',
  'mason',
  'welder',
  'babysitter/caretaker',
  'event-staff',
  'warehouse-labour',
];

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, required this.role});

  final String role;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _customSkillController = TextEditingController();
  final _selectedSkills = <String>{};
  PlaceHit? _place;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  void _addCustomSkill() {
    final skill = _customSkillController.text.trim();
    if (skill.isEmpty) return;
    setState(() {
      _selectedSkills.add(skill);
      _customSkillController.clear();
    });
  }

  Future<void> _pickLocation() async {
    final place = await LocationPickerSheet.show(context);
    if (place != null && mounted) setState(() => _place = place);
  }

  Future<void> _save() async {
    if (_place == null) {
      setState(() => _error = context.tr('set_location_first'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ApiClient(Config.apiBaseUrl);
      await api.post('/profile', {
        'role': widget.role,
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _place!.label,
        'lat': _place!.latitude,
        'lng': _place!.longitude,
        if (_emailController.text.trim().isNotEmpty)
          'email': _emailController.text.trim(),
        if (widget.role == 'worker') 'skills': _selectedSkills.toList(),
      });

      if (!mounted) return;
      showAppToast(context, context.tr('profile_saved'));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootRouter()),
        (route) => false,
      );
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
      title: context.tr('set_up_profile_title'),
      scroll: true,
      resizeForKeyboard: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeuTextField(
            label: context.tr('full_name'),
            controller: _nameController,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          NeuTextField(
            label: context.tr('phone'),
            controller: _phoneController,
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          NeuTextField(
            label: context.tr('email_optional'),
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.tr('location_label'),
            style: AppText.label.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          NeuCard(
            onTap: _pickLocation,
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: _place == null ? c.textSecondary : c.accent,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _place?.label ?? context.tr('tap_to_set_location'),
                    style: AppText.body.copyWith(
                      color: _place == null ? c.textTertiary : c.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.textTertiary),
              ],
            ),
          ),
          if (widget.role == 'worker') ...[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(context.tr('your_skills')),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: kSkillOptions
                  .map(
                    (skill) => FilterChip(
                      label: Text(skill),
                      selected: _selectedSkills.contains(skill),
                      onSelected: (selected) => setState(() {
                        selected
                            ? _selectedSkills.add(skill)
                            : _selectedSkills.remove(skill);
                      }),
                    ),
                  )
                  .toList(),
            ),
            if (_selectedSkills.any((s) => !kSkillOptions.contains(s))) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _selectedSkills
                    .where((s) => !kSkillOptions.contains(s))
                    .map(
                      (s) => Chip(
                        label: Text(s),
                        onDeleted: () =>
                            setState(() => _selectedSkills.remove(s)),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: NeuTextField(
                    label: context.tr('other_skill'),
                    controller: _customSkillController,
                    hint: context.tr('other_skill_hint'),
                    onSubmitted: (_) => _addCustomSkill(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                NeuButton(
                  label: context.tr('add'),
                  expand: false,
                  height: 48,
                  onPressed: _addCustomSkill,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (_error != null) ...[
            ErrorStrip(_error!),
            const SizedBox(height: AppSpacing.lg),
          ],
          NeuButton(
            label: context.tr('continue'),
            icon: Icons.arrow_forward_rounded,
            loading: _loading,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
