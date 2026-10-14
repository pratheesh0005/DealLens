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

/// ResQLink ResponderProfile — availability and capability info for responders.
/// Each row corresponds to a UserProfile with role=responder.
abstract class ResponderProfile
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      isAvailable: _is.BoolJsonExtension.fromJson(
        jsonSerialization['isAvailable'],
      ),
      capabilities: jsonSerialization['capabilities'] as String,
      currentLat: (jsonSerialization['currentLat'] as num?)?.toDouble(),
      currentLng: (jsonSerialization['currentLng'] as num?)?.toDouble(),
      lastLocationUpdate: jsonSerialization['lastLocationUpdate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastLocationUpdate'],
            ),
      activeEmergencyId: jsonSerialization['activeEmergencyId'] as int?,
      totalResponseCount: jsonSerialization['totalResponseCount'] as int,
      lastAssignedAt: jsonSerialization['lastAssignedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastAssignedAt'],
            ),
    );
  }

  static final t = ResponderProfileTable();

  static const db = ResponderProfileRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ResponderProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static ResponderProfileInclude include() {
    return ResponderProfileInclude._();
  }

  static ResponderProfileIncludeList includeList({
    _is.WhereExpressionBuilder<ResponderProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ResponderProfileTable>? orderBy,
    _is.OrderByListBuilder<ResponderProfileTable>? orderByList,
    ResponderProfileInclude? include,
  }) {
    return ResponderProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ResponderProfile.t),
      orderByList: orderByList?.call(ResponderProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class ResponderProfileUpdateTable
    extends _is.UpdateTable<ResponderProfileTable> {
  ResponderProfileUpdateTable(super.table);

  _is.ColumnValue<int, int> userProfileId(int value) => _is.ColumnValue(
    table.userProfileId,
    value,
  );

  _is.ColumnValue<bool, bool> isAvailable(bool value) => _is.ColumnValue(
    table.isAvailable,
    value,
  );

  _is.ColumnValue<String, String> capabilities(String value) => _is.ColumnValue(
    table.capabilities,
    value,
  );

  _is.ColumnValue<double, double> currentLat(double? value) => _is.ColumnValue(
    table.currentLat,
    value,
  );

  _is.ColumnValue<double, double> currentLng(double? value) => _is.ColumnValue(
    table.currentLng,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastLocationUpdate(DateTime? value) =>
      _is.ColumnValue(
        table.lastLocationUpdate,
        value,
      );

  _is.ColumnValue<int, int> activeEmergencyId(int? value) => _is.ColumnValue(
    table.activeEmergencyId,
    value,
  );

  _is.ColumnValue<int, int> totalResponseCount(int value) => _is.ColumnValue(
    table.totalResponseCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastAssignedAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastAssignedAt,
        value,
      );
}

class ResponderProfileTable extends _is.Table<int?> {
  ResponderProfileTable({super.tableRelation})
    : super(tableName: 'responder_profiles') {
    updateTable = ResponderProfileUpdateTable(this);
    userProfileId = _is.ColumnInt(
      'userProfileId',
      this,
    );
    isAvailable = _is.ColumnBool(
      'isAvailable',
      this,
    );
    capabilities = _is.ColumnString(
      'capabilities',
      this,
    );
    currentLat = _is.ColumnDouble(
      'currentLat',
      this,
    );
    currentLng = _is.ColumnDouble(
      'currentLng',
      this,
    );
    lastLocationUpdate = _is.ColumnDateTime(
      'lastLocationUpdate',
      this,
    );
    activeEmergencyId = _is.ColumnInt(
      'activeEmergencyId',
      this,
    );
    totalResponseCount = _is.ColumnInt(
      'totalResponseCount',
      this,
    );
    lastAssignedAt = _is.ColumnDateTime(
      'lastAssignedAt',
      this,
    );
  }

  late final ResponderProfileUpdateTable updateTable;

  /// FK to user_profiles.id
  late final _is.ColumnInt userProfileId;

  /// Whether the responder is currently available to receive requests.
  late final _is.ColumnBool isAvailable;

  /// Comma-separated capability codes: medical,fire,rescue,accident,missing
  late final _is.ColumnString capabilities;

  /// Last known latitude (-90 to 90). Null if not yet set.
  late final _is.ColumnDouble currentLat;

  /// Last known longitude (-180 to 180). Null if not yet set.
  late final _is.ColumnDouble currentLng;

  /// When the location was last updated.
  late final _is.ColumnDateTime lastLocationUpdate;

  /// FK to emergency_requests.id for the active assignment, if any.
  late final _is.ColumnInt activeEmergencyId;

  /// Total number of emergencies this responder has resolved.
  late final _is.ColumnInt totalResponseCount;

  /// Timestamp of the last time this responder was assigned an emergency.
  /// Used for fairness scoring in the matching algorithm.
  late final _is.ColumnDateTime lastAssignedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userProfileId,
    isAvailable,
    capabilities,
    currentLat,
    currentLng,
    lastLocationUpdate,
    activeEmergencyId,
    totalResponseCount,
    lastAssignedAt,
  ];
}

class ResponderProfileInclude extends _is.IncludeObject {
  ResponderProfileInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ResponderProfile.t;
}

class ResponderProfileIncludeList extends _is.IncludeList {
  ResponderProfileIncludeList._({
    _is.WhereExpressionBuilder<ResponderProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ResponderProfile.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ResponderProfile.t;
}

class ResponderProfileRepository {
  const ResponderProfileRepository._();

  /// Returns a list of [ResponderProfile]s matching the given query parameters.
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
  Future<List<ResponderProfile>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ResponderProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ResponderProfileTable>? orderBy,
    _is.OrderByListBuilder<ResponderProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ResponderProfile>(
      where: where?.call(ResponderProfile.t),
      orderBy: orderBy?.call(ResponderProfile.t),
      orderByList: orderByList?.call(ResponderProfile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ResponderProfile] matching the given query parameters.
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
  Future<ResponderProfile?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ResponderProfileTable>? where,
    int? offset,
    _is.OrderByBuilder<ResponderProfileTable>? orderBy,
    _is.OrderByListBuilder<ResponderProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ResponderProfile>(
      where: where?.call(ResponderProfile.t),
      orderBy: orderBy?.call(ResponderProfile.t),
      orderByList: orderByList?.call(ResponderProfile.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ResponderProfile] by its [id] or null if no such row exists.
  Future<ResponderProfile?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ResponderProfile>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ResponderProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [ResponderProfile]s will have their `id` fields set.
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
  Future<List<ResponderProfile>> insert(
    _is.DatabaseSession session,
    List<ResponderProfile> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ResponderProfile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ResponderProfile] and returns the inserted row.
  ///
  /// The returned [ResponderProfile] will have its `id` field set.
  Future<ResponderProfile> insertRow(
    _is.DatabaseSession session,
    ResponderProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ResponderProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ResponderProfile]s in the list and returns the resulting rows.
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
  /// The returned [ResponderProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ResponderProfile>> upsert(
    _is.DatabaseSession session,
    List<ResponderProfile> rows, {
    required _is.ColumnSelections<ResponderProfileTable> conflictColumns,
    _is.ColumnSelections<ResponderProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<ResponderProfileTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ResponderProfile>(
      rows,
      conflictColumns: conflictColumns(ResponderProfile.t),
      updateColumns: updateColumns?.call(ResponderProfile.t),
      updateWhere: updateWhere?.call(ResponderProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ResponderProfile] and returns the resulting row.
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
  /// The returned [ResponderProfile] will have its `id` field set.
  Future<ResponderProfile?> upsertRow(
    _is.DatabaseSession session,
    ResponderProfile row, {
    required _is.ColumnSelections<ResponderProfileTable> conflictColumns,
    _is.ColumnSelections<ResponderProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<ResponderProfileTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ResponderProfile>(
      row,
      conflictColumns: conflictColumns(ResponderProfile.t),
      updateColumns: updateColumns?.call(ResponderProfile.t),
      updateWhere: updateWhere?.call(ResponderProfile.t),
      transaction: transaction,
    );
  }

  /// Updates all [ResponderProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ResponderProfile>> update(
    _is.DatabaseSession session,
    List<ResponderProfile> rows, {
    _is.ColumnSelections<ResponderProfileTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ResponderProfile>(
      rows,
      columns: columns?.call(ResponderProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ResponderProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ResponderProfile> updateRow(
    _is.DatabaseSession session,
    ResponderProfile row, {
    _is.ColumnSelections<ResponderProfileTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ResponderProfile>(
      row,
      columns: columns?.call(ResponderProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ResponderProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ResponderProfile?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ResponderProfileUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ResponderProfile>(
      id,
      columnValues: columnValues(ResponderProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ResponderProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ResponderProfile>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ResponderProfileUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ResponderProfileTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ResponderProfileTable>? orderBy,
    _is.OrderByListBuilder<ResponderProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ResponderProfile>(
      columnValues: columnValues(ResponderProfile.t.updateTable),
      where: where(ResponderProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ResponderProfile.t),
      orderByList: orderByList?.call(ResponderProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ResponderProfile]s in the list and returns the deleted rows.
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
  Future<List<ResponderProfile>> delete(
    _is.DatabaseSession session,
    List<ResponderProfile> rows, {
    _is.OrderByBuilder<ResponderProfileTable>? orderBy,
    _is.OrderByListBuilder<ResponderProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ResponderProfile>(
      rows,
      orderBy: orderBy?.call(ResponderProfile.t),
      orderByList: orderByList?.call(ResponderProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ResponderProfile].
  Future<ResponderProfile> deleteRow(
    _is.DatabaseSession session,
    ResponderProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ResponderProfile>(
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
  Future<List<ResponderProfile>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ResponderProfileTable> where,
    _is.OrderByBuilder<ResponderProfileTable>? orderBy,
    _is.OrderByListBuilder<ResponderProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ResponderProfile>(
      where: where(ResponderProfile.t),
      orderBy: orderBy?.call(ResponderProfile.t),
      orderByList: orderByList?.call(ResponderProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ResponderProfileTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ResponderProfile>(
      where: where?.call(ResponderProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ResponderProfile] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ResponderProfileTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ResponderProfile>(
      where: where(ResponderProfile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
