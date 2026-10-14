import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Service responsible for matching emergency requests with the nearest available responders.
class MatchingService {
  /// Earth's radius in kilometers.
  static const double _earthRadiusKm = 6371.0;

  /// Calculate distance between two coordinates in kilometers using Haversine formula.
  static double calculateDistanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180.0;

  /// Attempt to match an emergency request with the optimal available responder.
  static Future<ResponderProfile?> findAndAssignBestResponder(
    Session session,
    EmergencyRequest emergency,
  ) async {
    // 1. Fetch available responders without an active emergency
    final candidates = await ResponderProfile.db.find(
      session,
      where: (t) =>
          t.isAvailable.equals(true) & t.activeEmergencyId.equals(null),
    );

    if (candidates.isEmpty) {
      session.log(
        'No available responders found for emergency #${emergency.id}',
      );
      return null;
    }

    // 2. Score and sort candidates:
    // Lowest score wins. Distance (km) + fairness penalty (less penalty if idle longer)
    ResponderProfile? bestCandidate;
    double bestScore = double.infinity;
    final now = DateTime.now();

    for (final candidate in candidates) {
      // Check capability match if emergency type is specific
      if (candidate.capabilities.isNotEmpty &&
          !candidate.capabilities.contains('all') &&
          !candidate.capabilities.toLowerCase().contains(
            emergency.type.toLowerCase(),
          )) {
        continue;
      }

      double distance = 5.0; // Default fallback distance if no GPS
      if (candidate.currentLat != null && candidate.currentLng != null) {
        distance = calculateDistanceKm(
          emergency.latitude,
          emergency.longitude,
          candidate.currentLat!,
          candidate.currentLng!,
        );
      }

      // Fairness penalty: responders who were assigned recently get slight de-prioritization
      double fairnessPenalty = 0.0;
      if (candidate.lastAssignedAt != null) {
        final minutesSinceLast = now
            .difference(candidate.lastAssignedAt!)
            .inMinutes;
        if (minutesSinceLast < 60) {
          fairnessPenalty =
              (60 - minutesSinceLast) * 0.1; // up to 6km equivalent penalty
        }
      }

      final score = distance + fairnessPenalty;
      if (score < bestScore) {
        bestScore = score;
        bestCandidate = candidate;
      }
    }

    if (bestCandidate == null) {
      return null;
    }

    // 3. Assign responder
    final updatedEmergency = emergency.copyWith(
      status: 'assigned',
      assignedResponderId: bestCandidate.id,
      updatedAt: DateTime.now(),
    );
    await EmergencyRequest.db.updateRow(session, updatedEmergency);

    final updatedResponder = bestCandidate.copyWith(
      activeEmergencyId: emergency.id,
      lastAssignedAt: DateTime.now(),
    );
    await ResponderProfile.db.updateRow(session, updatedResponder);

    // 4. Log status event
    final event = EmergencyStatusEvent(
      emergencyId: emergency.id!,
      status: 'assigned',
      actorId: bestCandidate.userProfileId,
      note: 'Auto-assigned to responder #${bestCandidate.id}',
      createdAt: DateTime.now(),
    );
    await EmergencyStatusEvent.db.insertRow(session, event);

    // 5. Notify responder and emergency subscribers via Serverpod MessageCentral
    await session.messages.postMessage(
      'responder_${bestCandidate.id}',
      updatedEmergency,
    );
    await session.messages.postMessage(
      'emergency_${emergency.id}',
      updatedEmergency,
    );
    await session.messages.postMessage(
      'emergency_feed',
      updatedEmergency,
    );

    session.log(
      'Successfully matched Emergency #${emergency.id} with Responder #${bestCandidate.id} (score: ${bestScore.toStringAsFixed(2)})',
    );

    return updatedResponder;
  }
}
