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
import 'package:resqlink_client/src/protocol/protocol.dart' as _i17c0nzg;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'user_profile.dart' as _ir2mn8w1;

abstract class AuthSuccess
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AuthSuccess._({
    required this.userId,
    required this.keyId,
    required this.key,
    required this.profile,
  });

  factory AuthSuccess({
    required int userId,
    required int keyId,
    required String key,
    required _ir2mn8w1.UserProfile profile,
  }) = _AuthSuccessImpl;

  factory AuthSuccess.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuthSuccess(
      userId: jsonSerialization['userId'] as int,
      keyId: jsonSerialization['keyId'] as int,
      key: jsonSerialization['key'] as String,
      profile: _i17c0nzg.Protocol().deserialize<_ir2mn8w1.UserProfile>(
        jsonSerialization['profile'],
      ),
    );
  }

  int userId;

  int keyId;

  String key;

  _ir2mn8w1.UserProfile profile;

  /// Returns a shallow copy of this [AuthSuccess]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AuthSuccess copyWith({
    int? userId,
    int? keyId,
    String? key,
    _ir2mn8w1.UserProfile? profile,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuthSuccess',
      'userId': userId,
      'keyId': keyId,
      'key': key,
      'profile': profile.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AuthSuccess',
      'userId': userId,
      'keyId': keyId,
      'key': key,
      'profile': profile.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AuthSuccessImpl extends AuthSuccess {
  _AuthSuccessImpl({
    required int userId,
    required int keyId,
    required String key,
    required _ir2mn8w1.UserProfile profile,
  }) : super._(
         userId: userId,
         keyId: keyId,
         key: key,
         profile: profile,
       );

  /// Returns a shallow copy of this [AuthSuccess]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AuthSuccess copyWith({
    int? userId,
    int? keyId,
    String? key,
    _ir2mn8w1.UserProfile? profile,
  }) {
    return AuthSuccess(
      userId: userId ?? this.userId,
      keyId: keyId ?? this.keyId,
      key: key ?? this.key,
      profile: profile ?? this.profile.copyWith(),
    );
  }
}
