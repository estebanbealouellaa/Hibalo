import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/catalog.dart';
import 'json_reader.dart';

/// Loads assets/lessons/lessons.json once and keeps it in memory.
///
/// Lessons are bundled with the app, so this works offline. Picture and audio
/// paths are checked against the AssetManifest while loading: anything not in
/// the app becomes null, and the screens show the fallback picture or hide the
/// audio button.
class LessonRepository {
  LessonRepository._(this.catalog, this.assetRefs);

  static const String lessonsAsset = 'assets/lessons/lessons.json';

  /// The schema version this code was written for.
  static const int supportedSchema = 7;

  final LessonCatalog catalog;

  /// Every picture/audio path in the JSON and whether it is in the app.
  final List<AssetRef> assetRefs;

  /// JSON paths whose files aren't in the app yet (word pictures, audio…).
  List<AssetRef> get missingAssets =>
      [for (final ref in assetRefs) if (!ref.found) ref];

  static Future<LessonRepository>? _loading;

  /// The shared repository. The first call loads the JSON; later calls reuse
  /// it. If loading fails, the next call tries again.
  static Future<LessonRepository> instance() {
    return _loading ??= load(rootBundle).catchError((Object e) {
      _loading = null;
      throw e;
    });
  }

  /// Loads and checks the lessons from [bundle]. Throws [FormatException]
  /// naming the place in the JSON if something is wrong.
  static Future<LessonRepository> load(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final text = await bundle.loadString(lessonsAsset);
    return parse(text, manifest.listAssets().toSet());
  }

  /// Parses the JSON text. [availableAssets] is the set of bundled asset
  /// paths; tests can pass their own.
  static LessonRepository parse(String jsonText, Set<String> availableAssets) {
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('lessons.json: the top level should be an object');
    }
    final assets = AssetResolver(availableAssets);
    final catalog = LessonCatalog.fromJson(JsonReader(decoded, 'lessons.json'), assets);
    if (catalog.schemaVersion != supportedSchema) {
      throw FormatException('lessons.json: schema ${catalog.schemaVersion}, '
          'this app reads schema $supportedSchema');
    }
    _checkUnlocks(catalog);
    return LessonRepository._(catalog, List.unmodifiable(assets.refs));
  }

  /// Every unlock rule must point at an earlier lesson in the same level,
  /// and a "passQuiz" rule needs that lesson to have a quiz.
  static void _checkUnlocks(LessonCatalog catalog) {
    final ids = <String>{};
    for (final level in catalog.levels) {
      final earlier = <String, Lesson>{};
      for (final lesson in level.lessons) {
        if (!ids.add(lesson.id)) {
          throw FormatException('lessons.json: lesson id ${lesson.id} is used twice');
        }
        final after = lesson.unlock.after;
        if (after != null) {
          final before = earlier[after];
          if (before == null) {
            throw FormatException('${lesson.id}: unlock.after "$after" is not '
                'an earlier lesson in ${level.id}');
          }
          if (lesson.unlock.needs == UnlockNeed.passQuiz && !before.hasQuiz) {
            throw FormatException('${lesson.id}: needs the quiz of $after, '
                'which has no quiz');
          }
        }
        earlier[lesson.id] = lesson;
      }
    }
  }
}
