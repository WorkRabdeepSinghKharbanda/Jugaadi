import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api_client.dart';
import '../config.dart';

/// Picks up to [remaining] images, uploads each via a backend-issued signed
/// upload URL (service-role key never touches the client), then confirms each
/// with the backend so it lands in jobs.photo_urls. Returns the new public URLs.
Future<List<String>> pickAndUploadJobPhotos(String jobId, {required int remaining}) async {
  if (remaining <= 0) return const [];
  final picked = await ImagePicker().pickMultiImage(limit: remaining);
  if (picked.isEmpty) return const [];

  final api = ApiClient(Config.apiBaseUrl);
  final urls = <String>[];
  for (final image in picked.take(remaining)) {
    final ext = image.path.split('.').last.toLowerCase();
    final upload = await api.post('/jobs/$jobId/photos/upload-url', {'ext': ext}) as Map<String, dynamic>;
    final path = upload['path'] as String;
    final token = upload['token'] as String;
    final publicUrl = upload['publicUrl'] as String;

    await Supabase.instance.client.storage.from('job-photos').uploadToSignedUrl(path, token, File(image.path));
    await api.post('/jobs/$jobId/photos', {'photo_url': publicUrl});
    urls.add(publicUrl);
  }
  return urls;
}
