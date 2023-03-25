import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository() : _firebaseAuth = FirebaseAuth.instance;

  // Stream to keep track of the current user's authentication state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Create a user with email and password
  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        rethrow;
      }
    }
  }

  // Get the current user's ID
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
