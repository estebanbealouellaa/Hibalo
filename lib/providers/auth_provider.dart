import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../services/language_prompt.dart';

class AuthProvider extends ChangeNotifier {
  // Lazy, so tests can subclass this without a Firebase app.
  late final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Firebase's error code for the last failure (e.g. 'network-request-failed',
  /// 'invalid-credential'), so the screen can pick the right banner.
  String? _errorCode;
  String? get errorCode => _errorCode;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  /// How long the admin-role check waits for the server before using the cached copy.
  /// Offline the server never answers, and the app must still open (it works offline after sign-in).
  static const adminCheckTimeout = Duration(seconds: 5);

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await DatabaseService.createUser(
          uid: user.uid,
          username: name,
          email: email,
        );
        await _checkAdminRole(user.uid);
        // New account: the language pop-up shows once on Home.
        await LanguagePrompt.afterSignUp(user.uid);
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _errorCode = e.code;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        await _checkAdminRole(uid);
        _updateLastActive(uid);
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _errorCode = e.code;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _isAdmin = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// At app start and after sign-in. Never waits on the network for long: the role check gives up after
  /// [adminCheckTimeout] and uses the cached copy, and the lastActive write isn't awaited (Firestore sends it
  /// when the phone is back online; a write's future only completes once the server confirms it).
  Future<void> refreshAdminRole(String uid) async {
    await _checkAdminRole(uid);
    _updateLastActive(uid);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }

  Future<void> _checkAdminRole(String uid) async {
    try {
      final data = await readUserDoc(uid).timeout(adminCheckTimeout);
      _isAdmin = data?['role'] == 'admin';
    } catch (_) {
      // Offline or slow: the copy Firestore keeps on the phone.
      try {
        final cached = await readUserDoc(uid, cacheOnly: true).timeout(adminCheckTimeout);
        _isAdmin = cached?['role'] == 'admin';
      } catch (_) {
        _isAdmin = false;
      }
    }
  }

  /// Fire and forget: errors are ignored and nothing waits for it.
  void _updateLastActive(String uid) {
    unawaited(writeLastActive(uid).catchError((Object _) {}));
  }

  /// users/{uid} from the server (or Firestore's own offline fallback), or only the phone's cache.
  /// Overridden in tests.
  @protected
  Future<Map<String, dynamic>?> readUserDoc(String uid, {bool cacheOnly = false}) async {
    final ref = _firestore.collection('users').doc(uid);
    final doc = await (cacheOnly ? ref.get(const GetOptions(source: Source.cache)) : ref.get());
    return doc.data();
  }

  /// users/{uid}.lastActive = now. Overridden in tests.
  @protected
  Future<void> writeLastActive(String uid) {
    return _firestore.collection('users').doc(uid).update({'lastActive': Timestamp.now()});
  }
}
