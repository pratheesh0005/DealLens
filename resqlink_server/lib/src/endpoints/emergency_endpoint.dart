import 'package:serverpod/serverpod.dart';
import '../business/matching_service.dart';
import '../generated/protocol.dart';

/// Endpoint for emergency creation, cancellation, status tracking, and live streams.
class EmergencyEndpoint extends Endpoint {
  /// Create a new emergency request with idempotency protection and trigger matching.
  Future<EmergencyRequest> createEmergency(
    Session session,
    EmergencyRequest request,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw StateError(
        'Authentication required. Please sign in before reporting an emergency.',
      );
    }
    final requesterId = int.parse(auth.userIdentifier);

    // 1. Idempotency check
    if (request.idempotencyKey.isNotEmpty) {
      final existing = await EmergencyRequest.db.findFirstRow(
        session,
        where: (t) => t.idempotencyKey.equals(request.idempotencyKey),
      );
      if (existing != null) {
        session.log(
          'Duplicate emergency submission detected for idempotencyKey: ${request.idempotencyKey}',
        );
        return existing;
      }
    }

    final now = DateTime.now();
    final newEmergency = request.copyWith(
      requesterId: requesterId,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
      matchingRetryCount: 0,
    );

    // 2. Insert into database
    final created = await EmergencyRequest.db.insertRow(session, newEmergency);

    // 3. Create audit trail event
    await EmergencyStatusEvent.db.insertRow(
      session,
      EmergencyStatusEvent(
        emergencyId: created.id!,
        status: 'pending',
        actorId: requesterId,
        note: 'Emergency reported: ${created.type} (${created.priority})',
        createdAt: now,
      ),
    );

    // 4. Broadcast creation event
    await session.messages.postMessage('emergency_${created.id}', created);
    await session.messages.postMessage('emergency_feed', created);

    // 5. Trigger smart matching engine asynchronously
    final matchedResponder = await MatchingService.findAndAssignBestResponder(
      session,
      created,
    );
    if (matchedResponder != null) {
      final refreshed = await EmergencyRequest.db.findById(
        session,
        created.id!,
      );
      return refreshed ?? created;
    }

    return created;
  }

  /// Get emergency by ID.
  Future<EmergencyRequest?> getEmergency(Session session, int id) async {
    return await EmergencyRequest.db.findById(session, id);
  }

  /// Get all emergencies created by the current authenticated citizen.
  Future<List<EmergencyRequest>> getMyEmergencies(
    Session session,
  ) async {
    final auth = session.authenticated;
    if (auth == null) {
      return [];
    }
    final userId = int.tryParse(auth.userIdentifier);
    if (userId == null) return [];
    return await EmergencyRequest.db.find(
      session,
      where: (t) => t.requesterId.equals(userId),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  /// Get all active emergencies (for responders and live feed).
  Future<List<EmergencyRequest>> getActiveEmergencies(
    Session session,
  ) async {
    return await EmergencyRequest.db.find(
      session,
      where: (t) =>
          t.status.notEquals('resolved') & t.status.notEquals('cancelled'),
      orderBy: (t) => t.createdAt.desc(),
      limit: 50,
    );
  }

  /// Cancel an emergency request.
  Future<EmergencyRequest> cancelEmergency(
    Session session, {
    required int emergencyId,
    required String reason,
  }) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw StateError('Authentication required');
    }
    final actorId = int.parse(auth.userIdentifier);

    final emergency = await EmergencyRequest.db.findById(session, emergencyId);
    if (emergency == null) {
      throw ArgumentError('Emergency #$emergencyId not found.');
    }

    if (emergency.status == 'resolved') {
      throw StateError('Cannot cancel an already resolved emergency.');
    }

    final now = DateTime.now();
    final updated = emergency.copyWith(
      status: 'cancelled',
      cancellationReason: reason,
      updatedAt: now,
    );
    await EmergencyRequest.db.updateRow(session, updated);

    // If a responder was assigned, free them up
    if (emergency.assignedResponderId != null) {
      final responder = await ResponderProfile.db.findById(
        session,
        emergency.assignedResponderId!,
      );
      if (responder != null && responder.activeEmergencyId == emergencyId) {
        await ResponderProfile.db.updateRow(
          session,
          responder.copyWith(activeEmergencyId: null),
        );
      }
    }

    // Audit log
    await EmergencyStatusEvent.db.insertRow(
      session,
      EmergencyStatusEvent(
        emergencyId: emergencyId,
        status: 'cancelled',
        actorId: actorId,
        note: 'Cancelled: $reason',
        createdAt: now,
      ),
    );

    // Broadcast
    await session.messages.postMessage('emergency_$emergencyId', updated);
    await session.messages.postMessage('emergency_feed', updated);

    return updated;
  }

  /// Fetch chronological timeline / audit trail of status events.
  Future<List<EmergencyStatusEvent>> getStatusEvents(
    Session session,
    int emergencyId,
  ) async {
    return await EmergencyStatusEvent.db.find(
      session,
      where: (t) => t.emergencyId.equals(emergencyId),
      orderBy: (t) => t.createdAt.asc(),
    );
  }

  /// Stream real-time updates for a single emergency request.
  Stream<EmergencyRequest> streamEmergency(
    Session session,
    int emergencyId,
  ) {
    return session.messages.createStream<EmergencyRequest>(
      'emergency_$emergencyId',
    );
  }

  /// Stream all emergency events (for real-time dashboard or responder alert feed).
  Stream<EmergencyRequest> streamEmergencyFeed(Session session) {
    return session.messages.createStream<EmergencyRequest>(
      'emergency_feed',
    );
  }
}
