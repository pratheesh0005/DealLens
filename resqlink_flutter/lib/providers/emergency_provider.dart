import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:resqlink_client/resqlink_client.dart';
import '../client.dart';
import '../services/location_service.dart';

class EmergencyProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  EmergencyRequest? _activeEmergency;
  List<EmergencyStatusEvent> _activeTimeline = [];
  List<EmergencyRequest> _myEmergencies = [];
  final List<EmergencyRequest> _liveFeed = [];

  bool _isCreating = false;
  bool _isLoadingHistory = false;
  String? _errorMessage;

  StreamSubscription<EmergencyRequest>? _activeEmergencySub;
  StreamSubscription<EmergencyRequest>? _feedSub;

  EmergencyRequest? get activeEmergency => _activeEmergency;
  List<EmergencyStatusEvent> get activeTimeline => _activeTimeline;
  List<EmergencyRequest> get myEmergencies => _myEmergencies;
  List<EmergencyRequest> get liveFeed => _liveFeed;
  bool get isCreating => _isCreating;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorMessage => _errorMessage;

  /// Start global emergency feed subscription for live radar/ticker.
  void listenToLiveFeed() {
    _feedSub?.cancel();
    try {
      _feedSub = client.emergency.streamEmergencyFeed().listen(
        (emergency) {
          final index = _liveFeed.indexWhere((e) => e.id == emergency.id);
          if (index != -1) {
            _liveFeed[index] = emergency;
          } else {
            _liveFeed.insert(0, emergency);
          }
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Live feed stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('Failed to start live feed stream: $e');
    }
  }

  /// Create and dispatch a new emergency request with real GPS and Serverpod backend.
  Future<EmergencyRequest?> reportEmergency({
    required String type,
    required String description,
    required String priority,
    double? latitude,
    double? longitude,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      double lat;
      double lng;

      if (latitude != null && longitude != null) {
        lat = latitude;
        lng = longitude;
      } else {
        // Query physical GPS
        final locResult = await LocationService.getCurrentLocation();
        if (!locResult.isSuccess) {
          _errorMessage =
              locResult.errorMessage ?? 'Unable to acquire GPS coordinates.';
          notifyListeners();
          return null;
        }
        lat = locResult.latitude!;
        lng = locResult.longitude!;
      }

      // Build request with UUID idempotency key
      final request = EmergencyRequest(
        requesterId: 0, // Assigned server-side by authenticated session
        type: type,
        description: description,
        latitude: lat,
        longitude: lng,
        priority: priority,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        idempotencyKey: _uuid.v4(),
        matchingRetryCount: 0,
      );

      // Dispatch to Serverpod backend
      final created = await client.emergency.createEmergency(request);
      _activeEmergency = created;

      // Subscribe to real-time status updates for this emergency
      subscribeToEmergency(created.id!);
      await fetchTimeline(created.id!);
      await fetchMyEmergencies();

      return created;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Error reporting emergency: $e');
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Subscribe to real-time status updates for an active emergency.
  void subscribeToEmergency(int emergencyId) {
    _activeEmergencySub?.cancel();
    try {
      _activeEmergencySub = client.emergency
          .streamEmergency(emergencyId)
          .listen(
            (updated) {
              _activeEmergency = updated;
              fetchTimeline(emergencyId);
              notifyListeners();
            },
            onError: (err) {
              debugPrint('Emergency stream error: $err');
            },
          );
    } catch (e) {
      debugPrint('Failed to stream emergency: $e');
    }
  }

  /// Fetch chronological timeline events.
  Future<void> fetchTimeline(int emergencyId) async {
    try {
      final events = await client.emergency.getStatusEvents(emergencyId);
      _activeTimeline = events;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching timeline: $e');
    }
  }

  /// Fetch all emergencies created by the authenticated citizen.
  Future<void> fetchMyEmergencies() async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final list = await client.emergency.getMyEmergencies();
      _myEmergencies = list;
    } catch (e) {
      debugPrint('Error fetching my emergencies: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Cancel active emergency.
  Future<bool> cancelActiveEmergency(String reason) async {
    if (_activeEmergency == null) return false;

    try {
      final cancelled = await client.emergency.cancelEmergency(
        emergencyId: _activeEmergency!.id!,
        reason: reason,
      );
      _activeEmergency = cancelled;
      await fetchTimeline(cancelled.id!);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Clear active tracking view.
  void clearActiveEmergency() {
    _activeEmergencySub?.cancel();
    _activeEmergencySub = null;
    _activeEmergency = null;
    _activeTimeline = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _activeEmergencySub?.cancel();
    _feedSub?.cancel();
    super.dispose();
  }
}
