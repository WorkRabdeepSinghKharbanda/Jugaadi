import 'package:geocoding/geocoding.dart';

/// A resolved place: a label plus coordinates, either from search or GPS.
class PlaceHit {
  const PlaceHit({required this.label, required this.latitude, required this.longitude});
  final String label;
  final double latitude;
  final double longitude;
}

/// Thin seam over the platform geocoder (Google on Android, Apple on iOS) —
/// no API key, no paid service. Typed text goes only to the OS geocoder.
class PlaceGateway {
  const PlaceGateway({this.timeout = const Duration(seconds: 6)});
  final Duration timeout;

  /// Up to 5 matches; returns [] when nothing matches or the geocoder fails.
  Future<List<PlaceHit>> search(String query) async {
    final List<Location> locs;
    try {
      locs = await Geocoding().locationFromAddress(query).timeout(timeout);
    } catch (_) {
      return const [];
    }
    final hits = <PlaceHit>[];
    for (final l in locs.take(5)) {
      hits.add(PlaceHit(label: await labelFor(l.latitude, l.longitude, fallback: query), latitude: l.latitude, longitude: l.longitude));
    }
    return hits;
  }

  /// "Locality, Administrative area" for coordinates, else [fallback]. Never throws.
  Future<String> labelFor(double lat, double lng, {String? fallback}) async {
    try {
      final marks = await Geocoding().placemarkFromCoordinates(lat, lng).timeout(const Duration(seconds: 3));
      if (marks.isNotEmpty) {
        final m = marks.first;
        final parts = [m.locality, m.administrativeArea].where((s) => s != null && s.isNotEmpty);
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // fall through to fallback below
    }
    return fallback ?? '$lat, $lng';
  }
}
