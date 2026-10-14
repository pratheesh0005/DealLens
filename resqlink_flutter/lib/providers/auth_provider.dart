import 'package:flutter/foundation.dart';
import 'package:resqlink_client/resqlink_client.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart';
import '../client.dart';

/// Real authentication provider managing Serverpod session and user profile.
class AuthProvider extends ChangeNotifier {
  UserProfile? _currentProfile;
  ResponderProfile? _currentResponderProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get currentProfile => _currentProfile;
  ResponderProfile? get currentResponderProfile => _currentResponderProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated =>
      sessionManager.isSignedIn && _currentProfile != null;
  String get activeRole => _currentProfile?.role ?? 'citizen';
  int get activeUserId => _currentProfile?.userId ?? 0;
  String get activeDisplayName => _currentProfile?.displayName ?? '';
  String get activeEmail => _currentProfile?.email ?? '';
  String? get activePhone => _currentProfile?.phone;

  /// Initialize and restore existing session from storage if present.
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (sessionManager.isSignedIn) {
        final profile = await client.user.getMyProfile();
        if (profile != null) {
          _currentProfile = profile;
          if (profile.role == 'responder') {
            _currentResponderProfile = await client.responder
                .getMyResponderProfile();
          }
        } else {
          // Stale session
          await sessionManager.signOutDevice();
          _currentProfile = null;
          _currentResponderProfile = null;
        }
      }
    } catch (e) {
      debugPrint('Error restoring auth session: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in or register with email, name, role, and optional phone.
  Future<bool> authenticate({
    required String email,
    required String displayName,
    required String role,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await client.user.authenticate(
        email: email.trim(),
        displayName: displayName.trim(),
        role: role.trim(),
        phone: phone?.trim(),
      );

      final userInfo = UserInfo(
        id: response.userId,
        userIdentifier: response.profile.email,
        userName: response.profile.displayName,
        email: response.profile.email,
        created: response.profile.createdAt,
        scopeNames: [response.profile.role],
        blocked: false,
      );

      await sessionManager.registerSignedInUser(
        userInfo,
        response.keyId,
        response.key,
      );

      _currentProfile = response.profile;
      if (response.profile.role == 'responder') {
        _currentResponderProfile = await client.responder
            .getMyResponderProfile();
      } else {
        _currentResponderProfile = null;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Authentication failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out the current user session from device.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await sessionManager.signOutDevice();
      _currentProfile = null;
      _currentResponderProfile = null;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh responder profile state.
  void updateResponderProfile(ResponderProfile? profile) {
    _currentResponderProfile = profile;
    notifyListeners();
  }
}
