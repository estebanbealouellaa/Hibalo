import '../data/json_reader.dart';
import 'catalog.dart';

/// Lesson part templates: template ID → `type` in the JSON.
/// Each ID has exactly one widget (P01 → KeyIdeaPart, … P10 → CultureNotePart).
const Map<String, String> kPartTemplates = {
  'P01': 'key_idea',
  'P02': 'table',
  'P03': 'pattern',
  'P04': 'words',
  'P05': 'letters',
  'P06': 'quick_check',
  'P07': 'dialogue',
  'P08': 'reading',
  'P09': 'bridge_mistakes',
  'P10': 'culture_note',
};

/// One part of a lesson. There is one subclass per template ID, and the part
/// player picks the widget with an exhaustive `switch` on the subclass.
sealed class LessonPart {
  LessonPart(this.id, this.template);

  final String id;

  /// "P01" … "P10".
  final String template;

  /// How many Back/Next steps the part has: one per card (P04) or letter
  /// (P05), otherwise 1.
  int get stepCount => 1;

  factory LessonPart.fromJson(
    JsonReader r, {
    required Map<String, LessonItem> itemsById,
    required List<Letter> letters,
    required AssetResolver assets,
  }) {
    final id = r.str('id');
    final p = JsonReader(r.map, '${r.path} ($id)');
    final template = p.str('template');
    final type = p.str('type');
    final expected = kPartTemplates[template];
    if (expected == null) p.fail('unknown part template "$template"');
    if (expected != type) {
      p.fail('template $template should have type "$expected", not "$type"');
    }

    return switch (template) {
      'P01' => KeyIdeaPartData(
          id,
          title: p.str('title'),
          icon: p.str('icon'),
          text: p.str('text'),
          terms: [for (final t in p.objectsOrEmpty('terms')) Term.fromJson(t)],
        ),
      'P02' => TablePartData.fromJson(id, p),
      'P03' => PatternPartData.fromJson(id, p),
      'P04' => WordsPartData(
          id,
          title: p.str('title'),
          items: [
            for (final itemId in p.strings('itemIds'))
              itemsById[itemId] ?? p.fail('itemId "$itemId" is not in items'),
          ],
        ),
      'P05' => letters.isEmpty
          ? p.fail('a letters part needs the lesson\'s letters list')
          : LettersPartData(id, title: p.str('title'), letters: letters),
      'P06' => QuickCheckPartData.fromJson(id, p),
      'P07' => DialoguePartData(
          id,
          title: p.str('title'),
          icon: p.str('icon'),
          setting: p.str('setting'),
          lines: [for (final l in p.objects('lines')) DialogueLine.fromJson(l)],
          tip: p.strOrNull('tip'),
        ),
      'P08' => ReadingPartData(
          id,
          title: p.str('title'),
          icon: p.str('icon'),
          lines: [for (final l in p.objects('lines')) HilFil.fromJson(l)],
          tip: p.strOrNull('tip'),
        ),
      'P09' => BridgeMistakesPartData(
          id,
          title: p.str('title'),
          icon: p.str('icon'),
          bridge: p.strings('bridge'),
          mistakes: [for (final m in p.objects('mistakes')) Mistake.fromJson(m)],
        ),
      'P10' => CultureNotePartData(
          id,
          title: p.str('title'),
          text: p.str('text'),
          image: assets.resolve(p.strOrNull('image'), '${p.path} > image'),
        ),
      _ => p.fail('unknown part template "$template"'),
    };
  }
}

// ── P01 Key idea ────────────────────────────────────────────────────────────

class KeyIdeaPartData extends LessonPart {
  KeyIdeaPartData(
    String id, {
    required this.title,
    required this.icon,
    required this.text,
    required this.terms,
  }) : super(id, 'P01');

  final String title;

  /// A Material Symbols Rounded name, e.g. "public".
  final String icon;

  /// May contain *markup*.
  final String text;

