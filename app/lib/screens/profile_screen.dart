import 'package:flutter/material.dart';
import '../api_client.dart';
import '../config.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/widgets.dart';
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
  final _bioController = TextEditingController();
  final _selectedSkills = <String>{};
  bool _saving = false;
  String? _error;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final data = await ApiClient(Config.apiBaseUrl).get('/profile/me') as Map<String, dynamic>;
    _profile = data;
    _contactController.text = (data['contact_phone'] as String?) ?? '';
    _bioController.text = (data['bio'] as String?) ?? '';
    _selectedSkills
      ..clear()
      ..addAll((data['worker_skills'] as List<dynamic>?)?.map((s) => s['skill'] as String) ?? const []);
    return data;
  }

  @override
  void dispose() {
    _contactController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final profile = _profile!;
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
        'contact_phone': _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        if (profile['role'] == 'worker') 'skills': _selectedSkills.toList(),
      });
      if (!mounted) return;
      showAppToast(context, 'Profile updated');
      setState(() {
        _editing = false;
        _future = _load();
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      onBack: () => Navigator.of(context).pop(),
      title: 'Profile',
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
                ErrorStrip('${snapshot.error}'),
                const SizedBox(height: AppSpacing.md),
                NeuButton(label: 'Retry', expand: false, onPressed: () => setState(() => _future = _load())),
              ],
            );
          }
          final profile = snapshot.data!;
          final isWorker = profile['role'] == 'worker';
          final verified = profile['is_verified'] == true;

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
                const SizedBox(height: AppSpacing.lg),
                NeuCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row(icon: Icons.phone_rounded, label: 'Login number', value: profile['phone'] as String? ?? '-'),
                      const SizedBox(height: AppSpacing.md),
                      _Row(
                        icon: Icons.call_outlined,
                        label: 'Contact number',
                        value: (profile['contact_phone'] as String?) ?? 'Same as login number',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Row(icon: Icons.location_city_rounded, label: 'City', value: profile['city'] as String? ?? '-'),
                      if ((profile['bio'] as String?)?.isNotEmpty ?? false) ...[
                        const SizedBox(height: AppSpacing.md),
                        _Row(icon: Icons.info_outline_rounded, label: 'About', value: profile['bio'] as String),
                      ],
                    ],
                  ),
                ),
                if (isWorker) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader('Skills'),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _selectedSkills.isEmpty
                        ? [Text('No skills added yet', style: AppText.bodySmall.copyWith(color: c.textTertiary))]
                        : _selectedSkills.map((s) => Chip(label: Text(s))).toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                NeuButton(label: 'Edit profile', icon: Icons.edit_outlined, onPressed: () => setState(() => _editing = true)),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeuTextField(
                label: 'Contact number',
                controller: _contactController,
                hint: 'Leave empty to use your login number',
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              NeuTextField(label: 'About', controller: _bioController, icon: Icons.info_outline_rounded, maxLines: 3),
              if (isWorker) ...[
                const SizedBox(height: AppSpacing.lg),
                SectionHeader('Skills'),
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
              ],
              const SizedBox(height: AppSpacing.lg),
              if (_error != null) ...[
                ErrorStrip(_error!),
                const SizedBox(height: AppSpacing.lg),
              ],
              Row(
                children: [
                  Expanded(
                    child: NeuButton(
                      label: 'Cancel',
                      variant: NeuButtonVariant.ghost,
                      onPressed: () => setState(() => _editing = false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: NeuButton(label: 'Save', loading: _saving, onPressed: _save)),
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
