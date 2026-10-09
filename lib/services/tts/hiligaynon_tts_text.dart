// Text side of the Hiligaynon voice (v4: MMS-TTS / VITS, HIL_0619).
// Exact port of voice_text(), ends_statement(), to_ids(), split_sentences()
// and split_first() in C:\Hibalo-TTS-Mobile\generate_tts_v4.py, so the
// phone feeds the model exactly what the PC does. Checked against
// test/tts/v4_reference.json.

/// Pause after a sentence, in seconds (HIBALO_GAP).
const double kSentenceGap = 0.50;

/// Breath before the question part of "lead-in, question?" (HIBALO_QGAP).
const double kQuestionGap = 0.20;

/// Breath between the two pieces of the cut first sentence (HIBALO_PGAP).
const double kPieceGap = 0.20;

/// The first sentence is cut once when it has more than this many words
/// (FIRST_MAX), so the voice can start speaking sooner.
const int kFirstMax = 6;

/// Words a sentence may be cut BEFORE (they start a new clause).
const Set<String> clauseWords = {
  'kag', 'kon', 'para', 'pero', 'apang', 'ukon', 'samtang', //
  'tungod', 'kay', 'agod', 'bisan', 'kundi', 'kaysa',
};

/// Never leave a piece shorter than this many words (MIN_PIECE).
const int _minPiece = 3;

/// Words the voice says wrong, and the spelling that makes it say them right.
const Map<String, String> fixedSpellings = {'nagapamangkot': 'nagapamangkott'};

/// Python's `\s` / str.isspace() (Dart's `\s` differs on a few characters).
const String _ws =
    r'[\t\n\x0B\f\r\x1C-\x1F \x85\xA0\u1680\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]';
final RegExp _wsRun = RegExp('$_ws+');
final RegExp _edgeWs = RegExp('^$_ws+|$_ws+\$');

/// Python's str.strip().
String _strip(String s) => s.replaceAll(_edgeWs, '');

final RegExp _combiningMarks = RegExp(r'\p{Mn}', unicode: true);

/// Python's strip_accents(): ñ -> ny, then unicodedata NFD with the
/// combining marks dropped. Dart has no NFD, so the letters it changes are
/// listed in [_accents].
String stripAccents(String s) {
  s = s.replaceAll('ñ', 'ny').replaceAll('Ñ', 'Ny');
  final sb = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    sb.write(_accents[ch] ?? ch);
  }
  return sb.toString().replaceAll(_combiningMarks, '');
}

/// True only for the last piece of the whole text, when it is not a
/// question: only there is the last vowel stretched (END_FIX "c").
bool endsStatement(String piece, bool isLast) =>
    isLast && !piece.replaceAll(RegExp('$_ws+\$'), '').endsWith('?');

/// Same as the v4 training text: '— text —', commas -> '—', '?' -> '|'.
/// With [stretchEnd], the last vowel is doubled: pamilya -> pamilyaa.
/// Returns '' when nothing is left to say.
String voiceText(String s, {bool stretchEnd = true}) {
  s = stripAccents(s).toLowerCase();
  s = s.replaceAll(RegExp('$_ws+-$_ws+|--+'), ' — ');
  s = s.replaceAll('?', ' | ');
  s = s.replaceAll('!', ' ').replaceAll('.', ' — ');
  s = s.replaceAll(RegExp('[,;:]'), ' — ');
  // TODO(numbers): digits are dropped for now ("May 3 ka libro." ->
  // "— may ka libro —"). Hiligaynon number words come in a separate change,
  // once a native speaker has checked them (update generate_tts_v4.py too).
  s = s.replaceAll(RegExp("[^a-z'\\-—| ]"), ' ');
  s = _strip(s.replaceAll(_wsRun, ' '));
  s = s.replaceAll(RegExp('(—$_ws*)+—'), '—'); // no double pauses
  s = s.replaceAll(RegExp('^(—$_ws*)+'), '');
  s = _strip(s.replaceAll(RegExp('($_ws*—)+\$'), ''));
  s = s.split(' ').map((w) => fixedSpellings[w] ?? w).join(' ');
  if (s.isEmpty) return '';
  if (stretchEnd) {
    s = s.replaceFirstMapped(
      RegExp('([aeiou])($_ws*\\|?)\$'),
      (m) => '${m[1]}${m[1]}${m[2]}',
    );
  }
  return '— $s —';
}

