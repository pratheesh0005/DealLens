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

/// ResQLink ResponderProfile — availability and capability info for responders.
/// Each row corresponds to a UserProfile with role=responder.
abstract class ResponderProfile
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ResponderProfile._({
    this.id,
    required this.userProfileId,
    required this.isAvailable,
    required this.capabilities,
    this.currentLat,
    this.currentLng,
    this.lastLocationUpdate,
    this.activeEmergencyId,
    required this.totalResponseCount,
    this.lastAssignedAt,
  });

  factory ResponderProfile({
    int? id,
    required int userProfileId,
    required bool isAvailable,
    required String capabilities,
    double? currentLat,
    double? currentLng,
    DateTime? lastLocationUpdate,
    int? activeEmergencyId,
    required int totalResponseCount,
    DateTime? lastAssignedAt,
  }) = _ResponderProfileImpl;

  factory ResponderProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return ResponderProfile(
      id: jsonSerialization['id'] as int?,
      userProfileId: jsonSerialization['userProfileId'] as int,
      isAvailable: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isAvailable'],
      ),
      capabilities: jsonSerialization['capabilities'] as String,
      currentLat: (jsonSerialization['currentLat'] as num?)?.toDouble(),
      currentLng: (jsonSerialization['currentLng'] as num?)?.toDouble(),
      lastLocationUpdate: jsonSerialization['lastLocationUpdate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastLocationUpdate'],
            ),
      activeEmergencyId: jsonSerialization['activeEmergencyId'] as int?,
      totalResponseCount: jsonSerialization['totalResponseCount'] as int,
      lastAssignedAt: jsonSerialization['lastAssignedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastAssignedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// FK to user_profiles.id
  int userProfileId;

  /// Whether the responder is currently available to receive requests.
  bool isAvailable;

  /// Comma-separated capability codes: medical,fire,rescue,accident,missing
  String capabilities;

  /// Last known latitude (-90 to 90). Null if not yet set.
  double? currentLat;

  /// Last known longitude (-180 to 180). Null if not yet set.
  double? currentLng;

  /// When the location was last updated.
  DateTime? lastLocationUpdate;

  /// FK to emergency_requests.id for the active assignment, if any.
  int? activeEmergencyId;

  /// Total number of emergencies this responder has resolved.
  int totalResponseCount;

  /// Timestamp of the last time this responder was assigned an emergency.
  /// Used for fairness scoring in the matching algorithm.
  DateTime? lastAssignedAt;

  /// Returns a shallow copy of this [ResponderProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ResponderProfile copyWith({
    int? id,
    int? userProfileId,
    bool? isAvailable,
    String? capabilities,
    double? currentLat,
    double? currentLng,
    DateTime? lastLocationUpdate,
    int? activeEmergencyId,
    int? totalResponseCount,
    DateTime? lastAssignedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ResponderProfile',
      if (id != null) 'id': id,
      'userProfileId': userProfileId,
      'isAvailable': isAvailable,
      'capabilities': capabilities,
      if (currentLat != null) 'currentLat': currentLat,
      if (currentLng != null) 'currentLng': currentLng,
      if (lastLocationUpdate != null)
        'lastLocationUpdate': lastLocationUpdate?.toJson(),
      if (activeEmergencyId != null) 'activeEmergencyId': activeEmergencyId,
      'totalResponseCount': totalResponseCount,
      if (lastAssignedAt != null) 'lastAssignedAt': lastAssignedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ResponderProfile',
      if (id != null) 'id': id,
      'userProfileId': userProfileId,
      'isAvailable': isAvailable,
      'capabilities': capabilities,
      if (currentLat != null) 'currentLat': currentLat,
      if (currentLng != null) 'currentLng': currentLng,
      if (lastLocationUpdate != null)
        'lastLocationUpdate': lastLocationUpdate?.toJson(),
      if (activeEmergencyId != null) 'activeEmergencyId': activeEmergencyId,
      'totalResponseCount': totalResponseCount,
      if (lastAssignedAt != null) 'lastAssignedAt': lastAssignedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ResponderProfileImpl extends ResponderProfile {
  _ResponderProfileImpl({
    int? id,
    required int userProfileId,
    required bool isAvailable,
    required String capabilities,
    double? currentLat,
    double? currentLng,
    DateTime? lastLocationUpdate,
    int? activeEmergencyId,
    required int totalResponseCount,
    DateTime? lastAssignedAt,
  }) : super._(
         id: id,
         userProfileId: userProfileId,
         isAvailable: isAvailable,
         capabilities: capabilities,
         currentLat: currentLat,
         currentLng: currentLng,
         lastLocationUpdate: lastLocationUpdate,
         activeEmergencyId: activeEmergencyId,
         totalResponseCount: totalResponseCount,
         lastAssignedAt: lastAssignedAt,
       );

  /// Returns a shallow copy of this [ResponderProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ResponderProfile copyWith({
    Object? id = _Undefined,
    int? userProfileId,
    bool? isAvailable,
    String? capabilities,
    Object? currentLat = _Undefined,
    Object? currentLng = _Undefined,
    Object? lastLocationUpdate = _Undefined,
    Object? activeEmergencyId = _Undefined,
    int? totalResponseCount,
    Object? lastAssignedAt = _Undefined,
  }) {
    return ResponderProfile(
      id: id is int? ? id : this.id,
      userProfileId: userProfileId ?? this.userProfileId,
      isAvailable: isAvailable ?? this.isAvailable,
      capabilities: capabilities ?? this.capabilities,
      currentLat: currentLat is double? ? currentLat : this.currentLat,
      currentLng: currentLng is double? ? currentLng : this.currentLng,
      lastLocationUpdate: lastLocationUpdate is DateTime?
          ? lastLocationUpdate
          : this.lastLocationUpdate,
      activeEmergencyId: activeEmergencyId is int?
          ? activeEmergencyId
          : this.activeEmergencyId,
      totalResponseCount: totalResponseCount ?? this.totalResponseCount,
      lastAssignedAt: lastAssignedAt is DateTime?
          ? lastAssignedAt
          : this.lastAssignedAt,
    );
  }
}
