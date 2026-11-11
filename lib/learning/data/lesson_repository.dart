import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/catalog.dart';
import 'json_reader.dart';

/// Loads the bundled lesson files once (works offline) and checks picture/audio paths against the AssetManifest.
/// learning_settings.json holds the settings, templates and the level list; each level's lessons are in their own file.
class LessonRepository {
  LessonRepository._(this.catalog, this.assetRefs);

  static const String settingsAsset = 'assets/lessons/learning_settings.json';

  /// The schema version this code was written for.
  static const int supportedSchema = 8;

  final LessonCatalog catalog;

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

  static Future<LessonRepository> load(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final settingsText = await bundle.loadString(settingsAsset);
    final levelTexts = <String, String>{
      for (final file in levelFiles(settingsText))
        file: await bundle.loadString('assets/$file'),
    };
    return parse(settingsText, levelTexts, manifest.listAssets().toSet());
  }

  /// The level files named in learning_settings.json (`levels[].file`, paths inside assets/).
  static List<String> levelFiles(String settingsText) {
    final decoded = jsonDecode(settingsText);
    final levels = decoded is Map<String, dynamic> ? decoded['levels'] : null;
    if (levels is! List) return const [];
    return [
      for (final level in levels)
        if (level is Map<String, dynamic> && level['file'] is String) level['file'] as String,
    ];
  }

  /// Parses the settings file and the level files ([levelTexts]: file path → text).
  /// [availableAssets] is the set of bundled asset paths; tests can pass their own.
  static LessonRepository parse(
    String settingsText,
    Map<String, String> levelTexts,
    Set<String> availableAssets,
  ) {
    final settings = _decode(settingsText, 'learning_settings.json');
    final levels = {
      for (final entry in levelTexts.entries)
        entry.key: _decode(entry.value, entry.key.split('/').last),
    };
    final assets = AssetResolver(availableAssets);
    final catalog = LessonCatalog.fromJson(settings, levels, assets);
    if (catalog.schemaVersion != supportedSchema) {
      throw FormatException('learning_settings.json: schema ${catalog.schemaVersion}, '
          'this app reads schema $supportedSchema');
    }
    _checkUnlocks(catalog);
    return LessonRepository._(catalog, List.unmodifiable(assets.refs));
  }

  static JsonReader _decode(String text, String name) {
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('$name: the top level should be an object');
    }
    return JsonReader(decoded, name);
  }

  /// Every unlock rule must point at an earlier lesson in the same level,
  /// and a "passQuiz" rule needs that lesson to have a quiz.
  static void _checkUnlocks(LessonCatalog catalog) {
    final ids = <String>{};
    for (final level in catalog.levels) {
      final earlier = <String, Lesson>{};
      for (final lesson in level.lessons) {
        if (!ids.add(lesson.id)) {
          throw FormatException('lesson id ${lesson.id} is used twice');
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