  /// Optional term cards (may be empty).
  final List<Term> terms;
}

class Term {
  const Term({required this.hil, this.note, this.fil});

  final String hil;

  /// NOTE row, hidden when null.
  final String? note;

  /// FILIPINO row, hidden when null.
  final String? fil;

  factory Term.fromJson(JsonReader r) =>
      Term(hil: r.str('hil'), note: r.strOrNull('note'), fil: r.strOrNull('fil'));
}

// ── P02 Table ───────────────────────────────────────────────────────────────

class TablePartData extends LessonPart {
  TablePartData(
    String id, {
    required this.title,
    required this.icon,
    required this.text,
    required this.columns,
    required this.rows,
    required this.hilColumns,
  }) : super(id, 'P02');

  final String title;
  final String icon;
  final String text;

  /// 2 to 4 column names. "" is an empty header cell.
  final List<String> columns;

  /// Every row has one cell per column.
  final List<List<String>> rows;

  /// Indexes of the Hiligaynon columns (italic violet).
  final Set<int> hilColumns;

  factory TablePartData.fromJson(String id, JsonReader p) {
    final columns = p.strings('columns');
    if (columns.length < 2 || columns.length > 4) {
      p.fail('a table needs 2 to 4 columns, not ${columns.length}');
    }
    final rows = <List<String>>[];
    for (final (i, row) in p.list('rows').indexed) {
      if (row is! List || row.any((c) => c is! String)) {
        p.fail('rows[$i] should be a list of text');
      }
      if (row.length != columns.length) {
        p.fail('rows[$i] has ${row.length} cells, expected ${columns.length}');
      }
      rows.add(row.cast<String>());
    }
    final hilColumns = p.ints('hilColumns').toSet();
    for (final c in hilColumns) {
      if (c < 0 || c >= columns.length) p.fail('hilColumns has $c, out of range');
    }
    return TablePartData(
      id,
      title: p.str('title'),
      icon: p.str('icon'),
      text: p.str('text'),
      columns: columns,
      rows: rows,
      hilColumns: hilColumns,
    );
  }
}

// ── P03 Pattern ─────────────────────────────────────────────────────────────

class PatternPartData extends LessonPart {
  PatternPartData(
    String id, {
    required this.title,
    required this.icon,
    required this.text,
    required this.slots,
    required this.fil,
    required this.examples,
  }) : super(id, 'P03');

  final String title;
  final String icon;
  final String text;

  /// 3 or 4 slots; at most one has highlight = true (the link word).
  final List<PatternSlot> slots;

  /// The Filipino meaning shown as "= fil".
  final String fil;
  final List<HilFil> examples;

  factory PatternPartData.fromJson(String id, JsonReader p) {
    final slots = [for (final s in p.objects('slots')) PatternSlot.fromJson(s)];
    if (slots.length < 3 || slots.length > 4) {
      p.fail('a pattern needs 3 or 4 slots, not ${slots.length}');
    }
    if (slots.where((s) => s.highlight).length > 1) {
      p.fail('only one slot can be highlighted');
    }
    return PatternPartData(
      id,
      title: p.str('title'),
      icon: p.str('icon'),
      text: p.str('text'),
      slots: slots,
      fil: p.str('fil'),
      examples: [for (final e in p.objectsOrEmpty('examples')) HilFil.fromJson(e)],
    );
  }
}

class PatternSlot {
  const PatternSlot({required this.label, required this.hil, this.highlight = false});

  /// Small label above the block; "" shows nothing.
  final String label;
  final String hil;
  final bool highlight;

  factory PatternSlot.fromJson(JsonReader r) => PatternSlot(
        label: r.str('label'),
        hil: r.str('hil'),
        highlight: r.boolean('highlight', fallback: false),
      );
}

// ── P04 Words (learn cards) ─────────────────────────────────────────────────

class WordsPartData extends LessonPart {
  WordsPartData(String id, {required this.title, required this.items})
      : super(id, 'P04');

  final String title;

