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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// ResQLink UserProfile — stores role and display info for every user.
/// userId links to the serverpod_auth AppUser (the auth module's user record).
abstract class UserProfile
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserProfile._({
    this.id,
    required this.userId,
    required this.displayName,
    required this.email,
    this.phone,
    required this.role,
    required this.createdAt,
    this.avatarUrl,
    this.fcmToken,
  });

  factory UserProfile({
    int? id,
    required int userId,
    required String displayName,
    required String email,
    String? phone,
    required String role,
    required DateTime createdAt,
    String? avatarUrl,
    String? fcmToken,
  }) = _UserProfileImpl;

  factory UserProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserProfile(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      displayName: jsonSerialization['displayName'] as String,
      email: jsonSerialization['email'] as String,
      phone: jsonSerialization['phone'] as String?,
      role: jsonSerialization['role'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      fcmToken: jsonSerialization['fcmToken'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The serverpod_auth userId (from AuthUser). Not nullable — every profile belongs to a real auth user.
  int userId;

  /// The user's display name.
  String displayName;

  /// The user's email (mirrored from auth for quick lookup).
  String email;

  /// Optional phone number.
  String? phone;

  /// Role: citizen | responder | admin. Always validated server-side.
  String role;

  /// ISO 8601 timestamp when the profile was created.
  DateTime createdAt;

  /// Optional avatar URL.
  String? avatarUrl;

  /// FCM device token for push notifications.
  String? fcmToken;

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserProfile copyWith({
    int? id,
    int? userId,
    String? displayName,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
    String? avatarUrl,
    String? fcmToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserProfile',
      if (id != null) 'id': id,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      'createdAt': createdAt.toJson(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserProfile',
      if (id != null) 'id': id,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      'createdAt': createdAt.toJson(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserProfileImpl extends UserProfile {
  _UserProfileImpl({
    int? id,
    required int userId,
    required String displayName,
    required String email,
    String? phone,
    required String role,
    required DateTime createdAt,
    String? avatarUrl,
    String? fcmToken,
  }) : super._(
         id: id,
         userId: userId,
         displayName: displayName,
         email: email,
         phone: phone,
         role: role,
         createdAt: createdAt,
         avatarUrl: avatarUrl,
         fcmToken: fcmToken,
       );

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserProfile copyWith({
    Object? id = _Undefined,
    int? userId,
    String? displayName,
    String? email,
    Object? phone = _Undefined,
    String? role,
    DateTime? createdAt,
    Object? avatarUrl = _Undefined,
    Object? fcmToken = _Undefined,
  }) {
    return UserProfile(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone is String? ? phone : this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl is String? ? avatarUrl : this.avatarUrl,
      fcmToken: fcmToken is String? ? fcmToken : this.fcmToken,
    );
  }
}