/// Each letter -> its number, with a blank (0) between every letter.
/// Letters not in [vocab] are skipped.
List<int> toIds(String text, Map<String, int> vocab) {
  final ids = <int>[0];
  for (final r in text.runes) {
    final id = vocab[String.fromCharCode(r)];
    if (id != null) ids.addAll([id, 0]);
  }
  return ids;
}

/// One whole sentence at a time. A question with a lead-in part
/// ("Maayong aga sa imo, kumusta ka?") is said as two: the lead-in, then the
/// question on its own, the way short questions sound best. The very first
/// part is also cut once by [splitFirst] when it is long.
/// Returns (text, pause after in seconds) pairs.
List<(String, double)> splitSentences(String text) {
  final out = <(String, double)>[];
  var first = true;
  for (final raw in _strip(text).split(RegExp('(?<=[.!?])$_ws+'))) {
    final s = _strip(raw);
    if (s.isEmpty) continue;
    var parts = [s];
    if (s.endsWith('?') && s.contains(',')) {
      final cut = s.lastIndexOf(',');
      final lead = _strip(s.substring(0, cut));
      final question = _strip(s.substring(cut + 1));
      if (lead.isNotEmpty && question.isNotEmpty) parts = [lead, question];
    }
    for (var j = 0; j < parts.length; j++) {
      final pieces = first ? splitFirst(parts[j]) : [parts[j]];
      first = false;
      for (var k = 0; k < pieces.length; k++) {
        final gap = k < pieces.length - 1
            ? kPieceGap
            : j < parts.length - 1
            ? kQuestionGap
            : kSentenceGap;
        out.add((pieces[k], gap));
      }
    }
  }
  return out;
}

/// Python's str.split() with no argument.
List<String> _words(String s) =>
    _strip(s).split(_wsRun).where((w) => w.isNotEmpty).toList();

/// Only for the very first sentence: cut it once so the voice can start
/// speaking sooner. Cut at its first comma (where a speaker pauses anyway),
/// otherwise before a clause word (kag, kon, para, ...) near the middle.
List<String> splitFirst(String s) {
  final w = _words(s);
  if (w.length <= kFirstMax) return [s];
  bool endsWithAny(String x, String chars) =>
      x.isNotEmpty && chars.contains(x[x.length - 1]);
  for (var i = 1; i < w.length; i++) {
    if (endsWithAny(w[i - 1], ',;:')) {
      if (i >= 2 && w.length - i >= _minPiece) {
        return [
          w.sublist(0, i).join(' ').replaceAll(RegExp(r'[,;:]+$'), ''),
          w.sublist(i).join(' '),
        ];
      }
      break;
    }
  }
  final notLetter = RegExp('[^a-z-]');
  final cuts = [
    for (var i = _minPiece; i <= w.length - _minPiece; i++)
      if (clauseWords.contains(w[i].toLowerCase().replaceAll(notLetter, '')) &&
          !w[i - 1].endsWith(','))
        i,
  ];
  if (cuts.isEmpty) return [s];
  // Python's min(): the first cut wins a tie.
  var best = cuts.first;
  for (final c in cuts) {
    if ((c - w.length / 2).abs() < (best - w.length / 2).abs()) best = c;
  }
  return [w.sublist(0, best).join(' '), w.sublist(best).join(' ')];
}

