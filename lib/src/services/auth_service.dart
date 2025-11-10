import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;
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
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }
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
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }
  String? getCurrentUserUid() {
    return _firebaseAuth.currentUser?.uid;
  }
}
