import 'package:firebase_auth/firebase_auth.dart';

/// Service class for handling Firebase Authentication operations.
/// This service provides methods for user signup, login, logout, and session management.
class AuthService {
  /// Instance of FirebaseAuth for authentication operations.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Stream of authentication state changes.
  /// Emits null when user is logged out, or a User object when logged in.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get the currently authenticated user.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign up a new user with email and password.
  /// 
  /// Parameters:
  /// - [email]: The user's email address.
  /// - [password]: The user's password (should be at least 6 characters).
  /// 
  /// Returns: The newly created User object.
  /// 
  /// Throws: FirebaseAuthException with specific error codes:
  /// - 'weak-password': Password is too weak.
  /// - 'email-already-in-use': Email is already registered.
  /// - 'invalid-email': Email format is invalid.
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  /// Sign in an existing user with email and password.
  /// 
  /// Parameters:
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  /// 
  /// Returns: The authenticated User object.
  /// 
  /// Throws: FirebaseAuthException with specific error codes:
  /// - 'user-not-found': No user found with this email.
  /// - 'wrong-password': Password is incorrect.
  /// - 'invalid-email': Email format is invalid.
  /// - 'user-disabled': User account has been disabled.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  /// Sign out the currently authenticated user.
  /// 
  /// Returns: A Future that completes when the user is signed out.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  /// Check if a user is currently authenticated.
  /// 
  /// Returns: true if a user is logged in, false otherwise.
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Get the email of the currently authenticated user.
  /// 
  /// Returns: The user's email, or null if no user is logged in.
  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }

  /// Get the UID of the currently authenticated user.
  /// 
  /// Returns: The user's UID, or null if no user is logged in.
  String? getCurrentUserUid() {
    return _firebaseAuth.currentUser?.uid;
  }
}
