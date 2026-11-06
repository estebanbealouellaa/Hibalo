import 'package:shared_preferences/shared_preferences.dart';

/// The language pop-up is only for brand-new accounts: once, right after Sign Up; never when an existing account signs in.
abstract final class LanguagePrompt {
  /// Per account: set right after Sign Up so the pop-up never shows twice.
  static String seenKey(String uid) => 'language_asked_v2_$uid';

  static String? _pendingUid;

  /// After a successful Sign Up: mark it seen (keyed by uid) and let Home show it once.
  static Future<void> afterSignUp(String uid) async {
    _pendingUid = uid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(seenKey(uid), true);
  }

  /// True once for the account that just signed up (Home asks this).
  static bool takePending(String? uid) {
    if (uid == null || uid != _pendingUid) return false;
    _pendingUid = null;
    return true;
  }

  static void resetForTest() => _pendingUid = null;
}
