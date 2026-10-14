import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication Provider managing user session, sign-in, registration, Google sign-in, and sign-out.
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn() {
    _user = _auth.currentUser;
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get displayName {
    if (_user == null) return 'Guest User';
    if (_user!.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }
    if (_user!.email != null && _user!.email!.isNotEmpty) {
      return _user!.email!.split('@').first;
    }
    return 'DealLens User';
  }

  String get email => _user?.email ?? 'Not logged in';

  /// Sign in with Google (Continue with Google)
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the Google sign-in dialog
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create a credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFriendlyAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      final errStr = e.toString();
      if (errStr.contains('10') || errStr.contains('DEVELOPER_ERROR')) {
        _errorMessage =
            'Google Sign-In requires SHA-1 fingerprint added in Firebase Console. You can also sign in with Email or as Guest.';
      } else if (errStr.contains('12500')) {
        _errorMessage =
            'Google Sign-In cancelled or not configured in Firebase Console.';
      } else {
        _errorMessage = 'Google Sign-In failed. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Email and Password (with automatic connection retry)
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    int attempts = 0;
    while (attempts < 2) {
      attempts++;
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        _user = credential.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } on FirebaseAuthException catch (e) {
        final msg = (e.message ?? '').toLowerCase();
        if (attempts < 2 &&
            (msg.contains('unexpected end of stream') ||
                msg.contains('internal error') ||
                e.code == 'network-request-failed')) {
          await Future.delayed(const Duration(milliseconds: 700));
          continue;
        }
        _errorMessage = _getFriendlyAuthErrorMessage(e);
        _isLoading = false;
        notifyListeners();
        return false;
      } catch (e) {
        if (attempts < 2 &&
            e.toString().toLowerCase().contains('unexpected end of stream')) {
          await Future.delayed(const Duration(milliseconds: 700));
          continue;
        }
        _errorMessage =
            'Network issue connecting to Firebase. Please check your internet connection.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Create Account with Name, Email and Password (with automatic retry)
  Future<bool> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    int attempts = 0;
    while (attempts < 2) {
      attempts++;
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        // Update display name
        if (credential.user != null && name.trim().isNotEmpty) {
          await credential.user!.updateDisplayName(name.trim());
          await credential.user!.reload();
          _user = _auth.currentUser;
        } else {
          _user = credential.user;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } on FirebaseAuthException catch (e) {
        final msg = (e.message ?? '').toLowerCase();
        if (attempts < 2 &&
            (msg.contains('unexpected end of stream') ||
                msg.contains('internal error') ||
                e.code == 'network-request-failed')) {
          await Future.delayed(const Duration(milliseconds: 700));
          continue;
        }
        _errorMessage = _getFriendlyAuthErrorMessage(e);
        _isLoading = false;
        notifyListeners();
        return false;
      } catch (e) {
        if (attempts < 2 &&
            e.toString().toLowerCase().contains('unexpected end of stream')) {
          await Future.delayed(const Duration(milliseconds: 700));
          continue;
        }
        _errorMessage =
            'Connection error. Please verify Email/Password is enabled in Firebase Console.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Guest / Anonymous sign-in
  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInAnonymously();
      _user = credential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFriendlyAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Could not sign in as guest. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Password reset email
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFriendlyAuthErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Could not send reset email.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    // 1. Attempt to sign out of Google if active or initialized
    try {
      await _googleSignIn.signOut();
    } catch (googleError) {
      // Safe to ignore: occurs when user is signed in via Email/Password or Guest,
      // where the Pigeon GoogleSignInApi channel was never established.
      debugPrint('Google sign-out bypassed (not active): $googleError');
    }

    // 2. Always sign out of Firebase Auth and clear local user state
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth signOut error: $e');
    } finally {
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getFriendlyAuthErrorMessage(FirebaseAuthException e) {
    final msg = (e.message ?? '').toLowerCase();

    // Catch OkHttp unexpected end of stream or internal errors on Android
    if (msg.contains('unexpected end of stream') ||
        msg.contains('internal error') ||
        e.code == 'internal-error') {
      return "Firebase connection error. Please enable 'Email/Password' in your Firebase Console (Authentication > Sign-in method) or use 'Continue with Google'.";
    }

    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please verify your credentials.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'network-request-failed':
        return 'Network connection issue. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again after a few minutes.';
      case 'operation-not-allowed':
        return "Email/Password sign-in is not enabled in Firebase Console. Please enable it under Authentication > Sign-in method.";
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
