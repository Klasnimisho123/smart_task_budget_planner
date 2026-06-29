import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService() : _auth = _createAuth();

  final FirebaseAuth? _auth;

  Future<void> ensureAnonymousSignIn() async {
    if (_auth == null) return;
    if (_auth!.currentUser != null) return;
    await _auth!.signInAnonymously();
  }

  static FirebaseAuth? _createAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }
}
