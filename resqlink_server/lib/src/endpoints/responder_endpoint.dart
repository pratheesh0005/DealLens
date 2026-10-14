import 'package:serverpod/serverpod.dart';
import '../business/matching_service.dart';
import '../generated/protocol.dart';

/// Endpoint for first responder actions, availability, location, and assignment workflow.
class ResponderEndpoint extends Endpoint {
  /// Register or update responder profile.
  Future<ResponderProfile> registerOrUpdateResponder(
    Session session, {
    required int userProfileId,
    required String capabilities,
    required bool isAvailable,
  }) async {
    // Validate that the user exists and has role=responder
    final userProfile = await UserProfile.db.findById(session, userProfileId);
    if (userProfile == null || userProfile.role != 'responder') {
      throw ArgumentError(
        'UserProfile #$userProfileId is not a registered responder.',
      );
    }

    final existing = await ResponderProfile.db.findFirstRow(
      session,
      where: (t) => t.userProfileId.equals(userProfileId),
    );

    if (existing != null) {
      final updated = existing.copyWith(
        capabilities: capabilities,
        isAvailable: isAvailable,
      );
      return await ResponderProfile.db.updateRow(session, updated);
    } else {
      final newResponder = ResponderProfile(
        userProfileId: userProfileId,
        isAvailable: isAvailable,
        capabilities: capabilities,
        totalResponseCount: 0,
      );
      return await ResponderProfile.db.insertRow(session, newResponder);
    }
  }

  /// Update responder's live GPS coordinates.
  Future<bool> updateLocation(
    Session session, {
    required int responderId,
    required double lat,
    required double lng,
  }) async {
    final responder = await ResponderProfile.db.findById(session, responderId);
    if (responder == null) return false;

    final updated = responder.copyWith(
      currentLat: lat,
      currentLng: lng,
      lastLocationUpdate: DateTime.now(),
    );
    await ResponderProfile.db.updateRow(session, updated);
    return true;
  }

  /// Toggle availability (on duty / off duty).
  Future<ResponderProfile?> updateAvailability(
    Session session, {
    required int responderId,
    required bool isAvailable,
  }) async {
    final responder = await ResponderProfile.db.findById(session, responderId);
    if (responder == null) return null;

    final updated = responder.copyWith(isAvailable: isAvailable);
    return await ResponderProfile.db.updateRow(session, updated);
  }

  /// Get responder profile by user profile ID.
  Future<ResponderProfile?> getResponderByUserProfileId(
    Session session,
    int userProfileId,
  ) async {
    return await ResponderProfile.db.findFirstRow(
      session,
      where: (t) => t.userProfileId.equals(userProfileId),
    );
  }

  /// Get responder profile by ID.
  Future<ResponderProfile?> getResponderById(
    Session session,
    int responderId,
  ) async {
    return await ResponderProfile.db.findById(session, responderId);
  }

  /// Get the current authenticated responder's profile.
  Future<ResponderProfile?> getMyResponderProfile(Session session) async {
    final auth = session.authenticated;
    if (auth == null) return null;
    final userId = int.tryParse(auth.userIdentifier);
    if (userId == null) return null;
    final userProfile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    if (userProfile == null) return null;
    return await ResponderProfile.db.findFirstRow(
      session,
      where: (t) => t.userProfileId.equals(userProfile.id!),
    );
  }

