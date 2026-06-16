import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================
  // USERS
  // ==========================
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

  static Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  static Future<void> updateLastLogin(String uid) async {
    await _db.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // ==========================
  // TEXT / SPEECH TRANSLATION
  // ==========================
  static Future<void> saveTranslation({
    required String uid,
    required String inputType,
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    await _db.collection('translations').add({
      'uid': uid,
      'inputType': inputType,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================
  // CAMERA TRANSLATION
  // ==========================
  static Future<void> saveCameraTranslation({
    required String uid,
    required String detectedText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    await _db.collection('camera_translations').add({
      'uid': uid,
      'detectedText': detectedText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================
  // LIBRARY
  // ==========================
  static Future<void> saveToLibrary({
    required String uid,
    required String word,
    required String translation,
    required String language,
  }) async {
    await _db.collection('library').add({
      'uid': uid,
      'word': word,
      'translation': translation,
      'language': language,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getLibrary(String uid) {
    return _db.collection('library').where('uid', isEqualTo: uid).snapshots();
  }

  // ==========================
  // HILIGAYNON TRANSLATION
  // FIX: Tamang collection = 'translations', fields = 'fil' at 'hil'
  // ==========================
  static Future<String?> translateToHiligaynon(String text) async {
    final cleaned = text.toLowerCase().trim();

    // 1. Exact match ng buong phrase
    final exact = await _db
        .collection('translations')
        .where('fil', isEqualTo: cleaned)
        .limit(1)
        .get();

    if (exact.docs.isNotEmpty) return exact.docs.first['hil'];

    // 2. Word-by-word fallback para sa multi-word input
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

    // 1. Exact match ng buong phrase
    final exact = await _db
        .collection('translations')
        .where('hil', isEqualTo: cleaned)
        .limit(1)
        .get();

    if (exact.docs.isNotEmpty) return exact.docs.first['fil'];

    // 2. Word-by-word fallback para sa multi-word input
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

  // ==========================
  // DICTIONARY MANAGEMENT (ADMIN)
  // ==========================
  static Future<void> addDictionaryWord({
    required String filipino,
    required String hiligaynon,
    required String category,
  }) async {
    await _db.collection('translations').add({
      'fil': filipino.toLowerCase().trim(),
      'hil': hiligaynon.toLowerCase().trim(),
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
