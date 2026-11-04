import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../lesson_image.dart';
import '../markup_text.dart';
import 'part_common.dart';

/// P10 · Culture note: the `title` chip ("Did you know?"), the picture
/// (firefly_reading until it exists), the "Culture note" label and the text.
class CultureNotePart extends StatelessWidget {
  const CultureNotePart({super.key, required this.data, required this.fallbackPicture});

  final CultureNotePartData data;
  final String fallbackPicture;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PartLayout(
      children: [
        // Figma "P10 · Culture note": card padding 20, radius 24, 12 between.
        PartCard(
          radius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SmallChip(data.title),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 295 / 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LessonImage(
                    path: data.image,
                    fallback: fallbackPicture,
                    fallbackColor: V6Colors.primaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(t.cultureNoteLabel, style: V6Text.labelMediumBold.copyWith(color: V6Colors.glowText)),
              const SizedBox(height: 12),
              MarkupText(
                data.text,
                textAlign: TextAlign.center,
                style: V6Text.bodyLargeSemiBold,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
