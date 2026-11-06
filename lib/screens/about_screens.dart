import 'package:flutter/material.dart';

import '../widgets/v6/v6.dart';

/// One section of an info card: an optional icon, a title and the text.
class InfoSection {
  const InfoSection(this.title, this.text, {this.icon, this.onTap});

  final String title;
  final String? text;
  final IconData? icon;
  final VoidCallback? onTap;
}

/// The Privacy policy text (Lance, Nov 6), shown word for word: each row is
/// "Label: text" with the label in bold.
const String kPrivacyIntro =
    'Hibalo was made by students of the Polytechnic University of the Philippines for a capstone study.';
const List<InfoSection> kPrivacySections = [
  InfoSection(
    'What we save',
    'your username, email address and chosen avatar; when you signed up and last signed in; and your learning '
        'progress (lessons finished, quiz scores, XP and streak). These are saved in Google Firebase so your '
        "progress isn't lost.",
  ),
  InfoSection(
    "What we don't save",
    'the text you translate, the pictures you scan and your voice. Your translation history and saved words are '
        'kept only on your phone; uninstalling the app or clearing them in Settings deletes them. Translation and '
        "picture reading happen on your phone. Speech-to-text uses your phone's own speech service, which may "
        "follow Google's privacy terms. Speaking practice in lessons is kept on your phone only while you use it, "
        'then deleted.',
  ),
  InfoSection(
    'Who can see your data',
    "only you and the research team (app administrators). You can't see other users' data, and they can't see "
        'yours.',
  ),
  InfoSection('How your data is used', 'only for this study. It is not sold or shared.'),
  InfoSection('Deleting your data', 'ask the research team, and they will delete your account and progress.'),
  InfoSection('Questions', 'contact the Hibalo research team.'),
];

/// Settings › Privacy policy (Figma 619:6273 layout).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPage(title: 'Privacy policy', intro: kPrivacyIntro, sections: kPrivacySections);
  }
}

/// The Credits & licences text (Lance, Nov 6), shown exactly as written.
const String kCreditsIntro = 'Made by the Hibalo team, Polytechnic University of the Philippines.';

/// Settings › Credits & licences (Figma 612:5896 layout). The last row opens
/// Flutter's licence list.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPage(
      title: 'Credits & licences',
      intro: kCreditsIntro,
      sections: [
        const InfoSection(
          'Hiligaynon voice',
          "a fine-tuned version of Meta's MMS-TTS (VITS) model, licensed CC BY-NC 4.0 (non-commercial use only).",
          icon: Icons.graphic_eq_rounded,
        ),
        const InfoSection(
          'Voice training data',
          'Philippine Languages Database (PLD), University of the Philippines Diliman Digital Signal Processing '
              'Laboratory (UP-DSP).',
          icon: Icons.dataset_rounded,
        ),
        const InfoSection(
          'Translation',
          'a MarianMT model trained by the Hibalo team, with help from the MADLAD-400 model and public Hiligaynon '
              'and Filipino texts.',
          icon: Icons.translate_rounded,
        ),
        const InfoSection(
          'Lesson content',
          'written by the Hibalo team and checked against public references, including Omniglot, Iloilo Directory, '
              'Wikipedia, the ERIC Hiligaynon language packet (ED402758) and pinoydictionary.com.',
          icon: Icons.menu_book_rounded,
        ),
        const InfoSection(
          'Text reading',
          'Google ML Kit. Font: Plus Jakarta Sans (SIL Open Font License). Icons: Material Symbols (Apache License '
              '2.0).',
          icon: Icons.star_rounded,
        ),
        InfoSection(
          'Open-source software',
          null,
          icon: Icons.code_rounded,
          onTap: () => showLicensePage(context: context, applicationName: 'Hibalo'),
        ),
      ],
    );
  }
}

/// Top app bar, an intro line, and one white card of sections.
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
