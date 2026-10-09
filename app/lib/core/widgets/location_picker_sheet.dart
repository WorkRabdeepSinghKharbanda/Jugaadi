import 'package:flutter/material.dart';
import '../location.dart';
import '../services/place_gateway.dart';
import '../theme/tokens.dart';
import 'error_strip.dart';
import 'neu_button.dart';
import 'neu_text_field.dart';

/// Bottom sheet to pick a location: current GPS fix, or a searched place/landmark.
/// Returns the chosen [PlaceHit], or null if dismissed without picking.
class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  static Future<PlaceHit?> show(BuildContext context) {
    return showModalBottomSheet<PlaceHit>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LocationPickerSheet(),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  static const _places = PlaceGateway();
  final _query = TextEditingController();
  List<PlaceHit> _hits = const [];
  String? _error;
  bool _busyGps = false;
  bool _busySearch = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _useCurrent() async {
    setState(() {
      _busyGps = true;
      _error = null;
    });
    try {
      final position = await getCurrentPositionOrThrow();
      final label = await _places.labelFor(position.latitude, position.longitude);
      if (!mounted) return;
      Navigator.of(context).pop(PlaceHit(label: label, latitude: position.latitude, longitude: position.longitude));
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busyGps = false);
    }
  }

  Future<void> _search() async {
    final q = _query.text.trim();
    if (q.length < 3) {
      setState(() => _error = 'Type at least 3 letters of the place or landmark.');
      return;
    }
    setState(() {
      _busySearch = true;
      _error = null;
      _hits = const [];
    });
    final hits = await _places.search(q);
    if (!mounted) return;
    setState(() {
      _busySearch = false;
      _hits = hits;
      _error = hits.isEmpty ? 'No place found. Try a nearby landmark or area name.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.lg),
        decoration: BoxDecoration(color: c.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: AppSpacing.lg), decoration: BoxDecoration(color: c.outline, borderRadius: BorderRadius.circular(2))),
            ),
            Text('Set your location', style: AppText.title),
            const SizedBox(height: AppSpacing.lg),
            NeuButton(label: 'Use my current location', icon: Icons.gps_fixed_rounded, variant: NeuButtonVariant.ghost, height: 48, loading: _busyGps, onPressed: _useCurrent),
            const SizedBox(height: AppSpacing.md),
            NeuTextField(label: 'Search place or landmark', hint: 'e.g. Connaught Place, Delhi', icon: Icons.search_rounded, controller: _query, onSubmitted: (_) => _search()),
            const SizedBox(height: AppSpacing.sm),
            NeuButton(label: 'Search', icon: Icons.search_rounded, variant: NeuButtonVariant.ghost, height: 48, loading: _busySearch, onPressed: _search),
            for (final h in _hits)
              InkWell(
                onTap: () => Navigator.of(context).pop(h),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(h.label, style: AppText.body.copyWith(color: c.accent)),
                ),
              ),
            if (_error != null) ...[const SizedBox(height: AppSpacing.sm), ErrorStrip(_error!)],
          ],
        ),
      ),
    );
  }
}
