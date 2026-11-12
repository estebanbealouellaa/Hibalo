// Opening the app offline: refreshAdminRole (run at app start and after sign-in) must never wait for the
// network for long. A Firestore write only completes when the server confirms it, so offline it never does.
//   flutter test test/providers/auth_offline_test.dart

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/providers/auth_provider.dart';

/// The real provider with the two Firestore calls replaced.
class _FakeAuth extends AuthProvider {
  _FakeAuth({this.server, this.cache, this.cacheFails = false});

  /// What the server returns, or null = it never answers (offline).
  final Map<String, dynamic>? server;

  /// The phone's cached copy of users/{uid}.
  final Map<String, dynamic>? cache;
  final bool cacheFails;

  int writes = 0;

  @override
  Future<Map<String, dynamic>?> readUserDoc(String uid, {bool cacheOnly = false}) {
    if (cacheOnly) {
      return cacheFails ? Future.error(StateError('no cached copy')) : Future.value(cache);
    }
    final answer = server;
    return answer == null ? Completer<Map<String, dynamic>?>().future : Future.value(answer);
  }

  @override
  Future<void> writeLastActive(String uid) {
    writes++;
    return Completer<void>().future; // offline: the server never confirms the write
  }
}

void main() {
  /// Runs refreshAdminRole and returns how long (fake time) it took, or null if it didn't finish in 30 s.
  Future<Duration?> timeRefresh(WidgetTester tester, _FakeAuth auth) async {
    var done = false;
    unawaited(auth.refreshAdminRole('u1').then((_) => done = true));
    var waited = Duration.zero;
    const step = Duration(milliseconds: 500);
    while (!done && waited < const Duration(seconds: 30)) {
      await tester.pump(step);
      waited += step;
    }
    return done ? waited : null;
  }

  testWidgets('offline: finishes after the 5 s timeout and uses the cached role', (tester) async {
    final auth = _FakeAuth(cache: {'role': 'admin'});
    final took = await timeRefresh(tester, auth);
    expect(took, isNotNull, reason: 'must not wait forever');
    expect(took!, lessThanOrEqualTo(AuthProvider.adminCheckTimeout + const Duration(seconds: 1)));
    expect(auth.isAdmin, isTrue, reason: 'the cached copy says admin');
    expect(auth.writes, 1, reason: 'lastActive is still sent (Firestore delivers it later)');
  });

  testWidgets('offline, a normal user: not admin', (tester) async {
    final auth = _FakeAuth(cache: {'role': 'user'});
    expect(await timeRefresh(tester, auth), isNotNull);
    expect(auth.isAdmin, isFalse);
  });

  testWidgets('offline with no cached copy: not admin, still finishes', (tester) async {
    final auth = _FakeAuth(cacheFails: true);
    expect(await timeRefresh(tester, auth), isNotNull);
    expect(auth.isAdmin, isFalse);
  });

  testWidgets('online: the server answers at once, and the write is not awaited', (tester) async {
    final auth = _FakeAuth(server: {'role': 'admin'});
    final took = await timeRefresh(tester, auth);
    expect(took, isNotNull);
    expect(took!, lessThanOrEqualTo(const Duration(milliseconds: 500)),
        reason: 'no waiting for the lastActive write, which never completes here');
    expect(auth.isAdmin, isTrue);
    expect(auth.writes, 1);
  });
}
