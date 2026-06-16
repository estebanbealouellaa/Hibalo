import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime? lastActive;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.role = 'user',
    required this.createdAt,
    this.lastActive,
  });

  // ─────────────────────────────────────────────────
  // For non-Firestore use (e.g. logging, local state)
  // ─────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  // ─────────────────────────────────────────────────
  // From Firestore document
  // ─────────────────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
    );
  }

  // ─────────────────────────────────────────────────
  // Convenience getter
  // ─────────────────────────────────────────────────
  bool get isAdmin => role == 'admin';

  // ─────────────────────────────────────────────────
  // Copy with modified fields
  // ─────────────────────────────────────────────────
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? role,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, username: $username, email: $email, role: $role)';
  }
}
