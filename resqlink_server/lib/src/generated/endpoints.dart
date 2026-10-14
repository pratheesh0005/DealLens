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
import 'package:resqlink_server/src/generated/emergency_request.dart'
    as _i1tiuqqg;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i1n3uhu0;
import '../endpoints/admin_endpoint.dart' as _i5t1w2d2;
import '../endpoints/emergency_endpoint.dart' as _iu421wgl;
import '../endpoints/responder_endpoint.dart' as _ixab9ci6;
import '../endpoints/user_endpoint.dart' as _iymy5306;
import '../greetings/greeting_endpoint.dart' as _il624ik7;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'admin': _i5t1w2d2.AdminEndpoint()
        ..initialize(
          server,
          'admin',
          null,
        ),
      'emergency': _iu421wgl.EmergencyEndpoint()
        ..initialize(
          server,
          'emergency',
          null,
        ),
      'responder': _ixab9ci6.ResponderEndpoint()
        ..initialize(
          server,
          'responder',
          null,
        ),
      'user': _iymy5306.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['admin'] = _is.EndpointConnector(
      name: 'admin',
      endpoint: endpoints['admin']!,
      methodConnectors: {
        'getDashboardStats': _is.MethodConnector(
          name: 'getDashboardStats',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .getDashboardStats(session),
        ),
        'getAllEmergencies': _is.MethodConnector(
          name: 'getAllEmergencies',
          params: {
            'status': _is.ParameterDescription(
              name: 'status',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .getAllEmergencies(
                    session,
                    status: params['status'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getAllResponders': _is.MethodConnector(
          name: 'getAllResponders',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .getAllResponders(session),
        ),
        'forceResolveEmergency': _is.MethodConnector(
          name: 'forceResolveEmergency',
          params: {
            'emergencyId': _is.ParameterDescription(
              name: 'emergencyId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'reason': _is.ParameterDescription(
              name: 'reason',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .forceResolveEmergency(
                    session,
                    emergencyId: params['emergencyId'],
                    reason: params['reason'],
                  ),
        ),
      },
    );
    connectors['emergency'] = _is.EndpointConnector(
      name: 'emergency',
      endpoint: endpoints['emergency']!,
      methodConnectors: {
        'createEmergency': _is.MethodConnector(
          name: 'createEmergency',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_i1tiuqqg.EmergencyRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emergency'] as _iu421wgl.EmergencyEndpoint)
                  .createEmergency(
                    session,
                    params['request'],
                  ),
        ),
        'getEmergency': _is.MethodConnector(
          name: 'getEmergency',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emergency'] as _iu421wgl.EmergencyEndpoint)
                  .getEmergency(
                    session,
                    params['id'],
                  ),
        ),
        'getMyEmergencies': _is.MethodConnector(
          name: 'getMyEmergencies',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emergency'] as _iu421wgl.EmergencyEndpoint)
                  .getMyEmergencies(session),
        ),
        'getActiveEmergencies': _is.MethodConnector(
          name: 'getActiveEmergencies',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emergency'] as _iu421wgl.EmergencyEndpoint)
                  .getActiveEmergencies(session),
        ),
        'cancelEmergency': _is.MethodConnector(
          name: 'cancelEmergency',
          params: {
            'emergencyId': _is.ParameterDescription(
              name: 'emergencyId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'reason': _is.ParameterDescription(
              name: 'reason',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emergency'] as _iu421wgl.EmergencyEndpoint)
                  .cancelEmergency(
                    session,
                    emergencyId: params['emergencyId'],
                    reason: params['reason'],
                  ),
        ),
        'getStatusEvents': _is.MethodConnector(
          name: 'getStatusEvents',
          params: {
            'emergencyId': _is.ParameterDescription(
              name: 'emergencyId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emergency'] as _iu421wgl.EmergencyEndpoint)
                  .getStatusEvents(
                    session,
                    params['emergencyId'],
                  ),
        ),
        'streamEmergency': _is.MethodStreamConnector(
          name: 'streamEmergency',
          params: {
            'emergencyId': _is.ParameterDescription(
              name: 'emergencyId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['emergency'] as _iu421wgl.EmergencyEndpoint)
                  .streamEmergency(
                    session,
                    params['emergencyId'],
                  ),
        ),
        'streamEmergencyFeed': _is.MethodStreamConnector(
          name: 'streamEmergencyFeed',
          params: {},
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['emergency'] as _iu421wgl.EmergencyEndpoint)
                  .streamEmergencyFeed(session),
        ),
      },
    );
    connectors['responder'] = _is.EndpointConnector(
      name: 'responder',
      endpoint: endpoints['responder']!,
      methodConnectors: {
        'registerOrUpdateResponder': _is.MethodConnector(
          name: 'registerOrUpdateResponder',
          params: {
            'userProfileId': _is.ParameterDescription(
              name: 'userProfileId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'capabilities': _is.ParameterDescription(
              name: 'capabilities',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'isAvailable': _is.ParameterDescription(
              name: 'isAvailable',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .registerOrUpdateResponder(
                    session,
                    userProfileId: params['userProfileId'],
                    capabilities: params['capabilities'],
                    isAvailable: params['isAvailable'],
                  ),
        ),
        'updateLocation': _is.MethodConnector(
          name: 'updateLocation',
          params: {
            'responderId': _is.ParameterDescription(
              name: 'responderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'lat': _is.ParameterDescription(
              name: 'lat',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'lng': _is.ParameterDescription(
              name: 'lng',
              type: _is.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .updateLocation(
                    session,
                    responderId: params['responderId'],
                    lat: params['lat'],
                    lng: params['lng'],
                  ),
        ),
        'updateAvailability': _is.MethodConnector(
          name: 'updateAvailability',
          params: {
            'responderId': _is.ParameterDescription(
              name: 'responderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'isAvailable': _is.ParameterDescription(
              name: 'isAvailable',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .updateAvailability(
                    session,
                    responderId: params['responderId'],
                    isAvailable: params['isAvailable'],
                  ),
        ),
        'getResponderByUserProfileId': _is.MethodConnector(
          name: 'getResponderByUserProfileId',
          params: {
            'userProfileId': _is.ParameterDescription(
              name: 'userProfileId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .getResponderByUserProfileId(
                    session,
                    params['userProfileId'],
                  ),
        ),
        'getResponderById': _is.MethodConnector(
          name: 'getResponderById',
          params: {
            'responderId': _is.ParameterDescription(
              name: 'responderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .getResponderById(
                    session,
                    params['responderId'],
                  ),
        ),
        'getMyResponderProfile': _is.MethodConnector(
          name: 'getMyResponderProfile',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .getMyResponderProfile(session),
        ),
        'acceptEmergency': _is.MethodConnector(
          name: 'acceptEmergency',
          params: {
            'responderId': _is.ParameterDescription(
              name: 'responderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'emergencyId': _is.ParameterDescription(
              name: 'emergencyId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .acceptEmergency(
                    session,
                    responderId: params['responderId'],
                    emergencyId: params['emergencyId'],
                  ),
        ),
        'declineEmergency': _is.MethodConnector(
          name: 'declineEmergency',
          params: {
            'responderId': _is.ParameterDescription(
              name: 'responderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'emergencyId': _is.ParameterDescription(
              name: 'emergencyId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'reason': _is.ParameterDescription(
              name: 'reason',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .declineEmergency(
                    session,
                    responderId: params['responderId'],
                    emergencyId: params['emergencyId'],
                    reason: params['reason'],
                  ),
        ),
        'updateEmergencyStatus': _is.MethodConnector(
          name: 'updateEmergencyStatus',
          params: {
            'responderId': _is.ParameterDescription(
              name: 'responderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'emergencyId': _is.ParameterDescription(
              name: 'emergencyId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'newStatus': _is.ParameterDescription(
              name: 'newStatus',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .updateEmergencyStatus(
                    session,
                    responderId: params['responderId'],
                    emergencyId: params['emergencyId'],
                    newStatus: params['newStatus'],
                    note: params['note'],
                  ),
        ),
        'streamAssignments': _is.MethodStreamConnector(
          name: 'streamAssignments',
          params: {
            'responderId': _is.ParameterDescription(
              name: 'responderId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['responder'] as _ixab9ci6.ResponderEndpoint)
                  .streamAssignments(
                    session,
                    params['responderId'],
                  ),
        ),
      },
    );
    connectors['user'] = _is.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'authenticate': _is.MethodConnector(
          name: 'authenticate',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'displayName': _is.ParameterDescription(
              name: 'displayName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'phone': _is.ParameterDescription(
              name: 'phone',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _iymy5306.UserEndpoint).authenticate(
                    session,
                    email: params['email'],
                    displayName: params['displayName'],
                    role: params['role'],
                    phone: params['phone'],
                  ),
        ),
        'getMyProfile': _is.MethodConnector(
          name: 'getMyProfile',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _iymy5306.UserEndpoint)
                  .getMyProfile(session),
        ),
        'updateMyProfile': _is.MethodConnector(
          name: 'updateMyProfile',
          params: {
            'displayName': _is.ParameterDescription(
              name: 'displayName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'role': _is.ParameterDescription(
              name: 'role',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'phone': _is.ParameterDescription(
              name: 'phone',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'avatarUrl': _is.ParameterDescription(
              name: 'avatarUrl',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _iymy5306.UserEndpoint).updateMyProfile(
                    session,
                    displayName: params['displayName'],
                    role: params['role'],
                    phone: params['phone'],
                    avatarUrl: params['avatarUrl'],
                  ),
        ),
        'updateFcmToken': _is.MethodConnector(
          name: 'updateFcmToken',
          params: {
            'fcmToken': _is.ParameterDescription(
              name: 'fcmToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _iymy5306.UserEndpoint).updateFcmToken(
                    session,
                    params['fcmToken'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    modules['serverpod_auth'] = _i1n3uhu0.Endpoints()
      ..initializeEndpoints(server);
  }
}
