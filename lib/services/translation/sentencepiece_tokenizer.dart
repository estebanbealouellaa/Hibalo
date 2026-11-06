// Pure-Dart SentencePiece (unigram) tokenizer for spm.model, following the C++ library step by step (ids checked in test/translation).

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

const int _typeNormal = 1;
const int _typeUnknown = 2;
const int _typeControl = 3;
const int _typeUserDefined = 4;
const int _typeUnused = 5;

const String _spaceSymbol = '▁';

/// Same as the C++ library: an unknown piece scores 10 below the worst one.
const double _unknownPenalty = 10.0;

/// FLT_MIN in C++, the start value of the highest piece score.
const double _floatMin = 1.17549435e-38;

/// The C++ code adds up 32-bit floats. Rounding the same way keeps close
/// choices between two splits identical.
final Float32List _float = Float32List(1);
double _f32(double x) {
  _float[0] = x;
  return _float[0];
}

class _ProtoReader {
  _ProtoReader(this.bytes) : _end = bytes.length;

  final Uint8List bytes;
  final int _end;
  int _pos = 0;

  bool get hasMore => _pos < _end;

  int readVarint() {
    var result = 0;
    var shift = 0;
    while (true) {
      final b = bytes[_pos++];
      result |= (b & 0x7f) << shift;
      if (b < 0x80) return result;
      shift += 7;
    }
  }

  Uint8List readBytes() {
    final length = readVarint();
    final out = Uint8List.sublistView(bytes, _pos, _pos + length);
    _pos += length;
    return out;
  }

  double readFloat() {
    final value = ByteData.sublistView(
      bytes,
      _pos,
      _pos + 4,
    ).getFloat32(0, Endian.little);
    _pos += 4;
    return value;
  }

  void skip(int wireType) {
    switch (wireType) {
      case 0:
        readVarint();
      case 1:
        _pos += 8;
      case 2:
        readBytes();
      case 5:
        _pos += 4;
      default:
        throw FormatException('spm.model: unknown wire type $wireType');
    }
  }
}

/// Finds the longest normalization rule in the charsmap stored in spm.model.
/// The charsmap is: [trie size][Darts double-array trie][replacement text].
class _CharsMap {
  _CharsMap(Uint8List blob) {
    final data = ByteData.sublistView(blob);
    final trieBytes = data.getUint32(0, Endian.little);
    _trie = List<int>.generate(
      trieBytes ~/ 4,
      (i) => data.getUint32(4 + i * 4, Endian.little),
      growable: false,
    );
    _text = Uint8List.sublistView(blob, 4 + trieBytes);
  }

  late final List<int> _trie;
  late final Uint8List _text;

  static bool _hasLeaf(int unit) => (unit >> 8) & 1 == 1;
  static int _value(int unit) => unit & 0x7fffffff;
  static int _label(int unit) => unit & 0x800000ff;
  static int _offset(int unit) =>
      (unit >> 10) << ((unit & (1 << 9)) >> 6);

  /// Longest rule that starts at [start]: (bytes used, replacement), or null.
  (int, Uint8List)? longestRule(Uint8List input, int start) {
    var node = _offset(_trie[0]);
    var bestLength = 0;
    var bestValue = 0;
    for (var i = start; i < input.length; i++) {
      final key = input[i];
      node ^= key;
      if (node >= _trie.length) break;
      final unit = _trie[node];
      if (_label(unit) != key) break;
      node ^= _offset(unit);
      if (_hasLeaf(unit)) {
        bestLength = i + 1 - start;
        bestValue = _value(_trie[node]);
      }
    }
    if (bestLength == 0) return null;
    var end = bestValue;
    while (_text[end] != 0) {
      end++;
    }
    return (bestLength, Uint8List.sublistView(_text, bestValue, end));
  }
}

