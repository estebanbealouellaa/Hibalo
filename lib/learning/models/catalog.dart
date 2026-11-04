import '../data/json_reader.dart';
import 'parts.dart';
import 'questions.dart';

/// Everything in assets/lessons/lessons.json: the app settings and the levels
/// with their lessons. Loaded once by LessonRepository.
class LessonCatalog {
  LessonCatalog({
    required this.schemaVersion,
    required this.settings,
    required this.levels,
  });

  final int schemaVersion;
  final LearningSettings settings;
  final List<Level> levels;

  /// Every lesson of every level, in level order then lesson order.
  List<Lesson> get allLessons => [for (final l in levels) ...l.lessons];

  Lesson? lessonById(String id) {
    for (final lesson in allLessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  /// The level that holds the lesson with this id.
  Level? levelOf(String lessonId) {
    for (final level in levels) {
      if (level.lessons.any((l) => l.id == lessonId)) return level;
    }
    return null;
  }

  /// The lesson after this one in the same level, or null for the last one.
  Lesson? nextLesson(String lessonId) {
    final level = levelOf(lessonId);
    if (level == null) return null;
    final i = level.lessons.indexWhere((l) => l.id == lessonId);
    return i + 1 < level.lessons.length ? level.lessons[i + 1] : null;
  }

  factory LessonCatalog.fromJson(JsonReader r, AssetResolver assets) {
    final meta = r.object('_meta');
    final settings = LearningSettings.fromJson(r.object('settings'), assets);
    final levels = [
      for (final level in r.objects('levels'))
        Level.fromJson(level, settings, assets),
    ];
    return LessonCatalog(
      schemaVersion: meta.integer('schemaVersion'),
      settings: settings,
      levels: levels,
    );
  }
}

// ── Settings ────────────────────────────────────────────────────────────────

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
  });

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

  bool isTimed(String questionType) => timedTypes.contains(questionType);

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

    // The fallback picture is given by name ("firefly_reading").
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

/// A picture slot size from `settings.images`.
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

  /// The avatar for a speaker, or null if its file isn't in the app.
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

// ── Levels and lessons ──────────────────────────────────────────────────────

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

  /// In lesson order.
  final List<Lesson> lessons;

  factory Level.fromJson(
      JsonReader r, LearningSettings settings, AssetResolver assets) {
    final lessons = [
      for (final l in r.objects('lessons'))
        Lesson.fromJson(l, settings, assets),
    ]..sort((a, b) => a.order.compareTo(b.order));
    return Level(
      id: r.str('id'),
      title: r.str('title'),
      unlockAfterLevel: r.objectOrNull('unlock')?.strOrNull('afterLevel'),
      lessons: lessons,
    );
  }
}

/// `kind` in the JSON: Lesson 1 is "letters" (no quiz), the rest are "words".
enum LessonKind { letters, words }

/// What unlocks a lesson (`unlock.needs`).
enum UnlockNeed {
  /// The lesson in `after` is finished.
  complete,

  /// The quiz of the lesson in `after` is passed.
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
  final String title;

  /// The "In this lesson:" list on Lesson Detail.
  final List<String> objectives;
  final int estMinutes;
  final int partsCount;

  /// Asset paths, or null if the picture is missing (→ firefly_reading).
  final String? icon;
  final String? coverImage;

  final UnlockRule unlock;

  /// Learn-card words, in JSON order.
  final List<LessonItem> items;

  /// Only Lesson 1 has letters.
  final List<Letter> letters;

  final List<LessonPart> parts;

  /// Null for Lesson 1.
  final Quiz? quiz;

  bool get isLetters => kind == LessonKind.letters;
  bool get hasQuiz => quiz != null;

  /// The "N New words" tile on Lesson complete.
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
    if (parts.length > 14) r.fail('more than 14 parts (the bar holds 14)');

    final quizJson = r.objectOrNull('quiz');
    final quiz = quizJson == null ? null : Quiz.fromJson(quizJson, assets);
    if (kind == LessonKind.words && quiz == null) r.fail('a words lesson needs a quiz');

    return Lesson(
      id: id,
      order: r.integer('order'),
      kind: kind,
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

  /// Asset paths, or null if missing (no audio button / firefly_reading).
  final String? audio;
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
        audio: assets.resolve(r.strOrNull('audio'), '$where > audio'),
        image: assets.resolve(r.strOrNull('image'), '$where > image'),
        example: r.objectOrNull('example') == null
            ? null
            : HilFil.fromJson(r.object('example')),
        verified: r.strOrNull('check') != 'unverified',
      );
}

/// One letter card in Lesson 1 (`letters[]`).
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

  /// One clip: the letter, then its example word. Null if missing.
  final String? audio;
  final HilFil example;

  factory Letter.fromJson(JsonReader r, AssetResolver assets, String where) =>
      Letter(
        id: r.str('id'),
        letter: r.str('letter'),
        name: r.str('name'),
        soundHint: r.str('soundHint'),
        audio: assets.resolve(r.strOrNull('audio'), '$where > audio'),
        example: HilFil.fromJson(r.object('example')),
      );
}

class Quiz {
  Quiz({required this.id, required this.questions});

  final String id;

  /// In quiz order.
  final List<QuizQuestion> questions;

  List<QuizQuestion> get scoredQuestions =>
      [for (final q in questions) if (q.scored) q];

  factory Quiz.fromJson(JsonReader r, AssetResolver assets) {
    final questions = [
      for (final q in r.objects('questions')) QuizQuestion.fromJson(q, assets),
    ];
    if (questions.isEmpty) r.fail('the quiz has no questions');
    return Quiz(id: r.str('id'), questions: questions);
  }
}
