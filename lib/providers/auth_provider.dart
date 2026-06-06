import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  // ─────────────────────────────────────────────────
  // Sign Up — unchanged from your original
  // ─────────────────────────────────────────────────
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': name,
          'email': email,
          'role': 'user',
          'createdAt': Timestamp.now(),
          'lastActive': Timestamp.now(),
        });
      }

      _isAdmin = false;
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────
  // Sign In — checks role after login
  // ─────────────────────────────────────────────────
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
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

      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    _isAdmin = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────
  // Called by main.dart on splash (already logged in)
  // and after onAuthSuccess so isAdmin is always fresh
  // ─────────────────────────────────────────────────
  Future<void> refreshAdminRole(String uid) async {
    await _checkAdminRole(uid);
    await _updateLastActive(uid);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────
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
