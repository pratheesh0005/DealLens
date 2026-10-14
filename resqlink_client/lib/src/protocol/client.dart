/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:resqlink_client/src/protocol/admin_stats.dart' as _i2z6zzju;
import 'package:resqlink_client/src/protocol/auth_success.dart' as _i30x645p;
import 'package:resqlink_client/src/protocol/emergency_request.dart'
    as _ifv5qcq0;
import 'package:resqlink_client/src/protocol/emergency_status_event.dart'
    as _ia4k3xal;
import 'package:resqlink_client/src/protocol/greetings/greeting.dart'
    as _i5vfzaub;
import 'package:resqlink_client/src/protocol/responder_profile.dart'
    as _icqjyfds;
import 'package:resqlink_client/src/protocol/user_profile.dart' as _i0gh1jmp;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i312scxx;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// Endpoint for operations dashboard, system telemetry, and admin overrides.
/// {@category Endpoint}
class EndpointAdmin extends _isc.EndpointRef {
  EndpointAdmin(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'admin';

  /// Aggregate system-wide statistics for the admin control room.
  _ida.Future<_i2z6zzju.AdminStats> getDashboardStats() =>
      caller.callServerEndpoint<_i2z6zzju.AdminStats>(
        'admin',
        'getDashboardStats',
        {},
      );

  /// List all emergencies with optional status filter and pagination.
  _ida.Future<List<_ifv5qcq0.EmergencyRequest>> getAllEmergencies({
    String? status,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_ifv5qcq0.EmergencyRequest>>(
    'admin',
    'getAllEmergencies',
    {
      'status': status,
      'limit': limit,
      'offset': offset,
    },
  );

  /// List all registered responders.
  _ida.Future<List<_icqjyfds.ResponderProfile>> getAllResponders() =>
      caller.callServerEndpoint<List<_icqjyfds.ResponderProfile>>(
        'admin',
        'getAllResponders',
        {},
      );

  /// Admin override to forcefully resolve an emergency.
  _ida.Future<_ifv5qcq0.EmergencyRequest> forceResolveEmergency({
    required int emergencyId,
    required String reason,
  }) => caller.callServerEndpoint<_ifv5qcq0.EmergencyRequest>(
    'admin',
    'forceResolveEmergency',
    {
      'emergencyId': emergencyId,
      'reason': reason,
    },
  );
}

/// Endpoint for emergency creation, cancellation, status tracking, and live streams.
/// {@category Endpoint}
class EndpointEmergency extends _isc.EndpointRef {
  EndpointEmergency(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emergency';

  /// Create a new emergency request with idempotency protection and trigger matching.
  _ida.Future<_ifv5qcq0.EmergencyRequest> createEmergency(
    _ifv5qcq0.EmergencyRequest request,
  ) => caller.callServerEndpoint<_ifv5qcq0.EmergencyRequest>(
    'emergency',
    'createEmergency',
    {'request': request},
  );

  /// Get emergency by ID.
  _ida.Future<_ifv5qcq0.EmergencyRequest?> getEmergency(int id) =>
      caller.callServerEndpoint<_ifv5qcq0.EmergencyRequest?>(
        'emergency',
        'getEmergency',
        {'id': id},
      );

  /// Get all emergencies created by the current authenticated citizen.
  _ida.Future<List<_ifv5qcq0.EmergencyRequest>> getMyEmergencies() =>
      caller.callServerEndpoint<List<_ifv5qcq0.EmergencyRequest>>(
        'emergency',
        'getMyEmergencies',
        {},
      );

  /// Get all active emergencies (for responders and live feed).
  _ida.Future<List<_ifv5qcq0.EmergencyRequest>> getActiveEmergencies() =>
      caller.callServerEndpoint<List<_ifv5qcq0.EmergencyRequest>>(
        'emergency',
        'getActiveEmergencies',
        {},
      );

  /// Cancel an emergency request.
  _ida.Future<_ifv5qcq0.EmergencyRequest> cancelEmergency({
    required int emergencyId,
    required String reason,
  }) => caller.callServerEndpoint<_ifv5qcq0.EmergencyRequest>(
    'emergency',
    'cancelEmergency',
    {
      'emergencyId': emergencyId,
      'reason': reason,
    },
  );

  /// Fetch chronological timeline / audit trail of status events.
  _ida.Future<List<_ia4k3xal.EmergencyStatusEvent>> getStatusEvents(
    int emergencyId,
  ) => caller.callServerEndpoint<List<_ia4k3xal.EmergencyStatusEvent>>(
    'emergency',
    'getStatusEvents',
    {'emergencyId': emergencyId},
  );

  /// Stream real-time updates for a single emergency request.
  _ida.Stream<_ifv5qcq0.EmergencyRequest> streamEmergency(int emergencyId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ifv5qcq0.EmergencyRequest>,
        _ifv5qcq0.EmergencyRequest
      >(
        'emergency',
        'streamEmergency',
        {'emergencyId': emergencyId},
        {},
      );

  /// Stream all emergency events (for real-time dashboard or responder alert feed).
  _ida.Stream<_ifv5qcq0.EmergencyRequest> streamEmergencyFeed() =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ifv5qcq0.EmergencyRequest>,
        _ifv5qcq0.EmergencyRequest
      >(
        'emergency',
        'streamEmergencyFeed',
        {},
        {},
      );
}

/// Endpoint for first responder actions, availability, location, and assignment workflow.
/// {@category Endpoint}
class EndpointResponder extends _isc.EndpointRef {
  EndpointResponder(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'responder';

  /// Register or update responder profile.
  _ida.Future<_icqjyfds.ResponderProfile> registerOrUpdateResponder({
    required int userProfileId,
    required String capabilities,
    required bool isAvailable,
  }) => caller.callServerEndpoint<_icqjyfds.ResponderProfile>(
    'responder',
    'registerOrUpdateResponder',
    {
      'userProfileId': userProfileId,
      'capabilities': capabilities,
      'isAvailable': isAvailable,
    },
  );

  /// Update responder's live GPS coordinates.
  _ida.Future<bool> updateLocation({
    required int responderId,
    required double lat,
    required double lng,
  }) => caller.callServerEndpoint<bool>(
    'responder',
    'updateLocation',
    {
      'responderId': responderId,
      'lat': lat,
      'lng': lng,
    },
  );

  /// Toggle availability (on duty / off duty).
  _ida.Future<_icqjyfds.ResponderProfile?> updateAvailability({
    required int responderId,
    required bool isAvailable,
  }) => caller.callServerEndpoint<_icqjyfds.ResponderProfile?>(
    'responder',
    'updateAvailability',
    {
      'responderId': responderId,
      'isAvailable': isAvailable,
    },
  );

  /// Get responder profile by user profile ID.
  _ida.Future<_icqjyfds.ResponderProfile?> getResponderByUserProfileId(
    int userProfileId,
  ) => caller.callServerEndpoint<_icqjyfds.ResponderProfile?>(
    'responder',
    'getResponderByUserProfileId',
    {'userProfileId': userProfileId},
  );

  /// Get responder profile by ID.
  _ida.Future<_icqjyfds.ResponderProfile?> getResponderById(int responderId) =>
      caller.callServerEndpoint<_icqjyfds.ResponderProfile?>(
        'responder',
        'getResponderById',
        {'responderId': responderId},
      );

  /// Get the current authenticated responder's profile.
  _ida.Future<_icqjyfds.ResponderProfile?> getMyResponderProfile() =>
      caller.callServerEndpoint<_icqjyfds.ResponderProfile?>(
        'responder',
        'getMyResponderProfile',
        {},
      );

  /// Accept an assigned emergency.
  _ida.Future<_ifv5qcq0.EmergencyRequest> acceptEmergency({
    required int responderId,
    required int emergencyId,
  }) => caller.callServerEndpoint<_ifv5qcq0.EmergencyRequest>(
    'responder',
    'acceptEmergency',
    {
      'responderId': responderId,
      'emergencyId': emergencyId,
    },
  );

  /// Decline an assigned emergency so it can be re-routed.
  _ida.Future<_ifv5qcq0.EmergencyRequest> declineEmergency({
    required int responderId,
    required int emergencyId,
    required String reason,
  }) => caller.callServerEndpoint<_ifv5qcq0.EmergencyRequest>(
    'responder',
    'declineEmergency',
    {
      'responderId': responderId,
      'emergencyId': emergencyId,
      'reason': reason,
    },
  );

  /// Update lifecycle status: enRoute | arrived | resolved.
  _ida.Future<_ifv5qcq0.EmergencyRequest> updateEmergencyStatus({
    required int responderId,
    required int emergencyId,
    required String newStatus,
    String? note,
  }) => caller.callServerEndpoint<_ifv5qcq0.EmergencyRequest>(
    'responder',
    'updateEmergencyStatus',
    {
      'responderId': responderId,
      'emergencyId': emergencyId,
      'newStatus': newStatus,
      'note': note,
    },
  );

  /// Real-time stream of assignments and updates for this responder.
  _ida.Stream<_ifv5qcq0.EmergencyRequest> streamAssignments(int responderId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ifv5qcq0.EmergencyRequest>,
        _ifv5qcq0.EmergencyRequest
      >(
        'responder',
        'streamAssignments',
        {'responderId': responderId},
        {},
      );
}

/// Endpoint for managing user authentication and profiles (citizens, responders, and admins).
/// {@category Endpoint}
class EndpointUser extends _isc.EndpointRef {
  EndpointUser(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  /// Authenticate (register or login) a user, issuing a Serverpod AuthKey.
  _ida.Future<_i30x645p.AuthSuccess> authenticate({
    required String email,
    required String displayName,
    required String role,
    String? phone,
  }) => caller.callServerEndpoint<_i30x645p.AuthSuccess>(
    'user',
    'authenticate',
    {
      'email': email,
      'displayName': displayName,
      'role': role,
      'phone': phone,
    },
  );

  /// Get the current authenticated user's profile.
  _ida.Future<_i0gh1jmp.UserProfile?> getMyProfile() =>
      caller.callServerEndpoint<_i0gh1jmp.UserProfile?>(
        'user',
        'getMyProfile',
        {},
      );

  /// Create or update user profile for authenticated user.
  _ida.Future<_i0gh1jmp.UserProfile> updateMyProfile({
    required String displayName,
    required String role,
    String? phone,
    String? avatarUrl,
  }) => caller.callServerEndpoint<_i0gh1jmp.UserProfile>(
    'user',
    'updateMyProfile',
    {
      'displayName': displayName,
      'role': role,
      'phone': phone,
      'avatarUrl': avatarUrl,
    },
  );

  /// Update FCM device token for push notifications.
  _ida.Future<bool> updateFcmToken(String fcmToken) =>
      caller.callServerEndpoint<bool>(
        'user',
        'updateFcmToken',
        {'fcmToken': fcmToken},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_i5vfzaub.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i5vfzaub.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i312scxx.Caller(client);
  }

  late final _i312scxx.Caller auth;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    admin = EndpointAdmin(this);
    emergency = EndpointEmergency(this);
    responder = EndpointResponder(this);
    user = EndpointUser(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointAdmin admin;

  late final EndpointEmergency emergency;

  late final EndpointResponder responder;

  late final EndpointUser user;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'admin': admin,
    'emergency': emergency,
    'responder': responder,
    'user': user,
    'greeting': greeting,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'auth': modules.auth,
  };
}
