import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api_client.dart';
import '../config.dart';
import '../core/i18n/lang.dart';
import '../core/i18n/strings.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/widgets.dart';
import 'auth/phone_auth_screen.dart';
import 'auth/profile_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _editing = false;
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _customSkillController = TextEditingController();
  final _selectedSkills = <String>{};
  bool _saving = false;
  bool _useCustomNumber = false;
  String? _error;
  Map<String, dynamic>? _profile;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/profile/me') as Map<String, dynamic>;
    _profile = data;
    _contactController.text = (data['contact_phone'] as String?) ?? '';
    _useCustomNumber = _contactController.text.isNotEmpty;
    _emailController.text = (data['email'] as String?) ?? '';
    _bioController.text = (data['bio'] as String?) ?? '';
    _selectedSkills
      ..clear()
      ..addAll((data['worker_skills'] as List<dynamic>?)?.map((s) => s['skill'] as String) ?? const []);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      _reviews = await ApiClient(Config.apiBaseUrl).get('/profiles/$userId/reviews') as List<dynamic>;
    } catch (_) {
      // not critical — the reviews section just stays empty
    }
    return data;
  }

  @override
  void dispose() {
    _contactController.dispose();
    _emailController.dispose();
    _bioController.dispose();
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

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('logout_dialog_title')),
        content: Text(ctx.tr('logout_dialog_body')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(ctx.tr('cancel'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(ctx.tr('log_out'))),
        ],
      ),
    );
    if (confirmed != true) return;
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('delete_dialog_title')),
        content: Text(ctx.tr('delete_dialog_body')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(ctx.tr('cancel'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(ctx.tr('delete'))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient(Config.apiBaseUrl).post('/profile/delete');
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) showAppToast(context, apiErrorMessage(e), tone: ToastTone.error);
    }
  }

  Future<void> _save() async {
    if (_useCustomNumber && _contactController.text.trim().isEmpty) {
      showAppToast(context, context.tr('enter_number_or_toggle_off'), tone: ToastTone.error);
      return;
    }
    final profile = _profile!;
    final lang = context.lang;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiClient(Config.apiBaseUrl).post('/profile', {
        'role': profile['role'],
        'full_name': profile['full_name'],
        'phone': profile['phone'],
        'city': profile['city'],
        'lat': profile['lat'],
        'lng': profile['lng'],
        'contact_phone': _useCustomNumber && _contactController.text.trim().isNotEmpty ? _contactController.text.trim() : null,
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        'skills': _selectedSkills.toList(),
        'lang': lang.name,
      });
      if (!mounted) return;
      showAppToast(context, context.tr('profile_updated'));
      setState(() {
        _editing = false;
        _future = _load();
      });
    } catch (e) {
      setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      title: context.tr('profile_title'),
      scroll: true,
      resizeForKeyboard: true,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(color: c.accent));
          }
          if (snapshot.hasError) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ErrorStrip(errorMessage(context, snapshot.error!)),
                const SizedBox(height: AppSpacing.md),
                NeuButton(label: context.tr('retry'), expand: false, onPressed: () => setState(() { _future = _load(); })),
              ],
            );
          }
          final profile = snapshot.data!;
          final verified = profile['is_verified'] == true;
          final avgRating = _reviews.isEmpty
              ? null
              : _reviews.map((r) => (r as Map<String, dynamic>)['rating'] as int).reduce((a, b) => a + b) / _reviews.length;

          if (!_editing) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(profile['full_name'] as String? ?? '-', style: AppText.headline)),
                    if (verified) const PillBadge.verified(),
                  ],
                ),
                if (avgRating != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: c.accent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${avgRating.toStringAsFixed(1)} · ${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
                        style: AppText.bodySmall.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row(icon: Icons.phone_rounded, label: context.tr('login_number'), value: profile['phone'] as String? ?? '-'),
                      const SizedBox(height: AppSpacing.md),
                      _Row(
                        icon: Icons.call_outlined,
                        label: context.tr('number_shown_to_hires'),
                        value: (profile['contact_phone'] as String?) ?? context.tr('same_as_login_number'),
                      ),
                      if ((profile['email'] as String?)?.isNotEmpty ?? false) ...[
                        const SizedBox(height: AppSpacing.md),
                        _Row(icon: Icons.email_outlined, label: context.tr('email'), value: profile['email'] as String),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      _Row(icon: Icons.location_city_rounded, label: context.tr('city'), value: profile['city'] as String? ?? '-'),
                      if ((profile['bio'] as String?)?.isNotEmpty ?? false) ...[
                        const SizedBox(height: AppSpacing.md),
                        _Row(icon: Icons.info_outline_rounded, label: context.tr('about'), value: profile['bio'] as String),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(context.tr('skills')),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _selectedSkills.isEmpty
                      ? [Text(context.tr('no_skills_yet'), style: AppText.bodySmall.copyWith(color: c.textTertiary))]
                      : _selectedSkills.map((s) => Chip(label: Text(s))).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(context.tr('reviews')),
                if (_reviews.isEmpty)
                  Text(context.tr('no_reviews_yet'), style: AppText.bodySmall.copyWith(color: c.textTertiary))
                else
                  for (final r in _reviews.cast<Map<String, dynamic>>()) ...[
                    NeuCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < (r['rating'] as int) ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: c.accent,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                (r['reviewer'] as Map<String, dynamic>?)?['full_name'] as String? ?? '-',
                                style: AppText.bodySmall.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                          if ((r['comment'] as String?)?.isNotEmpty ?? false) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(r['comment'] as String, style: AppText.body),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                const SizedBox(height: AppSpacing.md),
                NeuButton(label: context.tr('edit_profile'), icon: Icons.edit_outlined, onPressed: () => setState(() => _editing = true)),
                const SizedBox(height: AppSpacing.md),
                NeuButton(label: context.tr('log_out'), icon: Icons.logout_rounded, variant: NeuButtonVariant.ghost, onPressed: _logout),
                const SizedBox(height: AppSpacing.md),
                NeuButton(
                  label: context.tr('delete_account'),
                  icon: Icons.delete_outline_rounded,
                  variant: NeuButtonVariant.danger,
                  onPressed: _deleteAccount,
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeuCard(
                child: Row(
                  children: [
                    Icon(Icons.translate_rounded, size: 20, color: c.textSecondary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(context.tr('app_language'), style: AppText.body)),
                    DropdownButton<Lang>(
                      value: context.lang,
                      dropdownColor: c.surfaceHigh,
                      underline: const SizedBox.shrink(),
                      items: Lang.values
                          .map((l) => DropdownMenuItem(value: l, child: Text(context.tr('language_${l.name}'))))
                          .toList(),
                      onChanged: (l) {
                        if (l != null) LangScope.controllerOf(context).setLang(l);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              NeuCard(
                child: Row(
                  children: [
                    Icon(Icons.call_outlined, size: 20, color: c.textSecondary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('share_different_number'), style: AppText.body),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('share_different_number_desc'),
                            style: AppText.bodySmall.copyWith(color: c.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _useCustomNumber,
                      activeThumbColor: c.accent,
                      onChanged: (v) => setState(() => _useCustomNumber = v),
                    ),
                  ],
                ),
              ),
              if (_useCustomNumber) ...[
                const SizedBox(height: AppSpacing.md),
                NeuTextField(
                  label: context.tr('number_to_show'),
                  controller: _contactController,
                  icon: Icons.phone_forwarded_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              NeuTextField(label: context.tr('email'), controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppSpacing.md),
              NeuTextField(label: context.tr('about'), controller: _bioController, icon: Icons.info_outline_rounded, maxLines: 3),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(context.tr('skills')),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: kSkillOptions
                    .map((skill) => FilterChip(
                          label: Text(skill),
                          selected: _selectedSkills.contains(skill),
                          onSelected: (selected) => setState(() {
                            selected ? _selectedSkills.add(skill) : _selectedSkills.remove(skill);
                          }),
                        ))
                    .toList(),
              ),
              if (_selectedSkills.any((s) => !kSkillOptions.contains(s))) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _selectedSkills
                      .where((s) => !kSkillOptions.contains(s))
                      .map((s) => Chip(label: Text(s), onDeleted: () => setState(() => _selectedSkills.remove(s))))
                      .toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                  NeuButton(label: context.tr('add'), expand: false, height: 48, radius: AppRadius.sm, onPressed: _addCustomSkill),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_error != null) ...[
                ErrorStrip(_error!),
                const SizedBox(height: AppSpacing.lg),
              ],
              Row(
                children: [
                  Expanded(
                    child: NeuButton(
                      label: context.tr('cancel'),
                      variant: NeuButtonVariant.ghost,
                      onPressed: () => setState(() => _editing = false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: NeuButton(label: context.tr('save'), loading: _saving, onPressed: _save)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: c.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: AppText.label.copyWith(color: c.textTertiary)),
              const SizedBox(height: 2),
              Text(value, style: AppText.body),
            ],
          ),
        ),
      ],
    );
  }
}
