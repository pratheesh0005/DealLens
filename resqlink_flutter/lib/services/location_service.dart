import 'package:geolocator/geolocator.dart';

/// Result representing GPS acquisition status and coordinates.
class LocationResult {
  final double? latitude;
  final double? longitude;
  final bool isSuccess;
  final String? errorMessage;
  final bool isServiceDisabled;
  final bool isPermissionDenied;

  const LocationResult({
    this.latitude,
    this.longitude,
    required this.isSuccess,
    this.errorMessage,
    this.isServiceDisabled = false,
    this.isPermissionDenied = false,
  });

  factory LocationResult.success(double lat, double lng) => LocationResult(
    latitude: lat,
    longitude: lng,
    isSuccess: true,
  );

  factory LocationResult.failure(
    String message, {
    bool serviceDisabled = false,
    bool permissionDenied = false,
  }) => LocationResult(
    isSuccess: false,
    errorMessage: message,
    isServiceDisabled: serviceDisabled,
    isPermissionDenied: permissionDenied,
  );
}

/// Service for querying physical GPS sensor telemetry.
class LocationService {
  /// Get real device coordinates from physical GPS.
  static Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure(
          'Location services (GPS) are disabled on your phone. Please turn on GPS.',
          serviceDisabled: true,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.failure(
            'Location permission was denied. Please allow location access to dispatch emergency aid.',
            permissionDenied: true,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure(
          'Location permission is permanently denied. Please grant location permissions in App Settings.',
          permissionDenied: true,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationResult.success(position.latitude, position.longitude);
    } catch (e) {
      return LocationResult.failure('Failed to acquire GPS: $e');
    }
  }

  /// Open device location settings.
  static Future<void> openSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings if permanently denied.
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
