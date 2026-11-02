import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/services/translation/hil_numbers.dart';

void main() {
  group('cardinal (hil_numbers.py)', () {
    const cases = {
      0: 'sero',
      1: 'isa',
      9: 'siyam',
      10: 'napulo',
      11: 'napulo kag isa',
      19: 'napulo kag siyam',
      20: 'duha ka pulo',
      21: 'duha ka pulo kag isa',
      30: 'katluan',
      45: 'kap-atan kag lima',
      50: 'kalim-an',
      99: 'kasiyaman kag siyam',
      100: 'isa ka gatos',
      101: 'isa ka gatos kag isa',
      150: 'isa ka gatos kag kalim-an',
      200: 'duha ka gatos',
      1000: 'isa ka libo',
      1250: 'isa ka libo duha ka gatos kag kalim-an',
      2026: 'duha ka libo kag duha ka pulo kag anom',
      15113: 'napulo kag lima ka libo isa ka gatos kag napulo kag tatlo',
      1000000: 'isa ka milyon',
      5000000: 'lima ka milyon',
    };
    cases.forEach((n, want) {
      test('$n', () => expect(cardinal(n), want));
    });
  });

  group('numbersToWords (hil_numbers.py)', () {
    const cases = {
      'May 3 ka bata sa balay.': 'May tatlo ka bata sa balay.',
      'Ang P150 para sa 2 ka tawo.':
          'Ang isa ka gatos kag kalim-an ka pesos para sa duha ka tawo.',
      'Sa ika-3 nga adlaw, alas 4 sang hapon.':
          'Sa ikatlo nga adlaw, alas kwatro sang hapon.',
      'Alas 7:30 ang miting.': 'Alas siyete kag katluan ka minuto ang miting.',
      'Ang 20-anyos nga Pinay.': 'Ang duha ka pulo ka tuig nga Pinay.',
      'Mga 12-17 anyos ang bata.':
          'Mga napulo kag duha tubtob napulo kag pito anyos ang bata.',
      'Nagtaas sang 90% ang presyo.':
          'Nagtaas sang kasiyaman porsiyento ang presyo.',
      'May 15,113 ka kaso.':
          'May napulo kag lima ka libo isa ka gatos kag napulo kag tatlo ka kaso.',
      'Ang 12.7 milyon ka tawo.':
          'Ang napulo kag duha punto pito milyon ka tawo.',
      'Tawgi ang 09171234567.':
          'Tawgi ang sero siyam isa pito isa duha tatlo apat lima anom pito.',
      'Ika-25 nga tuig.': 'Ika-duha ka pulo kag lima nga tuig.',
      'Ika-2 nga beses.': 'Ikaduha nga beses.',
      'Wala sang numero diri.': 'Wala sang numero diri.',
      // The example at the top of the Python file.
      'Ang P150 para sa 2 ka tawo, ika-3 nga adlaw.':
          'Ang isa ka gatos kag kalim-an ka pesos para sa duha ka tawo, '
          'ikatlo nga adlaw.',
    };
    cases.forEach((input, want) {
      test(input, () => expect(numbersToWords(input), want));
    });

    test('a very long ordinal number does not crash', () {
      expect(
        numbersToWords('ika-123456789012345678901234'),
        startsWith('ika-isa duha tatlo'),
      );
    });
  });
}
