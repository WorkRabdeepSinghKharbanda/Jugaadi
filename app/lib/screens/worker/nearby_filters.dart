import 'package:flutter/material.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/widgets.dart';
import '../auth/profile_setup_screen.dart';

const kRadiiKm = [5, 10, 25, 50];

/// What the worker is filtering/sorting the nearby list by. Defaults = no filter.
class NearbyFilters {
  const NearbyFilters({this.skill, this.minPay, this.sort = 'nearest', this.radiusKm = 5});

  final String? skill;
  final int? minPay;
  final String sort; // 'nearest' | 'pay'
  final int radiusKm;

  bool get isActive => skill != null || minPay != null || sort != 'nearest' || radiusKm != 5;

  Map<String, dynamic> toQuery() => {
        'radius': radiusKm * 1000,
        'sort': sort,
        if (skill != null) 'skill': skill,
        if (minPay != null) 'min_wage': minPay,
      };
}

Future<NearbyFilters?> showNearbyFiltersSheet(BuildContext context, NearbyFilters current) {
  return showModalBottomSheet<NearbyFilters>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _FiltersSheet(current: current),
  );
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.current});
  final NearbyFilters current;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String? _skill = widget.current.skill;
  late String _sort = widget.current.sort;
  late int _radius = widget.current.radiusKm;
  late final _pay = TextEditingController(text: widget.current.minPay?.toString());

  @override
  void dispose() {
    _pay.dispose();
    super.dispose();
  }

  Widget _chips<T>(List<T> values, T selected, String Function(T) label, ValueChanged<T> onPick) {
    final c = context.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(label(v)),
            selected: v == selected,
            selectedColor: c.accent,
            labelStyle: AppText.bodySmall.copyWith(color: v == selected ? c.onAccent : c.textPrimary),
            onSelected: (_) => setState(() => onPick(v)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.lg),
        decoration: BoxDecoration(color: c.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: AppSpacing.lg), decoration: BoxDecoration(color: c.outline, borderRadius: BorderRadius.circular(2)))),
              Text(context.tr('filters'), style: AppText.title),
              const SizedBox(height: AppSpacing.lg),
              Text(context.tr('sort_by'), style: AppText.bodySmall.copyWith(color: c.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              _chips<String>(['nearest', 'pay'], _sort, (v) => context.tr(v == 'pay' ? 'sort_pay' : 'sort_nearest'), (v) => _sort = v),
              const SizedBox(height: AppSpacing.lg),
              Text(context.tr('search_radius'), style: AppText.bodySmall.copyWith(color: c.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              _chips<int>(kRadiiKm, _radius, (v) => '$v km', (v) => _radius = v),
              const SizedBox(height: AppSpacing.lg),
              Text(context.tr('filter_skill'), style: AppText.bodySmall.copyWith(color: c.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              _chips<String?>([null, ...kSkillOptions], _skill, (v) => v ?? context.tr('any_skill'), (v) => _skill = v),
              const SizedBox(height: AppSpacing.lg),
              NeuTextField(label: context.tr('min_pay'), controller: _pay, keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.lg),
              NeuButton(
                label: context.tr('apply_filters'),
                onPressed: () => Navigator.of(context).pop(NearbyFilters(skill: _skill, minPay: int.tryParse(_pay.text.trim()), sort: _sort, radiusKm: _radius)),
              ),
              const SizedBox(height: AppSpacing.sm),
              NeuButton(label: context.tr('clear_filters'), variant: NeuButtonVariant.ghost, onPressed: () => Navigator.of(context).pop(const NearbyFilters())),
            ],
          ),
        ),
      ),
    );
  }
}
