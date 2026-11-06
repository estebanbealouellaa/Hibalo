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
        await _updateLastActive(uid);
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

  Future<void> refreshAdminRole(String uid) async {
    await _checkAdminRole(uid);
    await _updateLastActive(uid);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }

  Future<void> _checkAdminRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      _isAdmin = doc.data()?['role'] == 'admin';
    } catch (_) {
      _isAdmin = false;
    }
  }

  Future<void> _updateLastActive(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastActive': Timestamp.now(),
      });
    } catch (_) {}
  }
}