class SentencePieceTokenizer {
  factory SentencePieceTokenizer.fromBytes(Uint8List modelBytes) {
    final pieces = <String>[];
    final scores = <double>[];
    final types = <int>[];
    Uint8List? charsMap;
    var addDummyPrefix = true;
    var removeExtraSpaces = true;
    var escapeSpaces = true;

    final model = _ProtoReader(modelBytes);
    while (model.hasMore) {
      final tag = model.readVarint();
      final field = tag >> 3;
      final wire = tag & 7;
      if (field == 1 && wire == 2) {
        var text = '';
        var score = 0.0;
        var type = _typeNormal;
        final piece = _ProtoReader(model.readBytes());
        while (piece.hasMore) {
          final pieceTag = piece.readVarint();
          switch ((pieceTag >> 3, pieceTag & 7)) {
            case (1, 2):
              text = utf8.decode(piece.readBytes());
            case (2, 5):
              score = piece.readFloat();
            case (3, 0):
              type = piece.readVarint();
            default:
              piece.skip(pieceTag & 7);
          }
        }
        pieces.add(text);
        scores.add(score);
        types.add(type);
      } else if (field == 3 && wire == 2) {
        final spec = _ProtoReader(model.readBytes());
        while (spec.hasMore) {
          final specTag = spec.readVarint();
          switch ((specTag >> 3, specTag & 7)) {
            case (2, 2):
              charsMap = spec.readBytes();
            case (3, 0):
              addDummyPrefix = spec.readVarint() != 0;
            case (4, 0):
              removeExtraSpaces = spec.readVarint() != 0;
            case (5, 0):
              escapeSpaces = spec.readVarint() != 0;
            default:
              spec.skip(specTag & 7);
          }
        }
      } else {
        model.skip(wire);
      }
    }

    return SentencePieceTokenizer._(
      pieces,
      scores,
      types,
      charsMap == null ? null : _CharsMap(charsMap),
      addDummyPrefix,
      removeExtraSpaces,
      escapeSpaces,
    );
  }

  SentencePieceTokenizer._(
    this._pieces,
    this._scores,
    this._types,
    this._charsMap,
    this._addDummyPrefix,
    this._removeExtraSpaces,
    this._escapeSpaces,
  ) {
    var minScore = double.maxFinite;
    var maxScore = _floatMin;
    for (var id = 0; id < _pieces.length; id++) {
      final type = _types[id];
      if (type == _typeUnknown) unkId = id;
      // Control pieces (<pad>, </s>) never come from the text.
      if (type == _typeControl || type == _typeUnknown) continue;
      _idOf[_pieces[id]] = id;
      _longestPiece = math.max(_longestPiece, _pieces[id].runes.length);
      if (type == _typeUserDefined) {
        _userDefined.add(utf8.encode(_pieces[id]));
      }
      if (type == _typeNormal) {
        minScore = math.min(minScore, _scores[id]);
        maxScore = math.max(maxScore, _scores[id]);
      }
    }
    _maxScore = maxScore;
    _unknownScore = _f32(minScore - _unknownPenalty);
  }

  final List<String> _pieces;
  final List<double> _scores;
  final List<int> _types;
  final _CharsMap? _charsMap;
  final bool _addDummyPrefix;
  final bool _removeExtraSpaces;
  final bool _escapeSpaces;

  final Map<String, int> _idOf = {};
  final List<Uint8List> _userDefined = [];
  int _longestPiece = 0;
  late final double _maxScore;
  late final double _unknownScore;

  int unkId = 0;

  int get vocabSize => _pieces.length;

  /// Text -> piece ids. No language tag and no end token: the translator adds
  /// them.
  List<int> encode(String text) {
    final normalized = normalize(text);
    if (normalized.isEmpty) return [];
    return _viterbi(normalized);
  }

  /// The normalized text, ready for splitting: spaces become "▁".
  String normalize(String text) {
    final input = utf8.encode(text);
    final out = BytesBuilder(copy: false);
    final space = utf8.encode(_escapeSpaces ? _spaceSymbol : ' ');
    var pos = 0;

    // Ignore spaces at the start.
    if (_removeExtraSpaces) {
      while (pos < input.length) {
        final (used, replacement) = _normalizePrefix(input, pos);
        if (replacement.length != 1 || replacement[0] != 0x20) break;
        pos += used;
      }
    }
    if (pos >= input.length) return '';

    if (_addDummyPrefix) out.add(space);

    var previousIsSpace = _removeExtraSpaces;
    while (pos < input.length) {
      final (used, replacement) = _normalizePrefix(input, pos);
      pos += used;

      // Skip spaces that follow a space.
      var start = 0;
      while (previousIsSpace &&
          start < replacement.length &&
          replacement[start] == 0x20) {
        start++;
      }
      if (start == replacement.length) continue;

      for (var i = start; i < replacement.length; i++) {
        final byte = replacement[i];
        if (_escapeSpaces && byte == 0x20) {
          out.add(space);
        } else {
          out.addByte(byte);
        }
      }
      previousIsSpace = replacement[replacement.length - 1] == 0x20;
    }

    var result = utf8.decode(out.takeBytes());
    // Ignore spaces at the end.
    if (_removeExtraSpaces) {
      final symbol = _escapeSpaces ? _spaceSymbol : ' ';
      while (result.endsWith(symbol)) {
        result = result.substring(0, result.length - symbol.length);
      }
    }
    return result;
  }

