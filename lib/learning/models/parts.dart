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
  'P11': 'role_play',
  'P12': 'verb_forms',
  'P13': 'idiom_cards',
  'P14': 'register_pairs',
};

/// One part of a lesson. There is one subclass per template ID (P01 → KeyIdeaPart, … P14 → RegisterPairsPart),
/// and the part player picks the widget with an exhaustive `switch` on the subclass.
sealed class LessonPart {
  LessonPart(this.id, this.template);

  final String id;

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
          text: p.strOrNull('text'),
          terms: [for (final t in p.objectsOrEmpty('terms')) Term.fromJson(t)],
          tip: p.strOrNull('tip'),
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
      'P07' => DialoguePartData.fromJson(id, p, assets),
      'P08' => ReadingPartData(
          id,
          title: p.str('title'),
          icon: p.str('icon'),
          text: p.strOrNull('text'),
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
      'P11' => RolePlayPartData.fromJson(id, p),
      'P12' => VerbFormsPartData.fromJson(id, p),
      'P13' => IdiomCardsPartData.fromJson(id, p, assets),
      'P14' => RegisterPairsPartData.fromJson(id, p),
      _ => p.fail('unknown part template "$template"'),
    };
  }
}

class KeyIdeaPartData extends LessonPart {
  KeyIdeaPartData(
    String id, {
    required this.title,
    required this.icon,
    required this.text,
    required this.terms,
    this.tip,
  }) : super(id, 'P01');

  final String title;

  /// A Material Symbols Rounded name, e.g. "public".
  final String icon;

  /// May contain *markup*. Null hides it (some Intermediate parts).
  final String? text;

  final List<Term> terms;

  /// Tip card under the terms (a few Intermediate parts), or null.
  final String? tip;
}

class Term {
  const Term({required this.hil, this.note, this.fil, this.example});

  final String hil;

  /// NOTE row, hidden when null.
  final String? note;

  /// FILIPINO row, hidden when null.
  final String? fil;

  /// Example under the term (Intermediate), or null.
  final HilOptionalFil? example;

  factory Term.fromJson(JsonReader r) => Term(
        hil: r.str('hil'),
        note: r.strOrNull('note'),
        fil: r.strOrNull('fil'),
        example: r.objectOrNull('example') == null
            ? null
            : HilOptionalFil.fromJson(r.object('example')),
      );
}

/// Hiligaynon text whose Filipino line may be missing (`fil: null` = show no Filipino line).
class HilOptionalFil {
  const HilOptionalFil(this.hil, this.fil);

  final String hil;
  final String? fil;

  factory HilOptionalFil.fromJson(JsonReader r) => HilOptionalFil(r.str('hil'), r.strOrNull('fil'));
}

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

  /// Null hides it (some Intermediate parts).
  final String? text;

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
      text: p.strOrNull('text'),
      columns: columns,
      rows: rows,
      hilColumns: hilColumns,
    );
  }
}

class PatternPartData extends LessonPart {
  PatternPartData(
    String id, {
    required this.title,
    required this.icon,
    required this.text,
    required this.slots,
    this.sentence,
    required this.fil,
    required this.examples,
  }) : super(id, 'P03');

  final String title;
  final String icon;

  /// Null hides it (some Intermediate parts).
  final String? text;

  /// 3 to 5 slots; at most one has highlight = true (the link word).
  final List<PatternSlot> slots;

  /// The full sentence the slots build, shown under them (Intermediate), or null.
  final String? sentence;

  /// The Filipino meaning shown as "= fil".
  final String fil;
  final List<HilFil> examples;

