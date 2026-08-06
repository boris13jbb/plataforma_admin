import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Sesión del hub: exige custom claim `hubAdmin`.
class HubSession extends ChangeNotifier {
  HubSession() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  User? _user;
  bool _loading = true;
  bool _isHubAdmin = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  bool get isHubAdmin => _isHubAdmin;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> _onAuth(User? user) async {
    _user = user;
    _error = null;
    _isHubAdmin = false;
    if (user == null) {
      _loading = false;
      notifyListeners();
      return;
    }
    try {
      final token = await user.getIdTokenResult(true);
      _isHubAdmin = token.claims?['hubAdmin'] == true;
      if (!_isHubAdmin) {
        _error =
            'Esta cuenta no tiene rol hubAdmin. Usa bootstrap o pide acceso.';
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? e.code;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  Future<void> refreshClaims() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _loading = true;
    notifyListeners();
    await _onAuth(user);
  }
}
