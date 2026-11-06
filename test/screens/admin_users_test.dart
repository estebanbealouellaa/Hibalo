import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/screens/admin_users_screen.dart';

void main() {
  group('admin users: username field', () {
    test('reads username first', () {
      expect(userDisplayName({'username': 'Bea', 'name': 'Old'}), 'Bea');
    });
    test('falls back to name for old docs', () {
      expect(userDisplayName({'name': 'Old'}), 'Old');
    });
    test('empty when neither is set', () {
      expect(userDisplayName({'email': 'a@b.c'}), '');
    });
    test('search matches username, old name and email', () {
      expect(userMatchesSearch({'username': 'Bea'}, 'be'), isTrue);
      expect(userMatchesSearch({'name': 'Lance'}, 'lan'), isTrue);
      expect(userMatchesSearch({'email': 'x@gmail.com'}, 'gmail'), isTrue);
      expect(userMatchesSearch({'username': 'Bea'}, 'zzz'), isFalse);
      expect(userMatchesSearch({'username': 'Bea'}, ''), isTrue);
    });
    test('edit writes only username (never name or email)', () {
      expect(adminEditFields(' Bea '), {'username': 'Bea'});
    });

    test('every user is listed: newest sign-up first, no sign-up date last', () {
      final users = [
        {'username': 'old', 'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1))},
        {'username': 'noDate'},
        {'username': 'new', 'createdAt': Timestamp.fromDate(DateTime(2026, 11, 1))},
        {'username': 'nullDate', 'createdAt': null},
      ]..sort(compareBySignUp);
      expect(users.map((u) => u['username']), ['new', 'old', 'noDate', 'nullDate']);
    });

    testWidgets('edit dialog: username editable, email read-only', (tester) async {
      final name = TextEditingController(text: 'Bea');
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,
        home: Scaffold(body: AdminEditUserForm(nameController: name, email: 'bea@example.com')),
      ));
      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields, hasLength(2));
      expect(fields[0].enabled, isNot(false));
      expect(fields[1].readOnly, isTrue);
      expect(fields[1].enabled, isFalse);
      expect(find.text('bea@example.com'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Ana');
      expect(name.text, 'Ana');
    });
  });
}
