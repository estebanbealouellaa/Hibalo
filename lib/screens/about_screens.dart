import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/v6/v6.dart';

/// One section of an info card: an optional icon, a title and the text.
class InfoSection {
  const InfoSection(this.title, this.text, {this.icon, this.onTap});

  final String title;
  final String? text;
  final IconData? icon;
  final VoidCallback? onTap;
}

/// Settings › Privacy policy: Lance's text, word for word in English (fil/hil are drafts).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _InfoPage(
      title: t.settingsPrivacy,
      intro: t.privacyIntro,
      sections: [
        InfoSection(t.privacySaveLabel, t.privacySaveText),
        InfoSection(t.privacyNotSaveLabel, t.privacyNotSaveText),
        InfoSection(t.privacyWhoLabel, t.privacyWhoText),
        InfoSection(t.privacyUseLabel, t.privacyUseText),
        InfoSection(t.privacyDeleteLabel, t.privacyDeleteText),
        InfoSection(t.privacyQuestionsLabel, t.privacyQuestionsText),
      ],
    );
  }
}

/// Settings › Credits & licences (Figma 612:5896 layout). Lance's text (Nov
/// 6). The last row opens Flutter's licence list.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _InfoPage(
      title: t.settingsCredits,
      intro: t.creditsIntro,
      sections: [
        InfoSection(t.creditsVoiceLabel, t.creditsVoiceText, icon: Icons.graphic_eq_rounded),
        InfoSection(t.creditsDataLabel, t.creditsDataText, icon: Icons.dataset_rounded),
        InfoSection(t.creditsTranslationLabel, t.creditsTranslationText, icon: Icons.translate_rounded),
        InfoSection(t.creditsLessonsLabel, t.creditsLessonsText, icon: Icons.menu_book_rounded),
        InfoSection(t.creditsReadingLabel, t.creditsReadingText, icon: Icons.star_rounded),
        InfoSection(
          t.creditsOpenSource,
          null,
          icon: Icons.code_rounded,
          onTap: () => showLicensePage(context: context, applicationName: 'Hibalo'),
        ),
      ],
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({required this.title, required this.intro, required this.sections});

  final String title;
  final String intro;
  final List<InfoSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V6Colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            V6TopAppBar(title: title, onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(intro, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: V6Colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: V6Colors.borderDivider),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final (i, s) in sections.indexed) ...[
                          if (i > 0) const Divider(height: 1, thickness: 1, color: V6Colors.borderDivider),
                          _SectionRow(section: s),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section});

  final InfoSection section;

  @override
  Widget build(BuildContext context) {
    final s = section;
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: s.text == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (s.icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: V6Colors.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Icon(s.icon, size: 20, color: V6Colors.primary),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.text == null)
                  Text(s.title, style: V6Text.titleMediumBold)
                else
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${s.title}: ',
                          style: V6Text.bodyMediumSemiBold.copyWith(color: V6Colors.textPrimary),
                        ),
                        TextSpan(text: s.text),
                      ],
                    ),
                    style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
                  ),
              ],
            ),
          ),
          if (s.onTap != null) const Icon(Icons.chevron_right_rounded, color: V6Colors.textMuted),
        ],
      ),
    );
    return s.onTap == null ? row : InkWell(onTap: s.onTap, child: row);
  }
}
