/// Filipino lesson text for the Filipino and Hiligaynon app languages (English stays the source).
///
/// One overlay file per lesson file, next to it: `beginner_lessons.json` → `beginner_lessons.fil.json`:
///
/// ```json
/// { "_meta": { ... },
///   "strings": { "b02_q9.options[0]": { "en": "To be polite to an older person", "fil": "..." } } }
/// ```
///
/// A key is the nearest object `id` above the string plus the path inside that object
/// (`b02.title`, `b02_q9.options[0]`, `b07_t1.rows[2][1]`, `i01.unit.title`); strings with no
/// id above them use the path from the file root (`settings.resultTiers[2].title`). Ids are
/// unique inside each file, so keys stay put when lessons are reordered. `en` is the English
/// the translation was made from: if the English has changed since, the entry is stale and the
/// English shows. `learning_settings.fil.json` can also hold `speakers.<Name>` entries: display
/// names only (the JSON keeps the name, which decides the avatar and the learner's side).
///
/// tools/lesson_strings.py exports the English to CSV and imports the translations with the
/// same checks as [LessonOverlay.validate].
class LessonOverlay {
  LessonOverlay._();

  /// The overlay asset for a lesson JSON asset.
  static String assetFor(String jsonAsset) => jsonAsset.replaceFirst(RegExp(r'\.json$'), '.fil.json');

  static const String speakerPrefix = 'speakers.';

  /// The only fields an overlay may change: display text. Ids, files, answers, accepted
  /// answers, tiles, the Hiligaynon, the Filipino glosses, speaker names and every setting the
  /// app works with can't be touched (same list as TRANSLATABLE in tools/lesson_strings.py).
  static const Set<String> translatableFields = {
    'title', 'objectives', 'question', 'hint', 'setting', 'situation', 'soundHint', 'cue', 'quote',
    'literal', 'sayTo', 'tone', 'warning', 'leftLabel', 'rightLabel', 'label', 'columns', 'tip', 'why',
    'text', 'prompt', 'bridge', 'explain', 'note', 'changes', 'right', 'wrong', 'options', 'rows',
  };

  /// Calls [visit] for every string in [json] with its overlay key and field name.
  static void forEachString(
    Object? json,
    void Function(String key, String field, String value, void Function(String) replace) visit,
  ) {
    void walk(Object? node, String id, String path, String field, void Function(String)? replace) {
      if (node is Map<String, dynamic>) {
        var nodeId = id, nodePath = path;
        final ownId = node['id'];
        if (ownId is String) {
          nodeId = ownId;
          nodePath = '';
        }
        for (final key in node.keys.toList()) {
          walk(node[key], nodeId, nodePath.isEmpty ? key : '$nodePath.$key', key, (v) => node[key] = v);
        }
      } else if (node is List) {
        for (var i = 0; i < node.length; i++) {
          final index = i;
          walk(node[i], id, '$path[$i]', field, (v) => node[index] = v);
        }
      } else if (node is String && replace != null) {
        visit(id.isEmpty ? path : '$id.$path', field, node, replace);
      }
    }

    walk(json, '', '', '', null);
  }

  /// Every string key in [json] → (field, English).
  static Map<String, (String, String)> keysOf(Object? json) {
    final out = <String, (String, String)>{};
    forEachString(json, (key, field, value, _) => out[key] = (field, value));
    return out;
  }

  /// Swaps the translated strings into [json] in place. Missing, stale, non-display or empty
  /// entries keep the English. Returns how many were applied and the speaker display names.
  static OverlayResult apply(Map<String, dynamic> json, Map<String, dynamic> overlay) {
    final strings = _strings(overlay);
    var applied = 0, stale = 0;
    forEachString(json, (key, field, value, replace) {
      final entry = strings[key];
      if (entry == null || !translatableFields.contains(field)) return;
      final (en, fil) = entry;
      if (en != value) {
        stale++;
        return;
      }
      if (fil.trim().isEmpty) return;
      replace(fil);
      applied++;
    });
    final speakers = <String, String>{
      for (final e in strings.entries)
        if (e.key.startsWith(speakerPrefix) && e.value.$2.trim().isNotEmpty &&
            e.key.substring(speakerPrefix.length) == e.value.$1)
          e.value.$1: e.value.$2,
    };
    return OverlayResult(applied: applied, stale: stale, speakerNames: speakers);
  }

