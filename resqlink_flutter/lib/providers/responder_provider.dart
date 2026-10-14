import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:resqlink_client/resqlink_client.dart';
import '../client.dart';
import '../services/location_service.dart';

class ResponderProvider extends ChangeNotifier {
  ResponderProfile? _profile;
  EmergencyRequest? _assignedEmergency;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<EmergencyRequest>? _assignmentSub;
  Timer? _locationTimer;

  ResponderProfile? get profile => _profile;
  EmergencyRequest? get assignedEmergency => _assignedEmergency;
  bool get isAvailable => _profile?.isAvailable ?? false;
  bool get hasActiveAssignment => _assignedEmergency != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize responder state and start live streams.
  Future<void> init(ResponderProfile? responder) async {
    _profile = responder;
    if (responder != null && responder.id != null) {
      _startAssignmentStream(responder.id!);
      _startPeriodicLocationBroadcast(responder.id!);
      await fetchAssignedEmergency(responder);
    }
  }

  /// Toggle on/off duty availability.
  Future<void> toggleAvailability() async {
    if (_profile == null || _profile!.id == null) return;

    final newStatus = !_profile!.isAvailable;
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await client.responder.updateAvailability(
        responderId: _profile!.id!,
        isAvailable: newStatus,
      );
      if (updated != null) {
        _profile = updated;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Broadcast real GPS location to server.
  Future<void> sendLocationUpdate() async {
    if (_profile == null || _profile!.id == null) return;

    final locResult = await LocationService.getCurrentLocation();
    if (!locResult.isSuccess || locResult.latitude == null) {
      debugPrint('Location ping skipped: ${locResult.errorMessage}');
      return;
    }

    try {
      await client.responder.updateLocation(
        responderId: _profile!.id!,
        lat: locResult.latitude!,
        lng: locResult.longitude!,
      );
    } catch (e) {
      debugPrint('Failed to send location update: $e');
    }
  }

  /// Fetch active emergency if any assigned.
  Future<void> fetchAssignedEmergency(ResponderProfile responder) async {
    if (responder.activeEmergencyId == null) {
      _assignedEmergency = null;
      notifyListeners();
      return;
    }

    try {
      final emergency = await client.emergency.getEmergency(
        responder.activeEmergencyId!,
      );
      _assignedEmergency = emergency;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching assigned emergency: $e');
    }
  }

  /// Accept incoming dispatch.
  Future<bool> acceptEmergency() async {
    if (_profile == null || _assignedEmergency == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updated = await client.responder.acceptEmergency(
        responderId: _profile!.id!,
        emergencyId: _assignedEmergency!.id!,
      );
      _assignedEmergency = updated;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Decline dispatch with reason.
  Future<bool> declineEmergency(String reason) async {
    if (_profile == null || _assignedEmergency == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await client.responder.declineEmergency(
        responderId: _profile!.id!,
        emergencyId: _assignedEmergency!.id!,
        reason: reason,
      );
      _assignedEmergency = null;
      _profile = _profile!.copyWith(activeEmergencyId: null);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Transition emergency stage (enRoute -> arrived -> resolved).
  Future<bool> advanceStatus(String newStatus, {String? note}) async {
    if (_profile == null || _assignedEmergency == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updated = await client.responder.updateEmergencyStatus(
        responderId: _profile!.id!,
        emergencyId: _assignedEmergency!.id!,
        newStatus: newStatus,
        note: note,
      );
      _assignedEmergency = newStatus == 'resolved' ? null : updated;
      if (newStatus == 'resolved') {
        _profile = _profile!.copyWith(
          activeEmergencyId: null,
          totalResponseCount: _profile!.totalResponseCount + 1,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startAssignmentStream(int responderId) {
    _assignmentSub?.cancel();
    try {
      _assignmentSub = client.responder
          .streamAssignments(responderId)
          .listen(
            (emergency) {
              _assignedEmergency = emergency;
              if (_profile != null &&
                  _profile!.activeEmergencyId != emergency.id) {
                _profile = _profile!.copyWith(activeEmergencyId: emergency.id);
              }
              notifyListeners();
            },
            onError: (err) {
              debugPrint('Responder assignment stream error: $err');
            },
          );
    } catch (e) {
      debugPrint('Failed to connect assignment stream: $e');
    }
  }

  void _startPeriodicLocationBroadcast(int responderId) {
    _locationTimer?.cancel();
    sendLocationUpdate();
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      sendLocationUpdate();
    });
  }

  @override
  void dispose() {
    _assignmentSub?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }
}