  /// Accept an assigned emergency.
  Future<EmergencyRequest> acceptEmergency(
    Session session, {
    required int responderId,
    required int emergencyId,
  }) async {
    final emergency = await EmergencyRequest.db.findById(session, emergencyId);
    if (emergency == null) {
      throw ArgumentError('Emergency #$emergencyId not found.');
    }

    final updated = emergency.copyWith(
      status: 'accepted',
      acceptedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await EmergencyRequest.db.updateRow(session, updated);

    // Audit log
    await EmergencyStatusEvent.db.insertRow(
      session,
      EmergencyStatusEvent(
        emergencyId: emergencyId,
        status: 'accepted',
        actorId: responderId,
        note: 'Responder accepted emergency assignment.',
        createdAt: DateTime.now(),
      ),
    );

    // Broadcast to real-time streams
    await session.messages.postMessage('emergency_$emergencyId', updated);
    await session.messages.postMessage('emergency_feed', updated);
    await session.messages.postMessage('responder_$responderId', updated);

    return updated;
  }

  /// Decline an assigned emergency so it can be re-routed.
  Future<EmergencyRequest> declineEmergency(
    Session session, {
    required int responderId,
    required int emergencyId,
    required String reason,
  }) async {
    final emergency = await EmergencyRequest.db.findById(session, emergencyId);
    if (emergency == null) {
      throw ArgumentError('Emergency #$emergencyId not found.');
    }

    // Unassign responder
    final responder = await ResponderProfile.db.findById(session, responderId);
    if (responder != null && responder.activeEmergencyId == emergencyId) {
      await ResponderProfile.db.updateRow(
        session,
        responder.copyWith(activeEmergencyId: null),
      );
    }

    // Set emergency back to matching
    final updated = emergency.copyWith(
      status: 'matching',
      assignedResponderId: null,
      matchingRetryCount: emergency.matchingRetryCount + 1,
      updatedAt: DateTime.now(),
    );
    await EmergencyRequest.db.updateRow(session, updated);

    // Audit log
    await EmergencyStatusEvent.db.insertRow(
      session,
      EmergencyStatusEvent(
        emergencyId: emergencyId,
        status: 'matching',
        actorId: responderId,
        note: 'Declined by responder #$responderId: $reason',
        createdAt: DateTime.now(),
      ),
    );

    // Re-run matching algorithm
    await MatchingService.findAndAssignBestResponder(session, updated);

    await session.messages.postMessage('emergency_$emergencyId', updated);
    await session.messages.postMessage('emergency_feed', updated);

    return updated;
  }

  /// Update lifecycle status: enRoute | arrived | resolved.
  Future<EmergencyRequest> updateEmergencyStatus(
    Session session, {
    required int responderId,
    required int emergencyId,
    required String newStatus,
    String? note,
  }) async {
    final validStatuses = ['enRoute', 'arrived', 'resolved'];
    if (!validStatuses.contains(newStatus)) {
      throw ArgumentError('Invalid status transition to: $newStatus');
    }

    final emergency = await EmergencyRequest.db.findById(session, emergencyId);
    if (emergency == null) {
      throw ArgumentError('Emergency #$emergencyId not found.');
    }

    final now = DateTime.now();
    var updated = emergency.copyWith(
      status: newStatus,
      updatedAt: now,
      arrivedAt: newStatus == 'arrived' ? now : emergency.arrivedAt,
      resolvedAt: newStatus == 'resolved' ? now : emergency.resolvedAt,
    );

    await EmergencyRequest.db.updateRow(session, updated);

    // If resolved, clear responder's activeEmergencyId and increment count
    if (newStatus == 'resolved') {
      final responder = await ResponderProfile.db.findById(
        session,
        responderId,
      );
      if (responder != null) {
        await ResponderProfile.db.updateRow(
          session,
          responder.copyWith(
            activeEmergencyId: null,
            totalResponseCount: responder.totalResponseCount + 1,
          ),
        );
      }
    }

    // Audit log
    await EmergencyStatusEvent.db.insertRow(
      session,
      EmergencyStatusEvent(
        emergencyId: emergencyId,
        status: newStatus,
        actorId: responderId,
        note: note ?? 'Status updated to $newStatus',
        createdAt: now,
      ),
    );

    // Broadcast
    await session.messages.postMessage('emergency_$emergencyId', updated);
    await session.messages.postMessage('emergency_feed', updated);
    await session.messages.postMessage('responder_$responderId', updated);

    return updated;
  }

  /// Real-time stream of assignments and updates for this responder.
  Stream<EmergencyRequest> streamAssignments(
    Session session,
    int responderId,
  ) {
    return session.messages.createStream<EmergencyRequest>(
      'responder_$responderId',
    );
  }
}
