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

/// ResQLink EmergencyStatusEvent — immutable audit log of every status change.
/// Created by the server on every status transition; never deleted.
abstract class EmergencyStatusEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EmergencyStatusEvent._({
    this.id,
    required this.emergencyId,
    required this.status,
    required this.actorId,
    this.note,
    required this.createdAt,
  });

  factory EmergencyStatusEvent({
    int? id,
    required int emergencyId,
    required String status,
    required int actorId,
    String? note,
    required DateTime createdAt,
  }) = _EmergencyStatusEventImpl;

  factory EmergencyStatusEvent.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EmergencyStatusEvent(
      id: jsonSerialization['id'] as int?,
      emergencyId: jsonSerialization['emergencyId'] as int,
      status: jsonSerialization['status'] as String,
      actorId: jsonSerialization['actorId'] as int,
      note: jsonSerialization['note'] as String?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// FK to emergency_requests.id
  int emergencyId;

  /// The new status after this transition.
  String status;

  /// The userId (from user_profiles) who triggered this change.
  int actorId;

  /// Optional human-readable note (e.g. "Responder declined: too far").
  String? note;

  /// When this event was recorded.
  DateTime createdAt;

  /// Returns a shallow copy of this [EmergencyStatusEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EmergencyStatusEvent copyWith({
    int? id,
    int? emergencyId,
    String? status,
    int? actorId,
    String? note,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EmergencyStatusEvent',
      if (id != null) 'id': id,
      'emergencyId': emergencyId,
      'status': status,
      'actorId': actorId,
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EmergencyStatusEvent',
      if (id != null) 'id': id,
      'emergencyId': emergencyId,
      'status': status,
      'actorId': actorId,
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EmergencyStatusEventImpl extends EmergencyStatusEvent {
  _EmergencyStatusEventImpl({
    int? id,
    required int emergencyId,
    required String status,
    required int actorId,
    String? note,
    required DateTime createdAt,
  }) : super._(
         id: id,
         emergencyId: emergencyId,
         status: status,
         actorId: actorId,
         note: note,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [EmergencyStatusEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EmergencyStatusEvent copyWith({
    Object? id = _Undefined,
    int? emergencyId,
    String? status,
    int? actorId,
    Object? note = _Undefined,
    DateTime? createdAt,
  }) {
    return EmergencyStatusEvent(
      id: id is int? ? id : this.id,
      emergencyId: emergencyId ?? this.emergencyId,
      status: status ?? this.status,
      actorId: actorId ?? this.actorId,
      note: note is String? ? note : this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
