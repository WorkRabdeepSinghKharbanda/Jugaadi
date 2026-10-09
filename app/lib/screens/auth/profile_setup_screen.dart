import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../config.dart';
import '../../core/services/place_gateway.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../../main.dart';

const kSkillOptions = ['loading-unloading', 'helper', 'cleaning', 'cook', 'delivery', 'packing'];

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, required this.role});

  final String role;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _selectedSkills = <String>{};
  PlaceHit? _place;
  bool _loading = false;
  String? _error;

  Future<void> _pickLocation() async {
    final place = await LocationPickerSheet.show(context);
    if (place != null && mounted) setState(() => _place = place);
  }

  Future<void> _save() async {
    if (_place == null) {
      setState(() => _error = 'Set your location first');
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
        if (widget.role == 'worker') 'skills': _selectedSkills.toList(),
      });

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootRouter()),
        (route) => false,
      );
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
      title: 'Set up your profile',
      scroll: true,
      resizeForKeyboard: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeuTextField(label: 'Full name', controller: _nameController, icon: Icons.person_outline_rounded),
          const SizedBox(height: AppSpacing.md),
          NeuTextField(label: 'Phone', controller: _phoneController, icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
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
                    _place?.label ?? 'Tap to set your location',
                    style: AppText.body.copyWith(color: _place == null ? c.textTertiary : c.textPrimary),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.textTertiary),
              ],
            ),
          ),
          if (widget.role == 'worker') ...[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader('Your skills'),
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
          NeuButton(label: 'Continue', icon: Icons.arrow_forward_rounded, loading: _loading, onPressed: _save),
        ],
      ),
    );
  }
}
