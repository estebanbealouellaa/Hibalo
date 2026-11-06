import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../learning/sync/firestore_progress_cloud.dart';
import 'translation_store.dart';

/// Why an account change failed (shown as a field error or a snackbar).
enum AccountProblem { wrongPassword, emailInUse, invalidEmail, weakPassword, network, tooManyTries, other }

class AccountException implements Exception {
  const AccountException(this.problem);

  final AccountProblem problem;

  static AccountException from(Object e) {
    if (e is AccountException) return e;
    if (e is FirebaseAuthException) {
      return AccountException(switch (e.code) {
        'wrong-password' || 'invalid-credential' || 'user-mismatch' => AccountProblem.wrongPassword,
        'email-already-in-use' => AccountProblem.emailInUse,
        'invalid-email' => AccountProblem.invalidEmail,
        'weak-password' => AccountProblem.weakPassword,
        'network-request-failed' => AccountProblem.network,
        'too-many-requests' => AccountProblem.tooManyTries,
        _ => AccountProblem.other,
      });
    }
    return const AccountException(AccountProblem.other);
  }

  @override
  String toString() => 'AccountException($problem)';
}

/// What Edit profile can do with the account. [FirebaseAccount] is the real
/// one; tests use a fake.
abstract class AccountActions {
  String? get email;

  /// Saves the username and avatar ("asset:avatarN").
  Future<void> saveProfile(String username, String photoUrl);

  /// Checks the current password (Firebase re-authentication).
  Future<void> confirmPassword(String password);

  /// Sends the "verify your new email" link. The email changes after the
  /// link is opened; [syncEmail] then copies it to users/{uid}.
  Future<void> changeEmail(String newEmail);

  Future<void> changePassword(String newPassword);

  /// Deletes progress, users/{uid}, the Firebase account, then History and Saved on the phone; call [confirmPassword] first.
  Future<void> deleteAccount();
}

class FirebaseAccount implements AccountActions {
  const FirebaseAccount();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  User get _user {
    final user = _auth.currentUser;
    if (user == null) throw const AccountException(AccountProblem.other);
    return user;
  }

  @override
  String? get email {
    try {
      return _auth.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(String username, String photoUrl) async {
    final user = _user;
    try {
      await user.updateDisplayName(username);
      try {
        await user.updatePhotoURL(photoUrl);
      } catch (e) {
        // The Firestore value below is the one the app reads.
        debugPrint('[Account] photoURL not updated: $e');
      }
      await _db.collection('users').doc(user.uid).set({
        'username': username,
        'photoUrl': photoUrl,
      }, SetOptions(merge: true));
      await user.reload();
    } catch (e) {
      throw AccountException.from(e);
    }
  }

  @override
  Future<void> confirmPassword(String password) async {
    final user = _user;
    try {
      await user.reauthenticateWithCredential(EmailAuthProvider.credential(email: user.email ?? '', password: password));
    } catch (e) {
      throw AccountException.from(e);
    }
  }

  @override
  Future<void> changeEmail(String newEmail) async {
    try {
      await _user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      throw AccountException.from(e);
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      await _user.updatePassword(newPassword);
    } catch (e) {
      throw AccountException.from(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _user;
    final uid = user.uid;
    try {
      // Progress first, then users/{uid} in the last batch (as the admin
      // "Delete user"), then the sign-in account.
      await FirestoreProgressCloud.deleteLearningDocs(
        _db,
        uid,
        also: (batch) => batch.delete(_db.collection('users').doc(uid)),
      );
      await user.delete();
    } catch (e) {
      throw AccountException.from(e);
    }
    await TranslationStore.instance.deleteUserData(uid);
  }
}

/// After an email change is verified, users/{uid} still has the old email:
/// copy the sign-in email there (on start and after signing in).
Future<void> syncEmail() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.reload();
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) return;
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final saved = (await doc.get()).data()?['email'];
    if (saved != email) await doc.set({'email': email}, SetOptions(merge: true));
  } catch (e) {
    debugPrint('[Account] email not synced: $e');
  }
}
