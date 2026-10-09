import 'package:geolocator/geolocator.dart';

/// Checks permission/service state explicitly (instead of letting
/// getCurrentPosition silently hang) and times out instead of waiting forever
/// for a GPS fix that may never arrive indoors/on an emulator.
Future<Position> getCurrentPositionOrThrow() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw Exception('Location services are off. Turn on location and try again.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    throw Exception('Location permission denied. Allow location access in app settings.');
  }

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 15)),
  );
}
