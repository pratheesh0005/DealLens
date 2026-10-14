import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';
import '../generated/protocol.dart';

/// Endpoint for managing user authentication and profiles (citizens, responders, and admins).
class UserEndpoint extends Endpoint {
  /// Authenticate (register or login) a user, issuing a Serverpod AuthKey.
  Future<AuthSuccess> authenticate(
    Session session, {
    required String email,
    required String displayName,
    required String role,
    String? phone,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedRole = role.trim().toLowerCase();
    final cleanName = displayName.trim().isEmpty
        ? 'ResQLink User'
        : displayName.trim();

    if (!['citizen', 'responder', 'admin'].contains(normalizedRole)) {
      throw ArgumentError(
        'Invalid role: $role. Must be citizen, responder, or admin.',
      );
    }

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw ArgumentError('A valid email address is required.');
    }

    // 1. Find or create Serverpod UserInfo
    var userInfo = await Users.findUserByEmail(session, normalizedEmail);
    userInfo ??= await Users.createUser(
      session,
      UserInfo(
        userIdentifier: normalizedEmail,
        userName: cleanName,
        email: normalizedEmail,
        created: DateTime.now(),
        scopeNames: [normalizedRole],
        blocked: false,
      ),
      'email',
    );

    if (userInfo == null || userInfo.id == null) {
      throw StateError('Failed to register or retrieve user identity.');
    }

    // 2. Find or create/update UserProfile
    var profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userInfo!.id!),
    );

    if (profile == null) {
      profile = await UserProfile.db.insertRow(
        session,
        UserProfile(
          userId: userInfo.id!,
          displayName: cleanName,
          email: normalizedEmail,
          role: normalizedRole,
          phone: phone?.trim(),
          createdAt: DateTime.now(),
        ),
      );
    } else {
      profile = await UserProfile.db.updateRow(
        session,
        profile.copyWith(
          displayName: cleanName,
          role: normalizedRole,
          phone: phone?.trim() ?? profile.phone,
        ),
      );
    }

    // 3. If responder, guarantee a ResponderProfile row exists
    if (normalizedRole == 'responder') {
      final existingResponder = await ResponderProfile.db.findFirstRow(
        session,
        where: (t) => t.userProfileId.equals(profile!.id!),
      );
      if (existingResponder == null) {
        await ResponderProfile.db.insertRow(
          session,
          ResponderProfile(
            userProfileId: profile.id!,
            isAvailable: true,
            capabilities: 'medical,accident,rescue,fire',
            totalResponseCount: 0,
            lastLocationUpdate: DateTime.now(),
          ),
        );
      }
    }

    // 4. Issue a real Serverpod AuthKey
    final authKey = await UserAuthentication.signInUser(
      session,
      userInfo.id!,
      'email',
      scopes: {Scope(normalizedRole)},
    );

    return AuthSuccess(
      userId: userInfo.id!,
      keyId: authKey.id!,
      key: authKey.key!,
      profile: profile,
    );
  }

  /// Get the current authenticated user's profile.
  Future<UserProfile?> getMyProfile(Session session) async {
    final auth = session.authenticated;
    if (auth == null) {
      return null;
    }
    final userId = int.tryParse(auth.userIdentifier);
    if (userId == null) return null;
    return await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
  }

  /// Create or update user profile for authenticated user.
  Future<UserProfile> updateMyProfile(
    Session session, {
    required String displayName,
    required String role,
    String? phone,
    String? avatarUrl,
  }) async {
    final auth = session.authenticated;
    if (auth == null) {
      throw StateError('Authentication required');
    }
    final userId = int.parse(auth.userIdentifier);

    final normalizedRole = role.toLowerCase().trim();
    if (!['citizen', 'responder', 'admin'].contains(normalizedRole)) {
      throw ArgumentError(
        'Invalid role: $role. Must be citizen, responder, or admin.',
      );
    }

    final existing = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );

    if (existing == null) {
      throw StateError('UserProfile not found for authenticated user.');
    }

    final updated = existing.copyWith(
      displayName: displayName.trim(),
      role: normalizedRole,
      phone: phone?.trim(),
      avatarUrl: avatarUrl,
    );
    return await UserProfile.db.updateRow(session, updated);
  }

  /// Update FCM device token for push notifications.
  Future<bool> updateFcmToken(
    Session session,
    String fcmToken,
  ) async {
    final auth = session.authenticated;
    if (auth == null) return false;

    final profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(int.parse(auth.userIdentifier)),
    );
    if (profile == null) return false;

    final updated = profile.copyWith(fcmToken: fcmToken);
    await UserProfile.db.updateRow(session, updated);
    return true;
  }
}