  /// Problems that would make an overlay wrong for [json] (empty = fine): unknown keys, fields that aren't display text,
  /// stale English, empty Filipino, *Hiligaynon markup* not kept, and option lists that
  /// would end up with two equal options.
  static List<String> validate(Map<String, dynamic> json, Map<String, dynamic> overlay, {Set<String> speakers = const {}}) {
    final problems = <String>[];
    final strings = _strings(overlay);
    final keys = keysOf(json);
    for (final MapEntry(:key, value: (en, fil)) in strings.entries) {
      if (key.startsWith(speakerPrefix)) {
        final name = key.substring(speakerPrefix.length);
        if (name != en) problems.add('$key: "en" should be the speaker name "$name"');
        if (speakers.isNotEmpty && !speakers.contains(name)) problems.add('$key: no speaker called "$name"');
        if (fil.trim().isEmpty) problems.add('$key: Filipino is empty');
        continue;
      }
      final source = keys[key];
      if (source == null) {
        problems.add('$key: no such text in the English file');
        continue;
      }
      final (field, english) = source;
      if (!translatableFields.contains(field)) problems.add('$key: "$field" can\'t be translated');
      if (english != en) problems.add('$key: stale (the English is now "$english")');
      if (fil.trim().isEmpty) problems.add('$key: Filipino is empty');
      final a = markup(english), b = markup(fil);
      if (fil.trim().isNotEmpty && !_sameItems(a, b)) {
        problems.add('$key: *Hiligaynon* parts changed (${a.join(', ')} → ${b.join(', ')})');
      }
    }
    // Answers are option positions, so the order can't change (one key per position); the
    // options must also stay different from each other once translated.
    final copy = _deepCopy(json);
    apply(copy, overlay);
    final before = _optionLists(json), after = _optionLists(copy);
    for (final MapEntry(:key, :value) in after.entries) {
      final was = before[key]!;
      if (value.toSet().length < value.length && was.toSet().length == was.length) {
        problems.add('$key: two options would be the same (${value.join(' | ')})');
      }
    }
    return problems;
  }

  /// Every `options` list of strings, by key (`b02_q9.options`).
  static Map<String, List<String>> _optionLists(Map<String, dynamic> json) {
    final out = <String, List<String>>{};
    forEachString(json, (key, field, value, _) {
      final m = RegExp(r'^(.*\boptions)\[\d+\]$').firstMatch(key);
      if (field == 'options' && m != null) (out[m.group(1)!] ??= []).add(value);
    });
    return out;
  }

  /// The `*…*` parts of [text], in order.
  static List<String> markup(String text) => [for (final m in RegExp(r'\*[^*]+\*').allMatches(text)) m.group(0)!];

  static bool _sameItems(List<String> a, List<String> b) {
    final x = [...a]..sort(), y = [...b]..sort();
    if (x.length != y.length) return false;
    for (var i = 0; i < x.length; i++) {
      if (x[i] != y[i]) return false;
    }
    return true;
  }

  static Map<String, (String, String)> _strings(Map<String, dynamic> overlay) {
    final raw = overlay['strings'];
    if (raw is! Map<String, dynamic>) return const {};
    return {
      for (final e in raw.entries)
        if (e.value is Map && (e.value as Map)['en'] is String && (e.value as Map)['fil'] is String)
          e.key: ((e.value as Map)['en'] as String, (e.value as Map)['fil'] as String),
    };
  }

  static Map<String, dynamic> _deepCopy(Map<String, dynamic> json) {
    Object? copy(Object? v) => switch (v) {
          Map<String, dynamic> m => {for (final e in m.entries) e.key: copy(e.value)},
          List l => [for (final x in l) copy(x)],
          _ => v,
        };
    return copy(json) as Map<String, dynamic>;
  }
}

class OverlayResult {
  const OverlayResult({required this.applied, required this.stale, required this.speakerNames});

  final int applied;
  final int stale;

  /// Speaker name in the JSON → name to show.
  final Map<String, String> speakerNames;
}