/// Letters whose NFD form (combining marks dropped) changes what the voice
/// gets. Generated from Python's unicodedata (every BMP letter for which
/// strip_accents() changes the result of voice_text()).
// dart format off
const Map<String, String> _accents = {
  '\u{00C0}': 'A', '\u{00C1}': 'A', '\u{00C2}': 'A', '\u{00C3}': 'A', '\u{00C4}': 'A', '\u{00C5}': 'A',
  '\u{00C7}': 'C', '\u{00C8}': 'E', '\u{00C9}': 'E', '\u{00CA}': 'E', '\u{00CB}': 'E', '\u{00CC}': 'I',
  '\u{00CD}': 'I', '\u{00CE}': 'I', '\u{00CF}': 'I', '\u{00D2}': 'O', '\u{00D3}': 'O', '\u{00D4}': 'O',
  '\u{00D5}': 'O', '\u{00D6}': 'O', '\u{00D9}': 'U', '\u{00DA}': 'U', '\u{00DB}': 'U', '\u{00DC}': 'U',
  '\u{00DD}': 'Y', '\u{00E0}': 'a', '\u{00E1}': 'a', '\u{00E2}': 'a', '\u{00E3}': 'a', '\u{00E4}': 'a',
  '\u{00E5}': 'a', '\u{00E7}': 'c', '\u{00E8}': 'e', '\u{00E9}': 'e', '\u{00EA}': 'e', '\u{00EB}': 'e',
  '\u{00EC}': 'i', '\u{00ED}': 'i', '\u{00EE}': 'i', '\u{00EF}': 'i', '\u{00F2}': 'o', '\u{00F3}': 'o',
  '\u{00F4}': 'o', '\u{00F5}': 'o', '\u{00F6}': 'o', '\u{00F9}': 'u', '\u{00FA}': 'u', '\u{00FB}': 'u',
  '\u{00FC}': 'u', '\u{00FD}': 'y', '\u{00FF}': 'y', '\u{0100}': 'A', '\u{0101}': 'a', '\u{0102}': 'A',
  '\u{0103}': 'a', '\u{0104}': 'A', '\u{0105}': 'a', '\u{0106}': 'C', '\u{0107}': 'c', '\u{0108}': 'C',
  '\u{0109}': 'c', '\u{010A}': 'C', '\u{010B}': 'c', '\u{010C}': 'C', '\u{010D}': 'c', '\u{010E}': 'D',
  '\u{010F}': 'd', '\u{0112}': 'E', '\u{0113}': 'e', '\u{0114}': 'E', '\u{0115}': 'e', '\u{0116}': 'E',
  '\u{0117}': 'e', '\u{0118}': 'E', '\u{0119}': 'e', '\u{011A}': 'E', '\u{011B}': 'e', '\u{011C}': 'G',
  '\u{011D}': 'g', '\u{011E}': 'G', '\u{011F}': 'g', '\u{0120}': 'G', '\u{0121}': 'g', '\u{0122}': 'G',
  '\u{0123}': 'g', '\u{0124}': 'H', '\u{0125}': 'h', '\u{0128}': 'I', '\u{0129}': 'i', '\u{012A}': 'I',
  '\u{012B}': 'i', '\u{012C}': 'I', '\u{012D}': 'i', '\u{012E}': 'I', '\u{012F}': 'i', '\u{0130}': 'I',
  '\u{0134}': 'J', '\u{0135}': 'j', '\u{0136}': 'K', '\u{0137}': 'k', '\u{0139}': 'L', '\u{013A}': 'l',
  '\u{013B}': 'L', '\u{013C}': 'l', '\u{013D}': 'L', '\u{013E}': 'l', '\u{0143}': 'N', '\u{0144}': 'n',
  '\u{0145}': 'N', '\u{0146}': 'n', '\u{0147}': 'N', '\u{0148}': 'n', '\u{014C}': 'O', '\u{014D}': 'o',
  '\u{014E}': 'O', '\u{014F}': 'o', '\u{0150}': 'O', '\u{0151}': 'o', '\u{0154}': 'R', '\u{0155}': 'r',
  '\u{0156}': 'R', '\u{0157}': 'r', '\u{0158}': 'R', '\u{0159}': 'r', '\u{015A}': 'S', '\u{015B}': 's',
  '\u{015C}': 'S', '\u{015D}': 's', '\u{015E}': 'S', '\u{015F}': 's', '\u{0160}': 'S', '\u{0161}': 's',
  '\u{0162}': 'T', '\u{0163}': 't', '\u{0164}': 'T', '\u{0165}': 't', '\u{0168}': 'U', '\u{0169}': 'u',
  '\u{016A}': 'U', '\u{016B}': 'u', '\u{016C}': 'U', '\u{016D}': 'u', '\u{016E}': 'U', '\u{016F}': 'u',
  '\u{0170}': 'U', '\u{0171}': 'u', '\u{0172}': 'U', '\u{0173}': 'u', '\u{0174}': 'W', '\u{0175}': 'w',
  '\u{0176}': 'Y', '\u{0177}': 'y', '\u{0178}': 'Y', '\u{0179}': 'Z', '\u{017A}': 'z', '\u{017B}': 'Z',
  '\u{017C}': 'z', '\u{017D}': 'Z', '\u{017E}': 'z', '\u{01A0}': 'O', '\u{01A1}': 'o', '\u{01AF}': 'U',
  '\u{01B0}': 'u', '\u{01CD}': 'A', '\u{01CE}': 'a', '\u{01CF}': 'I', '\u{01D0}': 'i', '\u{01D1}': 'O',
  '\u{01D2}': 'o', '\u{01D3}': 'U', '\u{01D4}': 'u', '\u{01D5}': 'U', '\u{01D6}': 'u', '\u{01D7}': 'U',
  '\u{01D8}': 'u', '\u{01D9}': 'U', '\u{01DA}': 'u', '\u{01DB}': 'U', '\u{01DC}': 'u', '\u{01DE}': 'A',
  '\u{01DF}': 'a', '\u{01E0}': 'A', '\u{01E1}': 'a', '\u{01E6}': 'G', '\u{01E7}': 'g', '\u{01E8}': 'K',
  '\u{01E9}': 'k', '\u{01EA}': 'O', '\u{01EB}': 'o', '\u{01EC}': 'O', '\u{01ED}': 'o', '\u{01F0}': 'j',
  '\u{01F4}': 'G', '\u{01F5}': 'g', '\u{01F8}': 'N', '\u{01F9}': 'n', '\u{01FA}': 'A', '\u{01FB}': 'a',
  '\u{0200}': 'A', '\u{0201}': 'a', '\u{0202}': 'A', '\u{0203}': 'a', '\u{0204}': 'E', '\u{0205}': 'e',
  '\u{0206}': 'E', '\u{0207}': 'e', '\u{0208}': 'I', '\u{0209}': 'i', '\u{020A}': 'I', '\u{020B}': 'i',
  '\u{020C}': 'O', '\u{020D}': 'o', '\u{020E}': 'O', '\u{020F}': 'o', '\u{0210}': 'R', '\u{0211}': 'r',
  '\u{0212}': 'R', '\u{0213}': 'r', '\u{0214}': 'U', '\u{0215}': 'u', '\u{0216}': 'U', '\u{0217}': 'u',
  '\u{0218}': 'S', '\u{0219}': 's', '\u{021A}': 'T', '\u{021B}': 't', '\u{021E}': 'H', '\u{021F}': 'h',
  '\u{0226}': 'A', '\u{0227}': 'a', '\u{0228}': 'E', '\u{0229}': 'e', '\u{022A}': 'O', '\u{022B}': 'o',
  '\u{022C}': 'O', '\u{022D}': 'o', '\u{022E}': 'O', '\u{022F}': 'o', '\u{0230}': 'O', '\u{0231}': 'o',
  '\u{0232}': 'Y', '\u{0233}': 'y', '\u{1E00}': 'A', '\u{1E01}': 'a', '\u{1E02}': 'B', '\u{1E03}': 'b',
  '\u{1E04}': 'B', '\u{1E05}': 'b', '\u{1E06}': 'B', '\u{1E07}': 'b', '\u{1E08}': 'C', '\u{1E09}': 'c',
  '\u{1E0A}': 'D', '\u{1E0B}': 'd', '\u{1E0C}': 'D', '\u{1E0D}': 'd', '\u{1E0E}': 'D', '\u{1E0F}': 'd',
  '\u{1E10}': 'D', '\u{1E11}': 'd', '\u{1E12}': 'D', '\u{1E13}': 'd', '\u{1E14}': 'E', '\u{1E15}': 'e',
  '\u{1E16}': 'E', '\u{1E17}': 'e', '\u{1E18}': 'E', '\u{1E19}': 'e', '\u{1E1A}': 'E', '\u{1E1B}': 'e',
  '\u{1E1C}': 'E', '\u{1E1D}': 'e', '\u{1E1E}': 'F', '\u{1E1F}': 'f', '\u{1E20}': 'G', '\u{1E21}': 'g',
  '\u{1E22}': 'H', '\u{1E23}': 'h', '\u{1E24}': 'H', '\u{1E25}': 'h', '\u{1E26}': 'H', '\u{1E27}': 'h',
  '\u{1E28}': 'H', '\u{1E29}': 'h', '\u{1E2A}': 'H', '\u{1E2B}': 'h', '\u{1E2C}': 'I', '\u{1E2D}': 'i',
  '\u{1E2E}': 'I', '\u{1E2F}': 'i', '\u{1E30}': 'K', '\u{1E31}': 'k', '\u{1E32}': 'K', '\u{1E33}': 'k',
  '\u{1E34}': 'K', '\u{1E35}': 'k', '\u{1E36}': 'L', '\u{1E37}': 'l', '\u{1E38}': 'L', '\u{1E39}': 'l',
  '\u{1E3A}': 'L', '\u{1E3B}': 'l', '\u{1E3C}': 'L', '\u{1E3D}': 'l', '\u{1E3E}': 'M', '\u{1E3F}': 'm',
  '\u{1E40}': 'M', '\u{1E41}': 'm', '\u{1E42}': 'M', '\u{1E43}': 'm', '\u{1E44}': 'N', '\u{1E45}': 'n',
  '\u{1E46}': 'N', '\u{1E47}': 'n', '\u{1E48}': 'N', '\u{1E49}': 'n', '\u{1E4A}': 'N', '\u{1E4B}': 'n',
  '\u{1E4C}': 'O', '\u{1E4D}': 'o', '\u{1E4E}': 'O', '\u{1E4F}': 'o', '\u{1E50}': 'O', '\u{1E51}': 'o',
  '\u{1E52}': 'O', '\u{1E53}': 'o', '\u{1E54}': 'P', '\u{1E55}': 'p', '\u{1E56}': 'P', '\u{1E57}': 'p',
  '\u{1E58}': 'R', '\u{1E59}': 'r', '\u{1E5A}': 'R', '\u{1E5B}': 'r', '\u{1E5C}': 'R', '\u{1E5D}': 'r',
  '\u{1E5E}': 'R', '\u{1E5F}': 'r', '\u{1E60}': 'S', '\u{1E61}': 's', '\u{1E62}': 'S', '\u{1E63}': 's',
  '\u{1E64}': 'S', '\u{1E65}': 's', '\u{1E66}': 'S', '\u{1E67}': 's', '\u{1E68}': 'S', '\u{1E69}': 's',
  '\u{1E6A}': 'T', '\u{1E6B}': 't', '\u{1E6C}': 'T', '\u{1E6D}': 't', '\u{1E6E}': 'T', '\u{1E6F}': 't',
  '\u{1E70}': 'T', '\u{1E71}': 't', '\u{1E72}': 'U', '\u{1E73}': 'u', '\u{1E74}': 'U', '\u{1E75}': 'u',
  '\u{1E76}': 'U', '\u{1E77}': 'u', '\u{1E78}': 'U', '\u{1E79}': 'u', '\u{1E7A}': 'U', '\u{1E7B}': 'u',
  '\u{1E7C}': 'V', '\u{1E7D}': 'v', '\u{1E7E}': 'V', '\u{1E7F}': 'v', '\u{1E80}': 'W', '\u{1E81}': 'w',
  '\u{1E82}': 'W', '\u{1E83}': 'w', '\u{1E84}': 'W', '\u{1E85}': 'w', '\u{1E86}': 'W', '\u{1E87}': 'w',
  '\u{1E88}': 'W', '\u{1E89}': 'w', '\u{1E8A}': 'X', '\u{1E8B}': 'x', '\u{1E8C}': 'X', '\u{1E8D}': 'x',
  '\u{1E8E}': 'Y', '\u{1E8F}': 'y', '\u{1E90}': 'Z', '\u{1E91}': 'z', '\u{1E92}': 'Z', '\u{1E93}': 'z',
  '\u{1E94}': 'Z', '\u{1E95}': 'z', '\u{1E96}': 'h', '\u{1E97}': 't', '\u{1E98}': 'w', '\u{1E99}': 'y',
  '\u{1EA0}': 'A', '\u{1EA1}': 'a', '\u{1EA2}': 'A', '\u{1EA3}': 'a', '\u{1EA4}': 'A', '\u{1EA5}': 'a',
  '\u{1EA6}': 'A', '\u{1EA7}': 'a', '\u{1EA8}': 'A', '\u{1EA9}': 'a', '\u{1EAA}': 'A', '\u{1EAB}': 'a',
  '\u{1EAC}': 'A', '\u{1EAD}': 'a', '\u{1EAE}': 'A', '\u{1EAF}': 'a', '\u{1EB0}': 'A', '\u{1EB1}': 'a',
  '\u{1EB2}': 'A', '\u{1EB3}': 'a', '\u{1EB4}': 'A', '\u{1EB5}': 'a', '\u{1EB6}': 'A', '\u{1EB7}': 'a',
  '\u{1EB8}': 'E', '\u{1EB9}': 'e', '\u{1EBA}': 'E', '\u{1EBB}': 'e', '\u{1EBC}': 'E', '\u{1EBD}': 'e',
  '\u{1EBE}': 'E', '\u{1EBF}': 'e', '\u{1EC0}': 'E', '\u{1EC1}': 'e', '\u{1EC2}': 'E', '\u{1EC3}': 'e',
  '\u{1EC4}': 'E', '\u{1EC5}': 'e', '\u{1EC6}': 'E', '\u{1EC7}': 'e', '\u{1EC8}': 'I', '\u{1EC9}': 'i',
  '\u{1ECA}': 'I', '\u{1ECB}': 'i', '\u{1ECC}': 'O', '\u{1ECD}': 'o', '\u{1ECE}': 'O', '\u{1ECF}': 'o',
  '\u{1ED0}': 'O', '\u{1ED1}': 'o', '\u{1ED2}': 'O', '\u{1ED3}': 'o', '\u{1ED4}': 'O', '\u{1ED5}': 'o',
  '\u{1ED6}': 'O', '\u{1ED7}': 'o', '\u{1ED8}': 'O', '\u{1ED9}': 'o', '\u{1EDA}': 'O', '\u{1EDB}': 'o',
  '\u{1EDC}': 'O', '\u{1EDD}': 'o', '\u{1EDE}': 'O', '\u{1EDF}': 'o', '\u{1EE0}': 'O', '\u{1EE1}': 'o',
  '\u{1EE2}': 'O', '\u{1EE3}': 'o', '\u{1EE4}': 'U', '\u{1EE5}': 'u', '\u{1EE6}': 'U', '\u{1EE7}': 'u',
  '\u{1EE8}': 'U', '\u{1EE9}': 'u', '\u{1EEA}': 'U', '\u{1EEB}': 'u', '\u{1EEC}': 'U', '\u{1EED}': 'u',
  '\u{1EEE}': 'U', '\u{1EEF}': 'u', '\u{1EF0}': 'U', '\u{1EF1}': 'u', '\u{1EF2}': 'Y', '\u{1EF3}': 'y',
  '\u{1EF4}': 'Y', '\u{1EF5}': 'y', '\u{1EF6}': 'Y', '\u{1EF7}': 'y', '\u{1EF8}': 'Y', '\u{1EF9}': 'y',
  '\u{212B}': 'A',
};
// dart format on
