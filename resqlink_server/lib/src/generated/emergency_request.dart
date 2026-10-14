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
import 'package:serverpod/serverpod.dart' as _is;

/// ResQLink EmergencyRequest — the core entity of the platform.
/// Created by a citizen, assigned to a responder via smart matching.
abstract class EmergencyRequest
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['acceptedAt']),
      arrivedAt: jsonSerialization['arrivedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['arrivedAt']),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['resolvedAt']),
      assignedResponderId: jsonSerialization['assignedResponderId'] as int?,
      idempotencyKey: jsonSerialization['idempotencyKey'] as String,
      cancellationReason: jsonSerialization['cancellationReason'] as String?,
      matchingRetryCount: jsonSerialization['matchingRetryCount'] as int,
    );
  }

  static final t = EmergencyRequestTable();

  static const db = EmergencyRequestRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [EmergencyRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static EmergencyRequestInclude include() {
    return EmergencyRequestInclude._();
  }

  static EmergencyRequestIncludeList includeList({
    _is.WhereExpressionBuilder<EmergencyRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EmergencyRequestTable>? orderBy,
    _is.OrderByListBuilder<EmergencyRequestTable>? orderByList,
    EmergencyRequestInclude? include,
  }) {
    return EmergencyRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmergencyRequest.t),
      orderByList: orderByList?.call(EmergencyRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class EmergencyRequestUpdateTable
    extends _is.UpdateTable<EmergencyRequestTable> {
  EmergencyRequestUpdateTable(super.table);

  _is.ColumnValue<int, int> requesterId(int value) => _is.ColumnValue(
    table.requesterId,
    value,
  );

  _is.ColumnValue<String, String> type(String value) => _is.ColumnValue(
    table.type,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<double, double> latitude(double value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<String, String> priority(String value) => _is.ColumnValue(
    table.priority,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> acceptedAt(DateTime? value) =>
      _is.ColumnValue(
        table.acceptedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> arrivedAt(DateTime? value) =>
      _is.ColumnValue(
        table.arrivedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> resolvedAt(DateTime? value) =>
      _is.ColumnValue(
        table.resolvedAt,
        value,
      );

  _is.ColumnValue<int, int> assignedResponderId(int? value) => _is.ColumnValue(
    table.assignedResponderId,
    value,
  );

  _is.ColumnValue<String, String> idempotencyKey(String value) =>
      _is.ColumnValue(
        table.idempotencyKey,
        value,
      );

  _is.ColumnValue<String, String> cancellationReason(String? value) =>
      _is.ColumnValue(
        table.cancellationReason,
        value,
      );

  _is.ColumnValue<int, int> matchingRetryCount(int value) => _is.ColumnValue(
    table.matchingRetryCount,
    value,
  );
}

class EmergencyRequestTable extends _is.Table<int?> {
  EmergencyRequestTable({super.tableRelation})
    : super(tableName: 'emergency_requests') {
    updateTable = EmergencyRequestUpdateTable(this);
    requesterId = _is.ColumnInt(
      'requesterId',
      this,
    );
    type = _is.ColumnString(
      'type',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    latitude = _is.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _is.ColumnDouble(
      'longitude',
      this,
    );
    priority = _is.ColumnString(
      'priority',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
    acceptedAt = _is.ColumnDateTime(
      'acceptedAt',
      this,
    );
    arrivedAt = _is.ColumnDateTime(
      'arrivedAt',
      this,
    );
    resolvedAt = _is.ColumnDateTime(
      'resolvedAt',
      this,
    );
    assignedResponderId = _is.ColumnInt(
      'assignedResponderId',
      this,
    );
    idempotencyKey = _is.ColumnString(
      'idempotencyKey',
      this,
    );
    cancellationReason = _is.ColumnString(
      'cancellationReason',
      this,
    );
    matchingRetryCount = _is.ColumnInt(
      'matchingRetryCount',
      this,
    );
  }

  late final EmergencyRequestUpdateTable updateTable;

  /// FK to user_profiles.id — the citizen who created this request.
  late final _is.ColumnInt requesterId;

  /// Emergency category: medical | accident | fire | rescue | missing | other
  late final _is.ColumnString type;

  /// Free-text description from the citizen.
  late final _is.ColumnString description;

  /// Location latitude where help is needed.
  late final _is.ColumnDouble latitude;

  /// Location longitude where help is needed.
  late final _is.ColumnDouble longitude;

  /// Priority level: low | medium | high | critical
  late final _is.ColumnString priority;

  /// Lifecycle status: pending | matching | assigned | accepted | enRoute | arrived | resolved | cancelled
  late final _is.ColumnString status;

  /// When the request was created.
  late final _is.ColumnDateTime createdAt;

  /// When the request was last updated (any status change).
  late final _is.ColumnDateTime updatedAt;

  /// When a responder accepted the assignment.
  late final _is.ColumnDateTime acceptedAt;

  /// When the responder marked themselves as arrived.
  late final _is.ColumnDateTime arrivedAt;

  /// When the emergency was resolved.
  late final _is.ColumnDateTime resolvedAt;

  /// FK to responder_profiles.id — set when a responder is matched.
  late final _is.ColumnInt assignedResponderId;

  /// Client-generated UUID to prevent duplicate submissions on retry.
  late final _is.ColumnString idempotencyKey;

  /// Human-readable cancellation or rejection reason, if applicable.
  late final _is.ColumnString cancellationReason;

  /// Number of times the matching algorithm has been retried.
  late final _is.ColumnInt matchingRetryCount;

  @override
  List<_is.Column> get columns => [
    id,
    requesterId,
    type,
    description,
    latitude,
    longitude,
    priority,
    status,
    createdAt,
    updatedAt,
    acceptedAt,
    arrivedAt,
    resolvedAt,
    assignedResponderId,
    idempotencyKey,
    cancellationReason,
    matchingRetryCount,
  ];
}

class EmergencyRequestInclude extends _is.IncludeObject {
  EmergencyRequestInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => EmergencyRequest.t;
}

class EmergencyRequestIncludeList extends _is.IncludeList {
  EmergencyRequestIncludeList._({
    _is.WhereExpressionBuilder<EmergencyRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EmergencyRequest.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => EmergencyRequest.t;
}

class EmergencyRequestRepository {
  const EmergencyRequestRepository._();

  /// Returns a list of [EmergencyRequest]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<EmergencyRequest>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EmergencyRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EmergencyRequestTable>? orderBy,
    _is.OrderByListBuilder<EmergencyRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EmergencyRequest>(
      where: where?.call(EmergencyRequest.t),
      orderBy: orderBy?.call(EmergencyRequest.t),
      orderByList: orderByList?.call(EmergencyRequest.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EmergencyRequest] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<EmergencyRequest?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EmergencyRequestTable>? where,
    int? offset,
    _is.OrderByBuilder<EmergencyRequestTable>? orderBy,
    _is.OrderByListBuilder<EmergencyRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EmergencyRequest>(
      where: where?.call(EmergencyRequest.t),
      orderBy: orderBy?.call(EmergencyRequest.t),
      orderByList: orderByList?.call(EmergencyRequest.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EmergencyRequest] by its [id] or null if no such row exists.
  Future<EmergencyRequest?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EmergencyRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EmergencyRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [EmergencyRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EmergencyRequest>> insert(
    _is.DatabaseSession session,
    List<EmergencyRequest> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<EmergencyRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [EmergencyRequest] and returns the inserted row.
  ///
  /// The returned [EmergencyRequest] will have its `id` field set.
  Future<EmergencyRequest> insertRow(
    _is.DatabaseSession session,
    EmergencyRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<EmergencyRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [EmergencyRequest]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [EmergencyRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EmergencyRequest>> upsert(
    _is.DatabaseSession session,
    List<EmergencyRequest> rows, {
    required _is.ColumnSelections<EmergencyRequestTable> conflictColumns,
    _is.ColumnSelections<EmergencyRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<EmergencyRequestTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<EmergencyRequest>(
      rows,
      conflictColumns: conflictColumns(EmergencyRequest.t),
      updateColumns: updateColumns?.call(EmergencyRequest.t),
      updateWhere: updateWhere?.call(EmergencyRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [EmergencyRequest] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [EmergencyRequest] will have its `id` field set.
  Future<EmergencyRequest?> upsertRow(
    _is.DatabaseSession session,
    EmergencyRequest row, {
    required _is.ColumnSelections<EmergencyRequestTable> conflictColumns,
    _is.ColumnSelections<EmergencyRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<EmergencyRequestTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<EmergencyRequest>(
      row,
      conflictColumns: conflictColumns(EmergencyRequest.t),
      updateColumns: updateColumns?.call(EmergencyRequest.t),
      updateWhere: updateWhere?.call(EmergencyRequest.t),
      transaction: transaction,
    );
  }

  /// Updates all [EmergencyRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EmergencyRequest>> update(
    _is.DatabaseSession session,
    List<EmergencyRequest> rows, {
    _is.ColumnSelections<EmergencyRequestTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<EmergencyRequest>(
      rows,
      columns: columns?.call(EmergencyRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [EmergencyRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EmergencyRequest> updateRow(
    _is.DatabaseSession session,
    EmergencyRequest row, {
    _is.ColumnSelections<EmergencyRequestTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<EmergencyRequest>(
      row,
      columns: columns?.call(EmergencyRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EmergencyRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EmergencyRequest?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<EmergencyRequestUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<EmergencyRequest>(
      id,
      columnValues: columnValues(EmergencyRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EmergencyRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EmergencyRequest>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EmergencyRequestUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<EmergencyRequestTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EmergencyRequestTable>? orderBy,
    _is.OrderByListBuilder<EmergencyRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<EmergencyRequest>(
      columnValues: columnValues(EmergencyRequest.t.updateTable),
      where: where(EmergencyRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmergencyRequest.t),
      orderByList: orderByList?.call(EmergencyRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [EmergencyRequest]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EmergencyRequest>> delete(
    _is.DatabaseSession session,
    List<EmergencyRequest> rows, {
    _is.OrderByBuilder<EmergencyRequestTable>? orderBy,
    _is.OrderByListBuilder<EmergencyRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<EmergencyRequest>(
      rows,
      orderBy: orderBy?.call(EmergencyRequest.t),
      orderByList: orderByList?.call(EmergencyRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [EmergencyRequest].
  Future<EmergencyRequest> deleteRow(
    _is.DatabaseSession session,
    EmergencyRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EmergencyRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EmergencyRequest>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EmergencyRequestTable> where,
    _is.OrderByBuilder<EmergencyRequestTable>? orderBy,
    _is.OrderByListBuilder<EmergencyRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<EmergencyRequest>(
      where: where(EmergencyRequest.t),
      orderBy: orderBy?.call(EmergencyRequest.t),
      orderByList: orderByList?.call(EmergencyRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EmergencyRequestTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<EmergencyRequest>(
      where: where?.call(EmergencyRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EmergencyRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EmergencyRequestTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EmergencyRequest>(
      where: where(EmergencyRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
