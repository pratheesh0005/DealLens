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

/// ResQLink EmergencyRequest — the core entity of the platform.
/// Created by a citizen, assigned to a responder via smart matching.
abstract class EmergencyRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EmergencyRequest._({
    this.id,
    required this.requesterId,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.resolvedAt,
    this.assignedResponderId,
    required this.idempotencyKey,
    this.cancellationReason,
    required this.matchingRetryCount,
  });

  factory EmergencyRequest({
    int? id,
    required int requesterId,
    required String type,
    required String description,
    required double latitude,
    required double longitude,
    required String priority,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? resolvedAt,
    int? assignedResponderId,
    required String idempotencyKey,
    String? cancellationReason,
    required int matchingRetryCount,
  }) = _EmergencyRequestImpl;

  factory EmergencyRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return EmergencyRequest(
      id: jsonSerialization['id'] as int?,
      requesterId: jsonSerialization['requesterId'] as int,
      type: jsonSerialization['type'] as String,
      description: jsonSerialization['description'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      priority: jsonSerialization['priority'] as String,
      status: jsonSerialization['status'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['acceptedAt'],
            ),
      arrivedAt: jsonSerialization['arrivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['arrivedAt']),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['resolvedAt'],
            ),
      assignedResponderId: jsonSerialization['assignedResponderId'] as int?,
      idempotencyKey: jsonSerialization['idempotencyKey'] as String,
      cancellationReason: jsonSerialization['cancellationReason'] as String?,
      matchingRetryCount: jsonSerialization['matchingRetryCount'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// FK to user_profiles.id — the citizen who created this request.
  int requesterId;

  /// Emergency category: medical | accident | fire | rescue | missing | other
  String type;

  /// Free-text description from the citizen.
  String description;

  /// Location latitude where help is needed.
  double latitude;

  /// Location longitude where help is needed.
  double longitude;

  /// Priority level: low | medium | high | critical
  String priority;

  /// Lifecycle status: pending | matching | assigned | accepted | enRoute | arrived | resolved | cancelled
  String status;

  /// When the request was created.
  DateTime createdAt;

  /// When the request was last updated (any status change).
  DateTime updatedAt;

  /// When a responder accepted the assignment.
  DateTime? acceptedAt;

  /// When the responder marked themselves as arrived.
  DateTime? arrivedAt;

  /// When the emergency was resolved.
  DateTime? resolvedAt;

  /// FK to responder_profiles.id — set when a responder is matched.
  int? assignedResponderId;

  /// Client-generated UUID to prevent duplicate submissions on retry.
  String idempotencyKey;

  /// Human-readable cancellation or rejection reason, if applicable.
  String? cancellationReason;

  /// Number of times the matching algorithm has been retried.
  int matchingRetryCount;

  /// Returns a shallow copy of this [EmergencyRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EmergencyRequest copyWith({
    int? id,
    int? requesterId,
    String? type,
    String? description,
    double? latitude,
    double? longitude,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? resolvedAt,
    int? assignedResponderId,
    String? idempotencyKey,
    String? cancellationReason,
    int? matchingRetryCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EmergencyRequest',
      if (id != null) 'id': id,
      'requesterId': requesterId,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (arrivedAt != null) 'arrivedAt': arrivedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (assignedResponderId != null)
        'assignedResponderId': assignedResponderId,
      'idempotencyKey': idempotencyKey,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      'matchingRetryCount': matchingRetryCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EmergencyRequest',
      if (id != null) 'id': id,
      'requesterId': requesterId,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (arrivedAt != null) 'arrivedAt': arrivedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (assignedResponderId != null)
        'assignedResponderId': assignedResponderId,
      'idempotencyKey': idempotencyKey,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      'matchingRetryCount': matchingRetryCount,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EmergencyRequestImpl extends EmergencyRequest {
  _EmergencyRequestImpl({
    int? id,
    required int requesterId,
    required String type,
    required String description,
    required double latitude,
    required double longitude,
    required String priority,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? resolvedAt,
    int? assignedResponderId,
    required String idempotencyKey,
    String? cancellationReason,
    required int matchingRetryCount,
  }) : super._(
         id: id,
         requesterId: requesterId,
         type: type,
         description: description,
         latitude: latitude,
         longitude: longitude,
         priority: priority,
         status: status,
         createdAt: createdAt,
         updatedAt: updatedAt,
         acceptedAt: acceptedAt,
         arrivedAt: arrivedAt,
         resolvedAt: resolvedAt,
         assignedResponderId: assignedResponderId,
         idempotencyKey: idempotencyKey,
         cancellationReason: cancellationReason,
         matchingRetryCount: matchingRetryCount,
       );

  /// Returns a shallow copy of this [EmergencyRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EmergencyRequest copyWith({
    Object? id = _Undefined,
    int? requesterId,
    String? type,
    String? description,
    double? latitude,
    double? longitude,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? acceptedAt = _Undefined,
    Object? arrivedAt = _Undefined,
    Object? resolvedAt = _Undefined,
    Object? assignedResponderId = _Undefined,
    String? idempotencyKey,
    Object? cancellationReason = _Undefined,
    int? matchingRetryCount,
  }) {
    return EmergencyRequest(
      id: id is int? ? id : this.id,
      requesterId: requesterId ?? this.requesterId,
      type: type ?? this.type,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt is DateTime? ? acceptedAt : this.acceptedAt,
      arrivedAt: arrivedAt is DateTime? ? arrivedAt : this.arrivedAt,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      assignedResponderId: assignedResponderId is int?
          ? assignedResponderId
          : this.assignedResponderId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      cancellationReason: cancellationReason is String?
          ? cancellationReason
          : this.cancellationReason,
      matchingRetryCount: matchingRetryCount ?? this.matchingRetryCount,
    );
  }
}
