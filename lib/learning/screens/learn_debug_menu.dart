import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_language.dart';
import '../models/progress.dart';
import '../state/learning_progress.dart';

/// Debug builds only (no bug icon in release): sets lesson progress and the app language for testing; English on purpose.
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

  final beginnerPassed = {
    for (var i = 0; i < lessons.length; i++)
      lessons[i].id: i == 0 ? done() : done(passed: true, best: scored(i)),
  };
  final intermediate = [
    for (final level in progress.catalog.levels)
      if (level.id == 'intermediate') ...level.lessons,
  ];

  /// All Beginner passed and Intermediate Lessons 1…[count] passed (full score).
  Map<String, LessonProgress> intermediatePassed(int count) => {
        ...beginnerPassed,
        for (final l in intermediate.take(count))
          l.id: done(passed: true, best: l.quiz?.scoredQuestions.length ?? 0),
      };

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
    'All Beginner passed': beginnerPassed,
    if (intermediate.length >= 12) ...{
      'Intermediate: Lesson 3 current': intermediatePassed(2),
      'Intermediate: Lesson 10 current': intermediatePassed(9),
      'Intermediate: Lesson 12 current': intermediatePassed(11),
      'Intermediate: Lesson 12 finished, quiz pending': {
        ...intermediatePassed(11),
        intermediate[11].id: done(),
      },
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
              onTap: () async {
                Navigator.pop(sheet);
                if (entry.value.isNotEmpty) {
                  await progress.debugReplaceLessons(entry.value);
                  return;
                }
                // Reset: the phone copy and this account's cloud progress.
                final messenger = ScaffoldMessenger.maybeOf(context);
                final cleared = await progress.debugResetAll();
                messenger?.showSnackBar(SnackBar(
                  content: Text(cleared
                      ? 'Progress reset on the phone and in the cloud'
                      : 'Phone reset. Cloud progress could not be cleared (offline?)'),
                ));
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