  factory PatternPartData.fromJson(String id, JsonReader p) {
    final slots = [for (final s in p.objects('slots')) PatternSlot.fromJson(s)];
    if (slots.length < 3 || slots.length > 5) {
      p.fail('a pattern needs 3 to 5 slots, not ${slots.length}');
    }
    if (slots.where((s) => s.highlight).length > 1) {
      p.fail('only one slot can be highlighted');
    }
    return PatternPartData(
      id,
      title: p.str('title'),
      icon: p.str('icon'),
      text: p.strOrNull('text'),
      slots: slots,
      sentence: p.strOrNull('sentence'),
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

class WordsPartData extends LessonPart {
  WordsPartData(String id, {required this.title, required this.items})
      : super(id, 'P04');

  final String title;

  final List<LessonItem> items;

  @override
  int get stepCount => items.length;
}

class LettersPartData extends LessonPart {
  LettersPartData(String id, {required this.title, required this.letters})
      : super(id, 'P05');

  final String title;

  final List<Letter> letters;

  @override
  int get stepCount => letters.length;
}

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

class DialoguePartData extends LessonPart {
  DialoguePartData(
    String id, {
    required this.title,
    required this.icon,
    required this.setting,
    required this.lines,
    required this.tip,
    this.listening = false,
  }) : super(id, 'P07');

  final String title;
  final String icon;

  /// Null hides it (some Intermediate dialogues).
  final String? setting;
  final List<DialogueLine> lines;

  /// Null hides the tip card.
  final String? tip;

  /// True: hide the text until the audio has played once (or "Show text"). Every line has a clip in the JSON.
  final bool listening;

  /// The JSON names a clip on at least one line (recorded or not).
  bool get hasClips => lines.any((l) => l.hasClip);

  /// The line clips in order, or empty when any of them isn't in the app yet (then the text is shown).
  List<String> get clips =>
      lines.every((l) => l.audio != null) ? [for (final l in lines) l.audio!] : const [];

  factory DialoguePartData.fromJson(String id, JsonReader p, AssetResolver assets) {
    final lines = [
      for (final (i, l) in p.objects('lines').indexed)
        DialogueLine.fromJson(l, assets, '${p.path} > lines[$i]'),
    ];
    final listening = p.boolean('listening', fallback: false);
    if (listening && lines.any((l) => !l.hasClip)) p.fail('listening: every line needs audio');
    return DialoguePartData(
      id,
      title: p.str('title'),
      icon: p.str('icon'),
      setting: p.strOrNull('setting'),
      lines: lines,
      tip: p.strOrNull('tip'),
      listening: listening,
    );
  }
}

class DialogueLine {
  const DialogueLine({
    required this.speaker,
    required this.hil,
    required this.fil,
    this.audio,
    this.hasClip = false,
  });

  final String speaker;
  final String hil;
  final String fil;

  /// This line's clip (dialogues used for listening), or null when there is none or it isn't recorded yet.
  final String? audio;

  /// The JSON names a clip for this line (recorded or not).
  final bool hasClip;

  factory DialogueLine.fromJson(JsonReader r, AssetResolver assets, String where) => DialogueLine(
        speaker: r.str('speaker'),
        hil: r.str('hil'),
        fil: r.str('fil'),
        audio: assets.resolveAudio(r.strOrNull('audio'), '$where > audio'),
        hasClip: r.strOrNull('audio') != null,
      );
}

class ReadingPartData extends LessonPart {
  ReadingPartData(
    String id, {
    required this.title,
    required this.icon,
    this.text,
    required this.lines,
    required this.tip,
  }) : super(id, 'P08');

  final String title;
  final String icon;

  /// Intro line above the reading (Advanced), or null.
  final String? text;
  final List<HilFil> lines;
  final String? tip;
}

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
  /// Null hides the reason line (some Intermediate mistakes).
  final String? why;

  factory Mistake.fromJson(JsonReader r) =>
      Mistake(wrong: r.str('wrong'), right: r.str('right'), why: r.strOrNull('why'));
}

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

/// P11: a chat where the learner picks each reply. Text only, no audio.
class RolePlayPartData extends LessonPart {
  RolePlayPartData(
    String id, {
    required this.title,
    required this.icon,
    required this.setting,
    required this.turns,
    required this.tip,
  }) : super(id, 'P11');

  final String title;
  final String icon;
  final String setting;

  /// The other speaker's lines in order. Only the last turn may have no choices (the closing line).
  final List<RolePlayTurn> turns;

  /// Null hides the tip card.
  final String? tip;

  factory RolePlayPartData.fromJson(String id, JsonReader p) {
    final turns = [for (final t in p.objects('turns')) RolePlayTurn.fromJson(t)];
    if (turns.isEmpty) p.fail('a role-play needs at least one turn');
    for (var i = 0; i < turns.length - 1; i++) {
      if (turns[i].choices.isEmpty) p.fail('turns[$i] has no choices, but only the last turn may close');
    }
    return RolePlayPartData(
      id,
      title: p.str('title'),
      icon: p.str('icon'),
      setting: p.str('setting'),
      turns: turns,
      tip: p.strOrNull('tip'),
    );
  }
}

class RolePlayTurn {
  const RolePlayTurn({
    required this.speaker,
    required this.hil,
    required this.fil,
    required this.cue,
    required this.fast,
    required this.choices,
    this.quote,
  });

  final String speaker;
  final String hil;

  /// Null = show no Filipino line.
  final String? fil;

  /// Short instruction shown above the choices, or null.
  final String? cue;

  /// A quoted line under the speaker's bubble (Advanced, e.g. what someone else said), or null.
  final String? quote;

  /// Show a small "talking fast" label on this bubble.
  final bool fast;

  /// In JSON order (shuffle before showing). Exactly one is correct (it may be the only one,
  /// a reply to tap and say); empty = the closing line.
  final List<RolePlayChoice> choices;

  RolePlayChoice? get correctChoice => choices.where((c) => c.correct).firstOrNull;

  factory RolePlayTurn.fromJson(JsonReader r) {
    final choices = [for (final c in r.objectsOrEmpty('choices')) RolePlayChoice.fromJson(c)];
    if (choices.isNotEmpty) {
      final correct = choices.where((c) => c.correct).length;
      if (correct != 1) r.fail('needs exactly 1 correct choice, not $correct');
      if (choices.map((c) => c.hil).toSet().length != choices.length) r.fail('choices repeat');
      for (final c in choices) {
        if (!c.correct && c.hint == null) r.fail('wrong choice "${c.hil}" has no hint');
      }
    }
    return RolePlayTurn(
      speaker: r.str('speaker'),
      hil: r.str('hil'),
      fil: r.strOrNull('fil'),
      cue: r.strOrNull('cue'),
      fast: r.boolean('fast', fallback: false),
      choices: choices,
      quote: r.strOrNull('quote'),
    );
  }
}

class RolePlayChoice {
  const RolePlayChoice({
    required this.hil,
    required this.fil,
    required this.correct,
    required this.hint,
    this.note,
  });

  final String hil;

  /// Small grey label above the reply (e.g. "Filipino, to your friend"), or null.
  final String? note;

  /// Null = show no Filipino line.
  final String? fil;
  final bool correct;

  /// Shown after "Not quite" for a wrong choice; null on the correct one.
  final String? hint;

  factory RolePlayChoice.fromJson(JsonReader r) => RolePlayChoice(
        hil: r.str('hil'),
        fil: r.strOrNull('fil'),
        correct: r.boolean('correct'),
        hint: r.strOrNull('hint'),
        note: r.strOrNull('note'),
      );
}

/// P12: how a verb root changes; one root at a time, picked with chips.
class VerbFormsPartData extends LessonPart {
  VerbFormsPartData(
    String id, {
    required this.title,
    required this.icon,
    required this.text,
    required this.columns,
    required this.roots,
    required this.note,
  }) : super(id, 'P12');

  final String title;
  final String icon;

  /// May contain *markup*.
  final String text;

  /// The 3 time labels (e.g. Done / Ongoing / every day / Not yet), one per form.
  final List<String> columns;

  final List<VerbRoot> roots;

  /// Shown in a tip card, with *markup*; null hides it.
  final String? note;

  factory VerbFormsPartData.fromJson(String id, JsonReader p) {
    final columns = p.strings('columns');
    if (columns.length != 3) p.fail('verb forms need 3 columns, not ${columns.length}');
    final roots = [for (final r in p.objects('roots')) VerbRoot.fromJson(r)];
    if (roots.isEmpty) p.fail('verb forms need at least one root');
    if (roots.map((r) => r.root).toSet().length != roots.length) p.fail('roots repeat');
    return VerbFormsPartData(
      id,
      title: p.str('title'),
      icon: p.str('icon'),
      text: p.str('text'),
      columns: columns,
      roots: roots,
      note: p.strOrNull('note'),
    );
  }
}

class VerbRoot {
  const VerbRoot({
    required this.root,
    required this.fil,
    required this.forms,
    required this.doerForms,
    required this.example,
  });

  final String root;
  final String fil;

  /// One form per column. With [doerForms] these are the "What it happens to" forms.
  final List<String> forms;

  /// "Who does it" forms (one per column), or null for a single row of forms.
  final List<String>? doerForms;

  final HilFil example;

  factory VerbRoot.fromJson(JsonReader r) {
    final forms = r.strings('forms');
    if (forms.length != 3) r.fail('forms needs 3 entries, not ${forms.length}');
    final doer = r.has('doerForms') ? r.strings('doerForms') : null;
    if (doer != null && doer.length != 3) r.fail('doerForms needs 3 entries, not ${doer.length}');
    return VerbRoot(
      root: r.str('root'),
      fil: r.str('fil'),
      forms: forms,
      doerForms: doer,
      example: HilFil.fromJson(r.object('example')),
    );
  }
}

/// P13: idiom cards, one card at a time with "n / N" (Back/Next like P04). No title on screen.
class IdiomCardsPartData extends LessonPart {
  IdiomCardsPartData(String id, {required this.title, required this.cards}) : super(id, 'P13');

  /// Not shown (like word cards).
  final String title;
  final List<IdiomCard> cards;

  @override
  int get stepCount => cards.length;

  factory IdiomCardsPartData.fromJson(String id, JsonReader p, AssetResolver assets) {
    final cards = [
      for (final (i, c) in p.objects('cards').indexed) IdiomCard.fromJson(c, assets, '${p.path} > cards[$i]'),
    ];
    if (cards.isEmpty) p.fail('idiom cards need at least one card');
    if (cards.map((c) => c.id).toSet().length != cards.length) p.fail('card ids repeat');
    return IdiomCardsPartData(id, title: p.str('title'), cards: cards);
  }
}

class IdiomCard {
  const IdiomCard({
    required this.id,
    required this.hil,
    required this.literal,
    required this.means,
    required this.tone,
    required this.careful,
    required this.sayTo,
    required this.warning,
    required this.exampleHil,
    required this.exampleFil,
    required this.audio,
  });

  final String id;
  final String hil;

  /// "Word for word".
  final String literal;

  /// "What it really means".
  final String means;

  /// Tone chip text; [careful] shows it in the Warning colour.
  final String tone;
  final bool careful;

  /// "Who you can say it to".
  final String sayTo;

  /// Warning line, or null.
  final String? warning;

  /// Example lines (a dash per speaker), Hiligaynon and Filipino, same length.
  final List<String> exampleHil;
  final List<String> exampleFil;

  /// The idiom's clip, or null (none, or not recorded yet).
  final String? audio;

  factory IdiomCard.fromJson(JsonReader r, AssetResolver assets, String where) {
    final example = r.object('example');
    final hil = example.strings('hil');
    final fil = example.strings('fil');
    if (hil.isEmpty) example.fail('the example has no lines');
    if (hil.length != fil.length) example.fail('hil has ${hil.length} lines, fil has ${fil.length}');
    return IdiomCard(
      id: r.str('id'),
      hil: r.str('hil'),
      literal: r.str('literal'),
      means: r.str('means'),
      tone: r.str('tone'),
      careful: r.boolean('careful'),
      sayTo: r.str('sayTo'),
      warning: r.strOrNull('warning'),
      exampleHil: hil,
      exampleFil: fil,
      audio: assets.resolveAudio(r.strOrNull('audio'), '$where > audio'),
    );
  }
}

/// P14: two ways to say the same thing, one situation at a time with "n / N" (Back/Next).
/// Header = the situation title; the part title shows under it. No audio.
class RegisterPairsPartData extends LessonPart {
  RegisterPairsPartData(
    String id, {
    required this.title,
    required this.icon,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftWrongOnPurpose,
    required this.situations,
  }) : super(id, 'P14');

  /// Shown under each situation's title (what kind of pair it is).
  final String title;
  final String icon;
  final String leftLabel;
  final String rightLabel;

  /// The left card is the wrong way on purpose (grey, ✗, `left.note` instead of Filipino).
  final bool leftWrongOnPurpose;
  final List<RegisterSituation> situations;

  @override
  int get stepCount => situations.length;

  factory RegisterPairsPartData.fromJson(String id, JsonReader p) {
    final wrong = p.boolean('leftWrongOnPurpose');
    final situations = [for (final s in p.objects('situations')) RegisterSituation.fromJson(s)];
    if (situations.isEmpty) p.fail('register pairs need at least one situation');
    for (final (i, s) in situations.indexed) {
      if ((s.left.note != null) != wrong) {
        p.fail('situations[$i]: left.note ${s.left.note == null ? 'missing' : 'present'}, '
            'but leftWrongOnPurpose is $wrong');
      }
    }
    return RegisterPairsPartData(
      id,
      title: p.str('title'),
      icon: p.str('icon'),
      leftLabel: p.str('leftLabel'),
      rightLabel: p.str('rightLabel'),
      leftWrongOnPurpose: wrong,
      situations: situations,
    );
  }
}

class RegisterSituation {
  const RegisterSituation({required this.title, required this.left, required this.right, required this.changes});

  final String title;
  final RegisterSide left;
  final RegisterSide right;

  /// "What changed" chips, e.g. "imo → ninyo".
  final List<String> changes;

  factory RegisterSituation.fromJson(JsonReader r) => RegisterSituation(
        title: r.str('title'),
        left: RegisterSide.fromJson(r.object('left')),
        right: RegisterSide.fromJson(r.object('right')),
        changes: r.strings('changes'),
      );
}

class RegisterSide {
  const RegisterSide({required this.hil, required this.fil, required this.note});

  final String hil;

  /// Null = no Filipino line.
  final String? fil;

  /// Wrong-on-purpose explanation (with *markup*), shown instead of the Filipino; null otherwise.
  final String? note;

  factory RegisterSide.fromJson(JsonReader r) =>
      RegisterSide(hil: r.str('hil'), fil: r.strOrNull('fil'), note: r.strOrNull('note'));
}
