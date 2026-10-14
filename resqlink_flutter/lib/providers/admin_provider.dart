import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:resqlink_client/resqlink_client.dart';
import '../client.dart';

class AdminProvider extends ChangeNotifier {
  AdminStats? _stats;
  List<EmergencyRequest> _emergencies = [];
  List<ResponderProfile> _responders = [];
  String? _selectedStatusFilter;
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _refreshTimer;

  AdminStats? get stats => _stats;
  List<EmergencyRequest> get emergencies => _emergencies;
  List<ResponderProfile> get responders => _responders;
  String? get selectedStatusFilter => _selectedStatusFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Start auto-refreshing dashboard KPIs and incident list.
  void startDashboardUpdates() {
    refreshAll();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      refreshAll(silent: true);
    });
  }

  /// Refresh statistics, incidents, and responder list.
  Future<void> refreshAll({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final statsFuture = client.admin.getDashboardStats();
      final emergenciesFuture = client.admin.getAllEmergencies(
        status: _selectedStatusFilter,
        limit: 50,
        offset: 0,
      );
      final respondersFuture = client.admin.getAllResponders();

      final results = await Future.wait([
        statsFuture,
        emergenciesFuture,
        respondersFuture,
      ]);

      _stats = results[0] as AdminStats;
      _emergencies = results[1] as List<EmergencyRequest>;
      _responders = results[2] as List<ResponderProfile>;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Apply status filter (e.g. pending, assigned, enRoute, resolved).
  void setFilter(String? status) {
    _selectedStatusFilter = status;
    refreshAll();
  }

  /// Admin override to force resolve an incident.
  Future<bool> forceResolve(int emergencyId, String reason) async {
    try {
      await client.admin.forceResolveEmergency(
        emergencyId: emergencyId,
        reason: reason,
      );
      await refreshAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