  /// One learn card per item, in `itemIds` order.
  final List<LessonItem> items;

  @override
  int get stepCount => items.length;
}

// ── P05 Letters & sounds ────────────────────────────────────────────────────

class LettersPartData extends LessonPart {
  LettersPartData(String id, {required this.title, required this.letters})
      : super(id, 'P05');

  final String title;

  /// The lesson's letters (19 in Lesson 1).
  final List<Letter> letters;

  @override
  int get stepCount => letters.length;
}

// ── P06 Quick check ─────────────────────────────────────────────────────────

class QuickCheckPartData extends LessonPart {
  QuickCheckPartData(
    String id, {
    required this.prompt,
    required this.options,
    required this.answer,
    required this.explain,
  }) : super(id, 'P06');

  final String prompt;

  /// In JSON order. Shuffle before showing.
  final List<String> options;

  /// Index of the right option in [options].
  final int answer;
  final String explain;

  factory QuickCheckPartData.fromJson(String id, JsonReader p) {
    final options = p.strings('options');
    final answer = p.integer('answer');
    checkOptions(p, options, answer);
    return QuickCheckPartData(
      id,
      prompt: p.str('prompt'),
      options: options,
      answer: answer,
      explain: p.str('explain'),
    );
  }
}

/// Shared check for option lists: at least 2 options, no repeats, and the
/// answer index points at one of them.
void checkOptions(JsonReader r, List<String> options, int answer) {
  if (options.length < 2) r.fail('needs at least 2 options');
  if (options.toSet().length != options.length) r.fail('options repeat');
  if (answer < 0 || answer >= options.length) {
    r.fail('answer $answer is out of range (0–${options.length - 1})');
  }
}

// ── P07 Dialogue ────────────────────────────────────────────────────────────

class DialoguePartData extends LessonPart {
  DialoguePartData(
    String id, {
    required this.title,
    required this.icon,
    required this.setting,
    required this.lines,
    required this.tip,
  }) : super(id, 'P07');

  final String title;
  final String icon;

  /// One line describing the scene.
  final String setting;
  final List<DialogueLine> lines;

  /// Null hides the tip card.
  final String? tip;
}

class DialogueLine {
  const DialogueLine({required this.speaker, required this.hil, required this.fil});

  final String speaker;
  final String hil;
  final String fil;

  factory DialogueLine.fromJson(JsonReader r) =>
      DialogueLine(speaker: r.str('speaker'), hil: r.str('hil'), fil: r.str('fil'));
}

// ── P08 Reading ─────────────────────────────────────────────────────────────

class ReadingPartData extends LessonPart {
  ReadingPartData(
    String id, {
    required this.title,
    required this.icon,
    required this.lines,
    required this.tip,
  }) : super(id, 'P08');

  final String title;
  final String icon;
  final List<HilFil> lines;
  final String? tip;
}

// ── P09 Filipino bridge & mistakes ──────────────────────────────────────────

class BridgeMistakesPartData extends LessonPart {
  BridgeMistakesPartData(
    String id, {
    required this.title,
    required this.icon,
    required this.bridge,
    required this.mistakes,
  }) : super(id, 'P09');

  final String title;
  final String icon;

  /// Bullet points, with *markup*.
  final List<String> bridge;
  final List<Mistake> mistakes;
}

class Mistake {
  const Mistake({required this.wrong, required this.right, required this.why});

  final String wrong;
  final String right;
  final String why;

  factory Mistake.fromJson(JsonReader r) =>
      Mistake(wrong: r.str('wrong'), right: r.str('right'), why: r.str('why'));
}

// ── P10 Culture note ────────────────────────────────────────────────────────

class CultureNotePartData extends LessonPart {
  CultureNotePartData(
    String id, {
    required this.title,
    required this.text,
    required this.image,
  }) : super(id, 'P10');

  final String title;
  final String text;

  /// Asset path, or null if missing (→ firefly_reading).
  final String? image;
}
