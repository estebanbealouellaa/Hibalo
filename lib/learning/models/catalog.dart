import '../data/json_reader.dart';
import 'parts.dart';
import 'questions.dart';

/// The most parts a lesson may have (one bar segment each).
const int kMaxParts = 20;

/// Everything in assets/lessons/: the app settings (learning_settings.json)
/// and the levels with their lessons (one file per level). Loaded once by LessonRepository.
class LessonCatalog {
  LessonCatalog({
    required this.schemaVersion,
    required this.settings,
    required this.levels,
  });

  final int schemaVersion;
  final LearningSettings settings;
  final List<Level> levels;

  List<Lesson> get allLessons => [for (final l in levels) ...l.lessons];

  Lesson? lessonById(String id) {
    for (final lesson in allLessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  Level? levelOf(String lessonId) {
    for (final level in levels) {
      if (level.lessons.any((l) => l.id == lessonId)) return level;
    }
    return null;
  }

  Lesson? nextLesson(String lessonId) {
    final level = levelOf(lessonId);
    if (level == null) return null;
    final i = level.lessons.indexWhere((l) => l.id == lessonId);
    return i + 1 < level.lessons.length ? level.lessons[i + 1] : null;
  }

  /// [r] is learning_settings.json; [levelFiles] maps each `levels[].file` to its parsed file.
  /// A level with `"file": null` has no lessons yet.
  factory LessonCatalog.fromJson(
      JsonReader r, Map<String, JsonReader> levelFiles, AssetResolver assets) {
    final meta = r.object('_meta');
    final settings = LearningSettings.fromJson(r.object('settings'), assets);
    final levels = <Level>[];
    for (final entry in r.objects('levels')) {
      final id = entry.str('id');
      final title = entry.str('title');
      final unlockAfter = entry.objectOrNull('unlock')?.strOrNull('afterLevel');
      final file = entry.strOrNull('file');
      if (file == null) {
        levels.add(Level(id: id, title: title, unlockAfterLevel: unlockAfter, lessons: const []));
        continue;
      }
      final level = Level.fromJson(
          levelFiles[file] ?? entry.fail('level file "$file" was not loaded'), settings, assets);
      if (level.id != id || level.title != title || level.unlockAfterLevel != unlockAfter) {
        entry.fail('$file says ${level.id} / ${level.title} / after ${level.unlockAfterLevel}, '
            'the level list says $id / $title / after $unlockAfter');
      }
      levels.add(level);
    }
    return LessonCatalog(
      schemaVersion: meta.integer('schemaVersion'),
      settings: settings,
      levels: levels,
    );
  }
}

/// The app rules from `settings` in the JSON (pass mark, XP, timer, …).
class LearningSettings {
  LearningSettings({
    required this.passMark,
    required this.xp,
    required this.timerSeconds,
    required this.timedTypes,
    required this.resultTiers,
    required this.shuffleOptions,
    required this.shuffleBuildTiles,
    required this.shuffleMatchRightColumn,
    required this.missingPicture,
    required this.images,
    required this.avatars,
    required this.lastPartWithQuizButton,
    required this.lastPartNoQuizButton,
    required this.uiLanguages,
    required this.defaultUiLanguage,
    this.pronunciation = PronunciationSettings.off,
  });

  /// Q09 pronunciation similarity feedback (off until tuned).
  final PronunciationSettings pronunciation;

  /// Share of scored questions needed to pass (0.8 = 80%).
  final double passMark;
  final XpSettings xp;
  final int timerSeconds;

  /// Question types that have the countdown timer (e.g. "multiple_choice").
  final Set<String> timedTypes;

  /// Highest tier first.
  final List<ResultTier> resultTiers;

  final bool shuffleOptions;
  final bool shuffleBuildTiles;
  final bool shuffleMatchRightColumn;

  /// Asset path of the fallback picture (firefly_reading).
  final String missingPicture;

  /// Picture sizes in the app, by name ("lessonBanner", "wordPicture"…).
  final Map<String, ImageSlot> images;

  final AvatarRules avatars;

  /// Primary button text on a lesson's last part.
  final String lastPartWithQuizButton;
  final String lastPartNoQuizButton;

  final List<String> uiLanguages;
  final String defaultUiLanguage;

  /// The result tier for a score between 0 and 1.
  ResultTier tierFor(double score) =>
      resultTiers.firstWhere((t) => score >= t.minScore,
          orElse: () => resultTiers.last);

  factory LearningSettings.fromJson(JsonReader r, AssetResolver assets) {
    final timer = r.object('timer');
    final shuffle = r.object('shuffle');
    final images = r.object('images');
    final buttons = r.object('lessonButtons');
    final languages = r.object('uiLanguages');

    final tiers = [for (final t in r.objects('resultTiers')) ResultTier.fromJson(t)]
      ..sort((a, b) => b.minScore.compareTo(a.minScore));
    if (tiers.isEmpty) r.fail('resultTiers is empty');

    final missingName = images.str('missingPicture');
    final missing = assets.resolve(
        'images/mascots/$missingName.webp', 'settings > images > missingPicture');
    if (missing == null) {
      images.fail('fallback picture "$missingName" is not in the app');
    }

    return LearningSettings(
      passMark: r.number('passMark'),
      xp: XpSettings.fromJson(r.object('xp')),
      timerSeconds: timer.integer('seconds'),
      timedTypes: timer.strings('timedTypes').toSet(),
      resultTiers: tiers,
      shuffleOptions: shuffle.boolean('options'),
      shuffleBuildTiles: shuffle.boolean('buildTiles'),
      shuffleMatchRightColumn: shuffle.boolean('matchRightColumn'),
      missingPicture: missing,
      images: {
        for (final key in images.map.keys)
          if (images.map[key] is Map<String, dynamic>)
            key: ImageSlot.fromJson(images.object(key)),
      },
      avatars: AvatarRules.fromJson(r.object('avatars'), assets),
      lastPartWithQuizButton: buttons.str('lastPartWithQuiz'),
      lastPartNoQuizButton: buttons.str('lastPartNoQuiz'),
      uiLanguages: languages.strings('options'),
      defaultUiLanguage: languages.str('default'),
      pronunciation: PronunciationSettings.fromJson(r.objectOrNull('pronunciationFeedback')),
    );
  }
}

/// settings.pronunciationFeedback. Missing block = off.
class PronunciationSettings {
  const PronunciationSettings({
    required this.enabled,
    required this.veryClose,
    required this.almost,
    required this.minSpeechMs,
    required this.minLevelDb,
  });

  static const off = PronunciationSettings(
    enabled: false,
    veryClose: null,
    almost: null,
    minSpeechMs: 250,
    minLevelDb: -40,
  );

  final bool enabled;

  /// Score at or below this = "Very close"; at or below [almost] = "Almost".
  final double? veryClose;
  final double? almost;

  /// "Couldn't hear" when the sound is shorter or quieter than these.
  final int minSpeechMs;
  final double minLevelDb;

  /// Learners see the feedback only when it's switched on and tuned.
  bool get active => enabled && veryClose != null && almost != null;

  factory PronunciationSettings.fromJson(JsonReader? r) {
    if (r == null) return off;
    final veryClose = r.numberOrNull('veryClose');
    final almost = r.numberOrNull('almost');
    if (veryClose != null && almost != null && veryClose > almost) {
      r.fail('veryClose should not be above almost');
    }
    return PronunciationSettings(
      enabled: r.boolean('enabled'),
      veryClose: veryClose,
      almost: almost,
      minSpeechMs: r.integer('minSpeechMs'),
      minLevelDb: r.number('minLevelDb'),
    );
  }
}

class XpSettings {
  const XpSettings({
    required this.perCorrect,
    required this.lessonComplete,
    required this.quickCheck,
  });

  final int perCorrect;
  final int lessonComplete;
  final int quickCheck;

  factory XpSettings.fromJson(JsonReader r) => XpSettings(
        perCorrect: r.integer('perCorrect'),
        lessonComplete: r.integer('lessonComplete'),
        quickCheck: r.integer('quickCheck'),
      );
}

class ResultTier {
  const ResultTier({
    required this.minScore,
    required this.title,
    required this.passed,
  });

  final double minScore;
  final String title;
  final bool passed;

  factory ResultTier.fromJson(JsonReader r) => ResultTier(
        minScore: r.number('minScore'),
        title: r.str('title'),
        passed: r.boolean('passed'),
      );
}

class ImageSlot {
  const ImageSlot(this.width, this.height, {this.fit});

  final double width;
  final double height;

  /// "cover" for the lesson banner, null otherwise.
  final String? fit;

  factory ImageSlot.fromJson(JsonReader r) =>
      ImageSlot(r.number('width'), r.number('height'), fit: r.strOrNull('fit'));
}

/// Which avatar a dialogue speaker gets (`settings.avatars`): an exact name,
/// a "startsWith:" prefix, or the default.
class AvatarRules {
  AvatarRules({
    required this.byName,
    required this.byPrefix,
    required this.fallback,
  });

  /// Speaker name → avatar asset path (null if the file is missing).
  final Map<String, String?> byName;

  /// Name prefix → avatar asset path, e.g. "Manang" → avatar-manang.svg.
  final Map<String, String?> byPrefix;
  final String? fallback;

  String? avatarFor(String speaker) {
    if (byName.containsKey(speaker)) return byName[speaker];
    for (final entry in byPrefix.entries) {
      if (speaker.startsWith(entry.key)) return entry.value;
    }
    return fallback;
  }

  factory AvatarRules.fromJson(JsonReader r, AssetResolver assets) {
    String? path(String key) => assets.resolve(
        'images/avatars/${r.str(key)}.svg', 'settings > avatars > $key');

    final byName = <String, String?>{};
    final byPrefix = <String, String?>{};
    String? fallback;
    for (final key in r.map.keys) {
      if (key == 'note') continue; // a comment for people, not a rule
      if (key == 'default') {
        fallback = path(key);
      } else if (key.startsWith('startsWith:')) {
        byPrefix[key.substring('startsWith:'.length)] = path(key);
      } else {
        byName[key] = path(key);
      }
    }
    return AvatarRules(byName: byName, byPrefix: byPrefix, fallback: fallback);
  }
}

class Level {
  Level({
    required this.id,
    required this.title,
    required this.unlockAfterLevel,
    required this.lessons,
  });

  final String id;
  final String title;

  /// The level that must be finished first, or null for Beginner.
  final String? unlockAfterLevel;

  final List<Lesson> lessons;

  factory Level.fromJson(
      JsonReader r, LearningSettings settings, AssetResolver assets) {
    final lessons = [
      for (final l in r.objects('lessons'))
        Lesson.fromJson(l, settings, assets),
    ]..sort((a, b) => a.order.compareTo(b.order));

    // `units` (Intermediate): each listed lesson must carry that same unit.
    for (final u in r.objectsOrEmpty('units')) {
      final unit = LessonUnit.fromJson(u);
      for (final id in u.strings('lessons')) {
        final lesson = lessons.where((l) => l.id == id).firstOrNull ??
            u.fail('lesson "$id" is not in this level');
        if (lesson.unit != unit) u.fail('$id has unit ${lesson.unit}, expected $unit');
      }
    }
    return Level(
      id: r.str('id'),
      title: r.str('title'),
      unlockAfterLevel: r.objectOrNull('unlock')?.strOrNull('afterLevel'),
      lessons: lessons,
    );
  }
}

/// A group of lessons inside a level (Intermediate): the Learn list shows "Unit N · title" above its first lesson.
class LessonUnit {
  const LessonUnit(this.number, this.title);

  final int number;
  final String title;

  factory LessonUnit.fromJson(JsonReader r) => LessonUnit(r.integer('number'), r.str('title'));

  @override
  bool operator ==(Object other) =>
      other is LessonUnit && other.number == number && other.title == title;

  @override
  int get hashCode => Object.hash(number, title);

  @override
  String toString() => '$number · $title';
}

/// `kind` in the JSON: Lesson 1 is "letters" (no quiz), the rest are "words".
enum LessonKind { letters, words }

/// What unlocks a lesson (`unlock.needs`).
enum UnlockNeed {
  complete,

  passQuiz,
}

class UnlockRule {
  const UnlockRule({this.after, this.needs});

  /// Lesson id that must be done first, or null for the first lesson.
  final String? after;
  final UnlockNeed? needs;

  factory UnlockRule.fromJson(JsonReader r) {
    final needs = r.strOrNull('needs');
    return UnlockRule(
      after: r.strOrNull('after'),
      needs: switch (needs) {
        null => null,
        'complete' => UnlockNeed.complete,
        'passQuiz' => UnlockNeed.passQuiz,
        _ => r.fail('unknown unlock.needs "$needs"'),
      },
    );
  }
}

class Lesson {
  Lesson({
    required this.id,
    required this.order,
    required this.kind,
    this.unit,
    required this.title,
    required this.objectives,
    required this.estMinutes,
    required this.partsCount,
    required this.icon,
    required this.coverImage,
    required this.unlock,
    required this.items,
    required this.letters,
    required this.parts,
    required this.quiz,
  });

  final String id;

  /// 1, 2, 3… (the number shown in the lesson row).
  final int order;
  final LessonKind kind;

  /// Intermediate only; null for Beginner.
  final LessonUnit? unit;
  final String title;

  final List<String> objectives;
  final int estMinutes;
  final int partsCount;

  /// Asset paths, or null if the picture is missing (→ firefly_reading).
  final String? icon;
  final String? coverImage;

  final UnlockRule unlock;

  final List<LessonItem> items;

  /// Only Lesson 1 has letters.
  final List<Letter> letters;

  final List<LessonPart> parts;

  /// Null for Lesson 1.
  final Quiz? quiz;

  bool get isLetters => kind == LessonKind.letters;
  bool get hasQuiz => quiz != null;

  int get newWordsCount => items.length;

  factory Lesson.fromJson(
      JsonReader json, LearningSettings settings, AssetResolver assets) {
    final id = json.str('id');
    final r = JsonReader(json.map, id); // shorter error paths: "b02 > …"

    final kindName = r.str('kind');
    final kind = switch (kindName) {
      'letters' => LessonKind.letters,
      'words' => LessonKind.words,
      _ => r.fail('unknown kind "$kindName"'),
    };

    final items = [
      for (final (i, item) in r.objectsOrEmpty('items').indexed)
        LessonItem.fromJson(item, assets, '$id > items[$i]'),
    ];
    final letters = [
      for (final (i, letter) in r.objectsOrEmpty('letters').indexed)
        Letter.fromJson(letter, assets, '$id > letters[$i]'),
    ];

    final itemsById = <String, LessonItem>{};
    for (final item in items) {
      if (itemsById.containsKey(item.id)) r.fail('item id "${item.id}" is used twice');
      itemsById[item.id] = item;
    }

    final parts = [
      for (final p in r.objects('parts'))
        LessonPart.fromJson(p,
            itemsById: itemsById, letters: letters, assets: assets),
    ];
    final partsCount = r.integer('partsCount');
    if (partsCount != parts.length) {
      r.fail('partsCount is $partsCount but there are ${parts.length} parts');
    }
    if (parts.length > kMaxParts) r.fail('more than $kMaxParts parts (the bar holds $kMaxParts)');

    final partsById = <String, LessonPart>{};
    for (final part in parts) {
      if (partsById.containsKey(part.id)) r.fail('part id "${part.id}" is used twice');
      partsById[part.id] = part;
    }

    final quizJson = r.objectOrNull('quiz');
    final quiz = quizJson == null ? null : Quiz.fromJson(quizJson, assets, partsById);
    if (kind == LessonKind.words && quiz == null) r.fail('a words lesson needs a quiz');

    return Lesson(
      id: id,
      order: r.integer('order'),
      kind: kind,
      unit: r.objectOrNull('unit') == null ? null : LessonUnit.fromJson(r.object('unit')),
      title: r.str('title'),
      objectives: r.strings('objectives'),
      estMinutes: r.integer('estMinutes'),
      partsCount: partsCount,
      icon: assets.resolve(r.strOrNull('icon'), '$id > icon'),
      coverImage: assets.resolve(r.strOrNull('coverImage'), '$id > coverImage'),
      unlock: UnlockRule.fromJson(r.object('unlock')),
      items: items,
      letters: letters,
      parts: parts,
      quiz: quiz,
    );
  }
}

/// A Hiligaynon text with its Filipino meaning (examples, reading lines…).
class HilFil {
  const HilFil(this.hil, this.fil);

  final String hil;
  final String fil;

  factory HilFil.fromJson(JsonReader r) => HilFil(r.str('hil'), r.str('fil'));
}

/// A word or phrase on a P04 learn card (`items[]`).
class LessonItem {
  LessonItem({
    required this.id,
    required this.hil,
    required this.fil,
    required this.alt,
    required this.note,
    required this.audio,
    required this.image,
    required this.example,
    required this.verified,
  });

  final String id;
  final String hil;
  final String fil;

  /// Another Hiligaynon way to say it ("Also said: …"), or null.
  final String? alt;
  final String? note;

  /// The clip's asset path, or null if the JSON has none or it isn't recorded yet (no audio button).
  final String? audio;

  /// Picture asset path, or null if missing (→ firefly_reading).
  final String? image;

  /// Null hides the Example box.
  final HilFil? example;

  /// False when `check` is "unverified".
  final bool verified;

  factory LessonItem.fromJson(JsonReader r, AssetResolver assets, String where) =>
      LessonItem(
        id: r.str('id'),
        hil: r.str('hil'),
        fil: r.str('fil'),
        alt: r.strOrNull('alt'),
        note: r.strOrNull('note'),
        audio: assets.resolveAudio(r.strOrNull('audio'), '$where > audio'),
        image: assets.resolve(r.strOrNull('image'), '$where > image'),
        example: r.objectOrNull('example') == null
            ? null
            : HilFil.fromJson(r.object('example')),
        verified: r.strOrNull('check') != 'unverified',
      );
}

class Letter {
  Letter({
    required this.id,
    required this.letter,
    required this.name,
    required this.soundHint,
    required this.audio,
    required this.example,
  });

  final String id;

  /// Big and small form, e.g. "A a".
  final String letter;
  final String name;
  final String soundHint;

  /// One clip: the example word only (not the letter name). Null if it isn't in the app.
  final String? audio;
  final HilFil example;

  factory Letter.fromJson(JsonReader r, AssetResolver assets, String where) =>
      Letter(
        id: r.str('id'),
        letter: r.str('letter'),
        name: r.str('name'),
        soundHint: r.str('soundHint'),
        audio: assets.resolveAudio(r.strOrNull('audio'), '$where > audio'),
        example: HilFil.fromJson(r.object('example')),
      );
}

class Quiz {
  Quiz({required this.id, required this.questions});

  final String id;

  final List<QuizQuestion> questions;

  List<QuizQuestion> get scoredQuestions =>
      [for (final q in questions) if (q.scored) q];

  /// [parts]: the lesson's parts by id, for Q11's `passagePart`.
  factory Quiz.fromJson(JsonReader r, AssetResolver assets, Map<String, LessonPart> parts) {
    final questions = [
      for (final q in r.objects('questions')) QuizQuestion.fromJson(q, assets, parts),
    ];
    if (questions.isEmpty) r.fail('the quiz has no questions');
    // Q13: every set is setSize questions in a row, numbered 1…setSize, on one passage in one mode.
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      if (q is! PassageSetData || q.setIndex != 1) {
        if (q is PassageSetData && (i == 0 || questions[i - 1] is! PassageSetData)) {
          r.fail('${q.id}: a passage set starts with setIndex 1');
        }
        continue;
      }
      for (var k = 1; k < q.setSize; k++) {
        final next = i + k < questions.length ? questions[i + k] : null;
        if (next is! PassageSetData || next.setIndex != k + 1 || next.setSize != q.setSize ||
            next.passagePart != q.passagePart || next.mode != q.mode) {
          r.fail('${q.id}: the passage set needs ${q.setSize} questions in a row on ${q.passagePart}');
        }
      }
    }
    return Quiz(id: r.str('id'), questions: questions);
  }
}
