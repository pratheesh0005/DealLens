import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Endpoint for operations dashboard, system telemetry, and admin overrides.
class AdminEndpoint extends Endpoint {
  Future<void> _verifyAdmin(Session session) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw StateError('Authentication required');
    }
    final userId = int.tryParse(auth.userIdentifier);
    if (userId == null) {
      throw StateError('Invalid user session');
    }
    final profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    if (profile == null || profile.role != 'admin') {
      throw StateError('Access denied: Admin role required');
    }
  }

  /// Aggregate system-wide statistics for the admin control room.
  Future<AdminStats> getDashboardStats(Session session) async {
    await _verifyAdmin(session);

    // 1. Pending emergencies
    final pendingCount = await EmergencyRequest.db.count(
      session,
      where: (t) => t.status.equals('pending') | t.status.equals('matching'),
    );

    // 2. Active emergencies in progress
    final activeCount = await EmergencyRequest.db.count(
      session,
      where: (t) =>
          t.status.equals('assigned') |
          t.status.equals('accepted') |
          t.status.equals('enRoute') |
          t.status.equals('arrived'),
    );

    // 3. Resolved today
    final startOfToday = DateTime.now().toUtc();
    final todayMidnight = DateTime.utc(
      startOfToday.year,
      startOfToday.month,
      startOfToday.day,
    );

    final resolvedToday = await EmergencyRequest.db.count(
      session,
      where: (t) =>
          t.status.equals('resolved') & (t.resolvedAt >= todayMidnight),
    );

    // 4. Cancelled today
    final cancelledToday = await EmergencyRequest.db.count(
      session,
      where: (t) =>
          t.status.equals('cancelled') & (t.updatedAt >= todayMidnight),
    );

    // 5. Available responders (isAvailable=true, activeEmergencyId=null)
    final availableResponders = await ResponderProfile.db.count(
      session,
      where: (t) =>
          t.isAvailable.equals(true) & t.activeEmergencyId.equals(null),
    );

    // 6. Active responders currently handling an emergency
    final activeResponders = await ResponderProfile.db.count(
      session,
      where: (t) => t.activeEmergencyId.notEquals(null),
    );

    // 7. Total citizens
    final totalCitizens = await UserProfile.db.count(
      session,
      where: (t) => t.role.equals('citizen'),
    );

    // 8. Total responders
    final totalResponders = await ResponderProfile.db.count(session);

    return AdminStats(
      pendingCount: pendingCount,
      activeCount: activeCount,
      resolvedTodayCount: resolvedToday,
      cancelledTodayCount: cancelledToday,
      availableResponderCount: availableResponders,
      activeResponderCount: activeResponders,
      totalCitizens: totalCitizens,
      totalResponders: totalResponders,
    );
  }

  /// List all emergencies with optional status filter and pagination.
  Future<List<EmergencyRequest>> getAllEmergencies(
    Session session, {
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    return await EmergencyRequest.db.find(
      session,
      where: (t) =>
          status != null ? t.status.equals(status) : Constant.bool(true),
      orderBy: (t) => t.createdAt.desc(),
      limit: limit,
      offset: offset,
    );
  }

  /// List all registered responders.
  Future<List<ResponderProfile>> getAllResponders(Session session) async {
    return await ResponderProfile.db.find(
      session,
      orderBy: (t) => t.totalResponseCount.desc(),
    );
  }

  /// Admin override to forcefully resolve an emergency.
  Future<EmergencyRequest> forceResolveEmergency(
    Session session, {
    required int emergencyId,
    required String reason,
  }) async {
    final emergency = await EmergencyRequest.db.findById(session, emergencyId);
    if (emergency == null) {
      throw ArgumentError('Emergency #$emergencyId not found.');
    }

    final now = DateTime.now();
    final updated = emergency.copyWith(
      status: 'resolved',
      resolvedAt: now,
      updatedAt: now,
    );
    await EmergencyRequest.db.updateRow(session, updated);

    // Free responder if assigned
    if (emergency.assignedResponderId != null) {
      final responder = await ResponderProfile.db.findById(
        session,
        emergency.assignedResponderId!,
      );
      if (responder != null && responder.activeEmergencyId == emergencyId) {
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
        status: 'resolved',
        actorId: 0, // 0 = admin system
        note: 'Admin override resolution: $reason',
        createdAt: now,
      ),
    );

    // Broadcast
    await session.messages.postMessage('emergency_$emergencyId', updated);
    await session.messages.postMessage('emergency_feed', updated);

    return updated;
  }
}
