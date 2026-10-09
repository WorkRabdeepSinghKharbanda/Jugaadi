import 'package:flutter/material.dart';
import '../api_client.dart';
import '../config.dart';
import 'widgets/widgets.dart';

/// Opens the location picker and, if the user picks a place, re-submits the
/// full profile with the new lat/lng/city — POST /profile upserts, so every
/// other field (name, phone, role, skills) must come along unchanged.
Future<void> editLocation(BuildContext context) async {
  final place = await LocationPickerSheet.show(context);
  if (place == null || !context.mounted) return;

  try {
    final api = ApiClient(Config.apiBaseUrl);
    final profile = await api.get('/profile/me') as Map<String, dynamic>;
    final skills = (profile['worker_skills'] as List<dynamic>?)?.map((s) => s['skill'] as String).toList();

    await api.post('/profile', {
      'role': profile['role'],
      'full_name': profile['full_name'],
      'phone': profile['phone'],
      'city': place.label,
      'lat': place.latitude,
      'lng': place.longitude,
      if (profile['role'] == 'worker') 'skills': skills ?? const [],
    });

    if (context.mounted) showAppToast(context, 'Location updated');
  } catch (e) {
    if (context.mounted) showAppToast(context, '$e', tone: ToastTone.error);
  }
}
