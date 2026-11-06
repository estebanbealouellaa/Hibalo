import 'package:flutter_test/flutter_test.dart';
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
    test('edit writes username, not name', () {
      final f = adminEditFields(' Bea ', ' a@b.c ');
      expect(f, {'username': 'Bea', 'email': 'a@b.c'});
      expect(f.containsKey('name'), isFalse);
    });
  });
}
