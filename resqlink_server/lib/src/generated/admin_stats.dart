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

/// ResQLink AdminStats — non-DB serializable DTO for the admin dashboard.
/// Returned by AdminEndpoint.getDashboardStats(). No database table.
abstract class AdminStats
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AdminStats._({
    required this.pendingCount,
    required this.activeCount,
    required this.resolvedTodayCount,
    required this.cancelledTodayCount,
    required this.availableResponderCount,
    required this.activeResponderCount,
    required this.totalCitizens,
    required this.totalResponders,
  });

  factory AdminStats({
    required int pendingCount,
    required int activeCount,
    required int resolvedTodayCount,
    required int cancelledTodayCount,
    required int availableResponderCount,
    required int activeResponderCount,
    required int totalCitizens,
    required int totalResponders,
  }) = _AdminStatsImpl;

  factory AdminStats.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminStats(
      pendingCount: jsonSerialization['pendingCount'] as int,
      activeCount: jsonSerialization['activeCount'] as int,
      resolvedTodayCount: jsonSerialization['resolvedTodayCount'] as int,
      cancelledTodayCount: jsonSerialization['cancelledTodayCount'] as int,
      availableResponderCount:
          jsonSerialization['availableResponderCount'] as int,
      activeResponderCount: jsonSerialization['activeResponderCount'] as int,
      totalCitizens: jsonSerialization['totalCitizens'] as int,
      totalResponders: jsonSerialization['totalResponders'] as int,
    );
  }

  /// Total emergencies currently in status=pending or status=matching.
  int pendingCount;

  /// Total emergencies currently in status=assigned, accepted, enRoute, or arrived.
  int activeCount;

  /// Total emergencies resolved today (UTC).
  int resolvedTodayCount;

  /// Total emergencies cancelled today (UTC).
  int cancelledTodayCount;

  /// Number of responders with isAvailable=true and no activeEmergencyId.
  int availableResponderCount;

  /// Number of responders currently handling an active emergency.
  int activeResponderCount;

  /// Total registered citizens.
  int totalCitizens;

  /// Total registered responders.
  int totalResponders;

  /// Returns a shallow copy of this [AdminStats]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AdminStats copyWith({
    int? pendingCount,
    int? activeCount,
    int? resolvedTodayCount,
    int? cancelledTodayCount,
    int? availableResponderCount,
    int? activeResponderCount,
    int? totalCitizens,
    int? totalResponders,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminStats',
      'pendingCount': pendingCount,
      'activeCount': activeCount,
      'resolvedTodayCount': resolvedTodayCount,
      'cancelledTodayCount': cancelledTodayCount,
      'availableResponderCount': availableResponderCount,
      'activeResponderCount': activeResponderCount,
      'totalCitizens': totalCitizens,
      'totalResponders': totalResponders,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminStats',
      'pendingCount': pendingCount,
      'activeCount': activeCount,
      'resolvedTodayCount': resolvedTodayCount,
      'cancelledTodayCount': cancelledTodayCount,
      'availableResponderCount': availableResponderCount,
      'activeResponderCount': activeResponderCount,
      'totalCitizens': totalCitizens,
      'totalResponders': totalResponders,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AdminStatsImpl extends AdminStats {
  _AdminStatsImpl({
    required int pendingCount,
    required int activeCount,
    required int resolvedTodayCount,
    required int cancelledTodayCount,
    required int availableResponderCount,
    required int activeResponderCount,
    required int totalCitizens,
    required int totalResponders,
  }) : super._(
         pendingCount: pendingCount,
         activeCount: activeCount,
         resolvedTodayCount: resolvedTodayCount,
         cancelledTodayCount: cancelledTodayCount,
         availableResponderCount: availableResponderCount,
         activeResponderCount: activeResponderCount,
         totalCitizens: totalCitizens,
         totalResponders: totalResponders,
       );

  /// Returns a shallow copy of this [AdminStats]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AdminStats copyWith({
    int? pendingCount,
    int? activeCount,
    int? resolvedTodayCount,
    int? cancelledTodayCount,
    int? availableResponderCount,
    int? activeResponderCount,
    int? totalCitizens,
    int? totalResponders,
  }) {
    return AdminStats(
      pendingCount: pendingCount ?? this.pendingCount,
      activeCount: activeCount ?? this.activeCount,
      resolvedTodayCount: resolvedTodayCount ?? this.resolvedTodayCount,
      cancelledTodayCount: cancelledTodayCount ?? this.cancelledTodayCount,
      availableResponderCount:
          availableResponderCount ?? this.availableResponderCount,
      activeResponderCount: activeResponderCount ?? this.activeResponderCount,
      totalCitizens: totalCitizens ?? this.totalCitizens,
      totalResponders: totalResponders ?? this.totalResponders,
    );
  }
}
