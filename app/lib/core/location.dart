import 'package:geolocator/geolocator.dart';

/// [key] is a strings.dart translation key, so the UI can show it in the user's language.
class LocationException implements Exception {
  const LocationException(this.key);
  final String key;
  @override
  String toString() => key;
}

/// Checks permission/service state explicitly (instead of letting
/// getCurrentPosition silently hang) and times out instead of waiting forever
/// for a GPS fix that may never arrive indoors/on an emulator.
Future<Position> getCurrentPositionOrThrow() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const LocationException('location_services_off');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw const LocationException('location_permission_denied');
  }

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 15),
    ),
  );
}
