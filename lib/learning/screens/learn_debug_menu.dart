import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_language.dart';
import '../models/progress.dart';
import '../state/learning_progress.dart';

/// Debug builds only: sets lesson progress and the app language, so every
/// S01/S02 state can be checked before the lesson and quiz players exist.
/// The bug icon that opens it is hidden in release builds. English only on
/// purpose: it is a developer tool, not part of the app.
void showLearnDebugMenu(BuildContext context) {
  if (!kDebugMode) return;
  final progress = context.read<LearningProgress>();
  if (!progress.isReady) return;
  final lessons = progress.catalog.levels.first.lessons;

  LessonProgress done({bool passed = false, int? best}) => LessonProgress(
        partsDone: 0,
        completed: true,
        passed: passed,
        bestScore: best,
        completedAt: DateTime.now(),
      );

  int scored(int i) => lessons[i].quiz?.scoredQuestions.length ?? 0;

  final presets = <String, Map<String, LessonProgress>>{
    'Reset all progress': {},
    'Lesson 1 done': {lessons[0].id: done()},
    'Lesson 2 in progress (4 parts)': {
      lessons[0].id: done(),
      lessons[1].id: const LessonProgress(partsDone: 4),
    },
    'Lesson 2 finished, quiz pending': {
      lessons[0].id: done(),
      lessons[1].id: done(),
    },
    'Lessons 1–3 done (Quiz 7/8), Lesson 4 current': {
      lessons[0].id: done(),
      lessons[1].id: done(passed: true, best: 7),
      lessons[2].id: done(passed: true, best: 7),
    },
    'Lessons 1–12 passed, Lesson 13 quiz pending': {
      for (var i = 0; i < lessons.length; i++)
        lessons[i].id: i == 0
            ? done()
            : i == lessons.length - 1
                ? done()
                : done(passed: true, best: scored(i)),
    },
    'All Beginner passed': {
      for (var i = 0; i < lessons.length; i++)
        lessons[i].id: i == 0 ? done() : done(passed: true, best: scored(i)),
    },
  };

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const ListTile(title: Text('DEBUG · Lesson progress')),
          for (final entry in presets.entries)
            ListTile(
              dense: true,
              title: Text(entry.key),
              onTap: () {
                progress.debugReplaceLessons(entry.value);
                Navigator.pop(sheet);
              },
            ),
          const Divider(),
          const ListTile(title: Text('DEBUG · App language')),
          for (final language in AppLanguage.locales.keys)
            ListTile(
              dense: true,
              title: Text(language),
              trailing: AppLanguage.instance.language == language
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () {
                AppLanguage.instance.setLanguage(language);
                Navigator.pop(sheet);
              },
            ),
        ],
      ),
    ),
  );
}
