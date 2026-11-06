import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> createUser({
    required String uid,
    required String username,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
      'email': email,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  static Future<String?> translateToHiligaynon(String text) async {
    final cleaned = text.toLowerCase().trim();

    final exact = await _db
        .collection('translations')
        .where('fil', isEqualTo: cleaned)
        .limit(1)
        .get();

    if (exact.docs.isNotEmpty) return exact.docs.first['hil'];

    final words = cleaned.split(RegExp(r'\s+'));
    if (words.length > 1) {
      final translated = <String>[];

      for (final word in words) {
        final wordQuery = await _db
            .collection('translations')
            .where('fil', isEqualTo: word)
            .limit(1)
            .get();

        translated.add(
          wordQuery.docs.isNotEmpty ? wordQuery.docs.first['hil'] : word,
        );
      }

      return translated.join(' ');
    }

    return null;
  }

  static Future<String?> translateToFilipino(String text) async {
    final cleaned = text.toLowerCase().trim();

    final exact = await _db
        .collection('translations')
        .where('hil', isEqualTo: cleaned)
        .limit(1)
        .get();

    if (exact.docs.isNotEmpty) return exact.docs.first['fil'];

    final words = cleaned.split(RegExp(r'\s+'));
    if (words.length > 1) {
      final translated = <String>[];

      for (final word in words) {
        final wordQuery = await _db
            .collection('translations')
            .where('hil', isEqualTo: word)
            .limit(1)
            .get();

        translated.add(
          wordQuery.docs.isNotEmpty ? wordQuery.docs.first['fil'] : word,
        );
      }

      return translated.join(' ');
    }

    return null;
  }

}
