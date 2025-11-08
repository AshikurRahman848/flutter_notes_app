import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/src/services/auth_service.dart';

/// Provider class for managing authentication state.
/// This class extends ChangeNotifier to provide reactive state management using Provider.
/// It handles user authentication, session persistence, and error states.
class AuthProvider extends ChangeNotifier {
  /// Instance of AuthService for Firebase operations.
  final AuthService _authService = AuthService();

  /// The currently authenticated user, or null if not logged in.
  User? _user;

  /// Flag indicating if an authentication operation is in progress.
  bool _isLoading = false;

  /// Error message from the last failed authentication operation.
  String? _errorMessage;

  /// Getters for accessing state from the UI.
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  String? get userEmail => _user?.email;

  /// Constructor that initializes the provider and sets up auth state listener.
  AuthProvider() {
    _initializeAuthState();
  }

  /// Initialize authentication state by listening to Firebase auth changes.
  /// This ensures the user stays logged in after app restart.
  void _initializeAuthState() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Clear any error messages.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign up a new user with email and password.
  /// 
  /// Parameters:
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  /// 
  /// Returns: true if signup was successful, false otherwise.
  /// Error details are stored in [_errorMessage].
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
      );
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in an existing user with email and password.
  /// 
  /// Parameters:
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  /// 
  /// Returns: true if login was successful, false otherwise.
  /// Error details are stored in [_errorMessage].
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out the currently authenticated user.
  /// 
  /// Returns: true if logout was successful, false otherwise.
  Future<bool> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to sign out. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Convert Firebase Auth error codes to user-friendly error messages.
  /// 
  /// Parameters:
  /// - [errorCode]: The Firebase Auth error code.
  /// 
  /// Returns: A user-friendly error message.
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'An error occurred: $errorCode. Please try again.';
    }
  }
}