  /// Normalizes what starts at [pos]: (input bytes used, output bytes).
  (int, Uint8List) _normalizePrefix(Uint8List input, int pos) {
    // User-defined symbols are copied as they are.
    var longest = 0;
    for (final symbol in _userDefined) {
      if (symbol.length > longest && _startsWith(input, pos, symbol)) {
        longest = symbol.length;
      }
    }
    if (longest > 0) {
      return (longest, Uint8List.sublistView(input, pos, pos + longest));
    }

    final rule = _charsMap?.longestRule(input, pos);
    if (rule != null) return rule;

    // No rule: keep this one character.
    final length = _charLength(input[pos]);
    final end = math.min(pos + length, input.length);
    return (end - pos, Uint8List.sublistView(input, pos, end));
  }

  static bool _startsWith(Uint8List input, int pos, Uint8List symbol) {
    if (pos + symbol.length > input.length) return false;
    for (var i = 0; i < symbol.length; i++) {
      if (input[pos + i] != symbol[i]) return false;
    }
    return true;
  }

  static int _charLength(int first) {
    if (first < 0x80) return 1;
    if (first < 0xe0) return 2;
    if (first < 0xf0) return 3;
    return 4;
  }

  /// Best-scoring split of the normalized text into pieces.
  List<int> _viterbi(String normalized) {
    final chars = normalized.runes.toList(growable: false);
    final n = chars.length;
    // bestScore[i]: best total for the first i characters.
    final bestScore = Float64List(n + 1);
    final bestId = Int32List(n + 1)..fillRange(0, n + 1, -1);
    final bestStart = Int32List(n + 1)..fillRange(0, n + 1, -1);

    void offer(int end, int start, int id, double score) {
      final total = _f32(score + bestScore[start]);
      if (bestStart[end] == -1 || total > bestScore[end]) {
        bestScore[end] = total;
        bestStart[end] = start;
        bestId[end] = id;
      }
    }

    for (var start = 0; start < n; start++) {
      var hasSingleChar = false;
      var byteLength = 0;
      final longest = math.min(_longestPiece, n - start);
      for (var length = 1; length <= longest; length++) {
        byteLength += _utf8Length(chars[start + length - 1]);
        final piece = String.fromCharCodes(chars, start, start + length);
        final id = _idOf[piece];
        if (id == null || _types[id] == _typeUnused) continue;
        // User-defined symbols get a bonus so they are always picked.
        final score = _types[id] == _typeUserDefined
            ? _f32(byteLength * _maxScore - 0.1)
            : _scores[id];
        offer(start + length, start, id, score);
        if (length == 1) hasSingleChar = true;
      }
      if (!hasSingleChar) offer(start + 1, start, unkId, _unknownScore);
    }

    // Walk back from the end to read the best split.
    final reversed = <int>[];
    for (var end = n; end > 0; end = bestStart[end]) {
      reversed.add(bestId[end]);
    }
    final ids = <int>[];
    for (final id in reversed.reversed) {
      // Several unknown characters in a row count as one <unk>.
      if (id == unkId && ids.isNotEmpty && ids.last == unkId) continue;
      ids.add(id);
    }
    return ids;
  }

  static int _utf8Length(int rune) {
    if (rune < 0x80) return 1;
    if (rune < 0x800) return 2;
    if (rune < 0x10000) return 3;
    return 4;
  }

  /// Piece ids -> text. Control pieces and unknowns are dropped, as in step H.
  String decode(List<int> ids) {
    final out = StringBuffer();
    var atStart = true;
    for (final id in ids) {
      if (id < 0 || id >= _pieces.length) continue;
      final type = _types[id];
      if (type == _typeControl || type == _typeUnknown) continue;
      var piece = _pieces[id];
      if (atStart && piece.startsWith(_spaceSymbol)) {
        piece = piece.substring(_spaceSymbol.length);
      }
      atStart = false;
      out.write(piece.replaceAll(_spaceSymbol, ' '));
    }
    return out.toString();
  }
}
