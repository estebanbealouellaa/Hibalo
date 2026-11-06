import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../learning/learning_routes.dart';
import '../../learning/models/catalog.dart';
import '../../learning/services/lesson_audio.dart';
import '../../learning/state/learning_progress.dart';
import '../../widgets/v6/v6.dart';
import '../../widgets/v6/v6_avatar.dart';
import 'home_logic.dart';

/// V6 · Accent Soft, the Continue card fill (not in the Learning tokens).
const Color _accentSoft = Color(0xFFD3C2F6);

/// Home (Figma 468:1943, first time 677:7491): greeting and avatar, the
/// streak / lessons / XP pills, the Continue card and the Phrase of the day.
class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.userName,
    required this.photoUrl,
    required this.onOpenLearn,
    this.clock = DateTime.now,
  });

  final String userName;
  final String? photoUrl;

  /// Switches to the Learn tab (the "all done" card).
  final VoidCallback onOpenLearn;

  /// The phone's clock (greeting and Phrase of the day); fixed in tests.
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final progress = context.watch<LearningProgress>();
    final now = clock();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: V6Colors.background,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${greetingFor(now)}\n$userName.',
                      style: V6Text.headlineLargeTight.copyWith(letterSpacing: -0.28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  V6Avatar(photoUrl: photoUrl),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: StatPill(
                      icon: Icons.local_fire_department_rounded,
                      value: progress.streak,
                      label: t.homeDayStreak,
                      color: V6Colors.coral,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatPill(
                      icon: Icons.menu_book_rounded,
                      value: progress.lessonsCompleted,
                      label: progress.lessonsCompleted == 1 ? t.homeLesson : t.homeLessons,
                      color: V6Colors.lagoon,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatPill(icon: Icons.bolt_rounded, value: progress.xp, label: t.homeXp, color: V6Colors.citrus),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              if (progress.isReady) ...[
                ContinueCard(pick: pickContinue(progress.catalog, progress.rules), onOpenLearn: onOpenLearn),
                const SizedBox(height: 24),
                if (phraseOfTheDay(progress.catalog, now) case final item?) PhraseOfTheDayCard(item: item),
              ] else if (progress.loadError == null)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma "Stat": a 26-high pill with an icon, the value and a label.
class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.icon, required this.value, required this.label, required this.color});

  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = V6Text.labelSmall.copyWith(color: V6Colors.primaryStrong);
    return Semantics(
      label: '$value ${label.toLowerCase()}',
      excludeSemantics: true,
      child: Container(
        height: 26,
        padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
        // Figma draws the pill fill at half strength over the background.
        decoration: ShapeDecoration(color: color.withValues(alpha: 0.5), shape: const StadiumBorder()),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: V6Colors.primaryStrong),
              const SizedBox(width: 4),
              Text('$value', style: style),
              const SizedBox(width: 4),
              Text(label, style: style),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma "Continue learning card" / "Start learning card".
class ContinueCard extends StatelessWidget {
  const ContinueCard({super.key, required this.pick, required this.onOpenLearn});

  final ContinuePick pick;
  final VoidCallback onOpenLearn;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lesson = pick.lesson;
    final level = pick.level;
    final levelIndex = level == null ? 0 : context.read<LearningProgress>().catalog.levels.indexOf(level);
    final allDone = pick.kind == ContinueKind.allDone;
    final (mascot, title, progressLabel, buttonLabel) = switch (pick.kind) {
      ContinueKind.firstTime || ContinueKind.notStarted => (
          'firefly_backpack',
          t.homeLessonTitle(lesson.order, lesson.title),
          t.homePartsDone(0, pick.partsCount),
          t.homeStartLesson(lesson.order),
        ),
      ContinueKind.inProgress => (
          'firefly_reading',
          t.homeLessonTitle(lesson.order, lesson.title),
          t.homePartOf(pick.nextPart, pick.partsCount),
          t.continueLesson,
        ),
      ContinueKind.quizPending => (
          'firefly_reading',
          t.homeLessonTitle(lesson.order, lesson.title),
          t.homePartsDone(pick.partsCount, pick.partsCount),
          t.homeTakeQuiz,
        ),
      ContinueKind.allDone => (
          'firefly_celebrate',
          level == null ? t.homeAllComplete : t.homeLevelComplete(level.title),
          t.homeEveryLessonDone,
          t.homeReviewLessons,
        ),
    };
    final value = allDone ? 1.0 : pick.partsDone / pick.partsCount;

    void open() {
      switch (pick.kind) {
        case ContinueKind.firstTime || ContinueKind.notStarted:
          LearningRoutes.openLessonDetail(context, lesson);
        case ContinueKind.inProgress:
          final rules = context.read<LearningProgress>().rules;
          LearningRoutes.openLessonPlayer(context, lesson, startPart: rules.firstUnfinishedPart(lesson));
        case ContinueKind.quizPending:
          LearningRoutes.openLessonComplete(context, lesson);
        case ContinueKind.allDone:
          onOpenLearn();
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: _accentSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V6Colors.textSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (level != null) V6Chip(label: t.homeLevelChip(level.title, levelIndex + 1), tone: V6ChipTone.surface),
                    const SizedBox(height: 8),
                    Text(title, style: V6Text.headlineMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 82,
                height: 90,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned(
                      left: 5,
                      top: 14,
                      width: 72,
                      height: 72,
                      child: DecoratedBox(decoration: BoxDecoration(color: V6Colors.citrus, shape: BoxShape.circle)),
                    ),
                    Positioned(
                      left: -26,
                      top: -21,
                      width: 108,
                      height: 122,
                      child: Image.asset(
                        'assets/images/mascots/$mascot.webp',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: V6Colors.primary,
                    color: V6Colors.glow,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(progressLabel, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          V6Button(label: buttonLabel, expand: true, onPressed: open),
        ],
      ),
    );
  }
}

/// Figma "Phrase of the day card": Listen plays the word's recorded clip (silent until recorded), never the TTS voice.
class PhraseOfTheDayCard extends StatelessWidget {
  const PhraseOfTheDayCard({super.key, required this.item});

  final LessonItem item;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tag = V6Text.labelMedium.copyWith(color: V6Colors.glowText);
    final example = item.example;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: V6Colors.glowContainerSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V6Colors.glow),
        boxShadow: const [
          BoxShadow(color: Color(0x0F321B58), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0F321B58), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.format_quote_rounded, size: 40, color: V6Colors.glow),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: V6Colors.glow),
                  const SizedBox(width: 6),
                  Text(t.homePhraseOfDay, style: V6Text.labelLarge),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hiligaynon', style: tag),
                        const SizedBox(height: 2),
                        Text(item.hil, style: V6Text.headlineLargeTight.copyWith(fontWeight: FontWeight.w700, height: 36 / 28, letterSpacing: -0.2)),
                        const SizedBox(height: 8),
                        Text('Filipino', style: tag),
                        const SizedBox(height: 2),
                        Text(item.fil, style: V6Text.bodyLarge.copyWith(color: V6Colors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: V6Colors.glow,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: t.commonListen,
                      onPressed: () => LessonAudio.instance.play(item.audio),
                      icon: const Icon(Icons.volume_up_rounded, color: V6Colors.primaryStrong),
                    ),
                  ),
                ],
              ),
              if (example != null) ...[
                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1, color: V6Colors.glowTonal),
                const SizedBox(height: 8),
                _ExampleLine(text: example.hil, bold: item.hil),
                const SizedBox(height: 2),
                Text(example.fil, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ExampleLine extends StatelessWidget {
  const _ExampleLine({required this.text, required this.bold});

  final String text;
  final String bold;

  @override
  Widget build(BuildContext context) {
    final base = V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary);
    final strong = V6Text.labelLargeBold.copyWith(color: V6Colors.textPrimary);
    final at = text.toLowerCase().indexOf(bold.toLowerCase());
    if (at < 0) return Text(text, style: base);
    return Text.rich(TextSpan(children: [
      TextSpan(text: text.substring(0, at), style: base),
      TextSpan(text: text.substring(at, at + bold.length), style: strong),
      TextSpan(text: text.substring(at + bold.length), style: base),
    ]));
  }
}
