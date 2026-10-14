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

/// ResQLink EmergencyStatusEvent — immutable audit log of every status change.
/// Created by the server on every status transition; never deleted.
abstract class EmergencyStatusEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = EmergencyStatusEventTable();

  static const db = EmergencyStatusEventRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [EmergencyStatusEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static EmergencyStatusEventInclude include() {
    return EmergencyStatusEventInclude._();
  }

  static EmergencyStatusEventIncludeList includeList({
    _is.WhereExpressionBuilder<EmergencyStatusEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EmergencyStatusEventTable>? orderBy,
    _is.OrderByListBuilder<EmergencyStatusEventTable>? orderByList,
    EmergencyStatusEventInclude? include,
  }) {
    return EmergencyStatusEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmergencyStatusEvent.t),
      orderByList: orderByList?.call(EmergencyStatusEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class EmergencyStatusEventUpdateTable
    extends _is.UpdateTable<EmergencyStatusEventTable> {
  EmergencyStatusEventUpdateTable(super.table);

  _is.ColumnValue<int, int> emergencyId(int value) => _is.ColumnValue(
    table.emergencyId,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> actorId(int value) => _is.ColumnValue(
    table.actorId,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class EmergencyStatusEventTable extends _is.Table<int?> {
  EmergencyStatusEventTable({super.tableRelation})
    : super(tableName: 'emergency_status_events') {
    updateTable = EmergencyStatusEventUpdateTable(this);
    emergencyId = _is.ColumnInt(
      'emergencyId',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    actorId = _is.ColumnInt(
      'actorId',
      this,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final EmergencyStatusEventUpdateTable updateTable;

  /// FK to emergency_requests.id
  late final _is.ColumnInt emergencyId;

  /// The new status after this transition.
  late final _is.ColumnString status;

  /// The userId (from user_profiles) who triggered this change.
  late final _is.ColumnInt actorId;

  /// Optional human-readable note (e.g. "Responder declined: too far").
  late final _is.ColumnString note;

  /// When this event was recorded.
  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    emergencyId,
    status,
    actorId,
    note,
    createdAt,
  ];
}

class EmergencyStatusEventInclude extends _is.IncludeObject {
  EmergencyStatusEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => EmergencyStatusEvent.t;
}

class EmergencyStatusEventIncludeList extends _is.IncludeList {
  EmergencyStatusEventIncludeList._({
    _is.WhereExpressionBuilder<EmergencyStatusEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EmergencyStatusEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => EmergencyStatusEvent.t;
}

class EmergencyStatusEventRepository {
  const EmergencyStatusEventRepository._();

  /// Returns a list of [EmergencyStatusEvent]s matching the given query parameters.
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
  Future<List<EmergencyStatusEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EmergencyStatusEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EmergencyStatusEventTable>? orderBy,
    _is.OrderByListBuilder<EmergencyStatusEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EmergencyStatusEvent>(
      where: where?.call(EmergencyStatusEvent.t),
      orderBy: orderBy?.call(EmergencyStatusEvent.t),
      orderByList: orderByList?.call(EmergencyStatusEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EmergencyStatusEvent] matching the given query parameters.
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
  Future<EmergencyStatusEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EmergencyStatusEventTable>? where,
    int? offset,
    _is.OrderByBuilder<EmergencyStatusEventTable>? orderBy,
    _is.OrderByListBuilder<EmergencyStatusEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EmergencyStatusEvent>(
      where: where?.call(EmergencyStatusEvent.t),
      orderBy: orderBy?.call(EmergencyStatusEvent.t),
      orderByList: orderByList?.call(EmergencyStatusEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EmergencyStatusEvent] by its [id] or null if no such row exists.
  Future<EmergencyStatusEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EmergencyStatusEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EmergencyStatusEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [EmergencyStatusEvent]s will have their `id` fields set.
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
  Future<List<EmergencyStatusEvent>> insert(
    _is.DatabaseSession session,
    List<EmergencyStatusEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<EmergencyStatusEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [EmergencyStatusEvent] and returns the inserted row.
  ///
  /// The returned [EmergencyStatusEvent] will have its `id` field set.
  Future<EmergencyStatusEvent> insertRow(
    _is.DatabaseSession session,
    EmergencyStatusEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<EmergencyStatusEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [EmergencyStatusEvent]s in the list and returns the resulting rows.
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
  /// The returned [EmergencyStatusEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EmergencyStatusEvent>> upsert(
    _is.DatabaseSession session,
    List<EmergencyStatusEvent> rows, {
    required _is.ColumnSelections<EmergencyStatusEventTable> conflictColumns,
    _is.ColumnSelections<EmergencyStatusEventTable>? updateColumns,
    _is.WhereExpressionBuilder<EmergencyStatusEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<EmergencyStatusEvent>(
      rows,
      conflictColumns: conflictColumns(EmergencyStatusEvent.t),
      updateColumns: updateColumns?.call(EmergencyStatusEvent.t),
      updateWhere: updateWhere?.call(EmergencyStatusEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [EmergencyStatusEvent] and returns the resulting row.
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
  /// The returned [EmergencyStatusEvent] will have its `id` field set.
  Future<EmergencyStatusEvent?> upsertRow(
    _is.DatabaseSession session,
    EmergencyStatusEvent row, {
    required _is.ColumnSelections<EmergencyStatusEventTable> conflictColumns,
    _is.ColumnSelections<EmergencyStatusEventTable>? updateColumns,
    _is.WhereExpressionBuilder<EmergencyStatusEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<EmergencyStatusEvent>(
      row,
      conflictColumns: conflictColumns(EmergencyStatusEvent.t),
      updateColumns: updateColumns?.call(EmergencyStatusEvent.t),
      updateWhere: updateWhere?.call(EmergencyStatusEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [EmergencyStatusEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EmergencyStatusEvent>> update(
    _is.DatabaseSession session,
    List<EmergencyStatusEvent> rows, {
    _is.ColumnSelections<EmergencyStatusEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<EmergencyStatusEvent>(
      rows,
      columns: columns?.call(EmergencyStatusEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [EmergencyStatusEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EmergencyStatusEvent> updateRow(
    _is.DatabaseSession session,
    EmergencyStatusEvent row, {
    _is.ColumnSelections<EmergencyStatusEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<EmergencyStatusEvent>(
      row,
      columns: columns?.call(EmergencyStatusEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EmergencyStatusEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EmergencyStatusEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<EmergencyStatusEventUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<EmergencyStatusEvent>(
      id,
      columnValues: columnValues(EmergencyStatusEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EmergencyStatusEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EmergencyStatusEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EmergencyStatusEventUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<EmergencyStatusEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EmergencyStatusEventTable>? orderBy,
    _is.OrderByListBuilder<EmergencyStatusEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<EmergencyStatusEvent>(
      columnValues: columnValues(EmergencyStatusEvent.t.updateTable),
      where: where(EmergencyStatusEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmergencyStatusEvent.t),
      orderByList: orderByList?.call(EmergencyStatusEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [EmergencyStatusEvent]s in the list and returns the deleted rows.
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
  Future<List<EmergencyStatusEvent>> delete(
    _is.DatabaseSession session,
    List<EmergencyStatusEvent> rows, {
    _is.OrderByBuilder<EmergencyStatusEventTable>? orderBy,
    _is.OrderByListBuilder<EmergencyStatusEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<EmergencyStatusEvent>(
      rows,
      orderBy: orderBy?.call(EmergencyStatusEvent.t),
      orderByList: orderByList?.call(EmergencyStatusEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [EmergencyStatusEvent].
  Future<EmergencyStatusEvent> deleteRow(
    _is.DatabaseSession session,
    EmergencyStatusEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EmergencyStatusEvent>(
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
  Future<List<EmergencyStatusEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EmergencyStatusEventTable> where,
    _is.OrderByBuilder<EmergencyStatusEventTable>? orderBy,
    _is.OrderByListBuilder<EmergencyStatusEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<EmergencyStatusEvent>(
      where: where(EmergencyStatusEvent.t),
      orderBy: orderBy?.call(EmergencyStatusEvent.t),
      orderByList: orderByList?.call(EmergencyStatusEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EmergencyStatusEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<EmergencyStatusEvent>(
      where: where?.call(EmergencyStatusEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EmergencyStatusEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EmergencyStatusEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EmergencyStatusEvent>(
      where: where(EmergencyStatusEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
