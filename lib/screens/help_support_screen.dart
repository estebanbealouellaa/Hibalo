import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/v6/v6.dart';

/// The support address (unchanged from before; Figma shows
/// hibalo.app@gmail.com, to be confirmed by Lance).
const String kSupportEmail = 'hibalo@gmail.com';

/// Figma 612:6044 questions. The first answer is Figma's; the others are
/// written from how the app works (Figma has no answer text for them).
const List<(String, String)> kFaqs = [
  (
    'How do I translate a photo?',
    'On Translate, tap the camera button, then take a photo or choose one from your gallery. '
        'Check the text Hibalo reads, then tap Translate.',
  ),
  (
    'Does Hibalo work without internet?',
    'Yes, after you sign in once. Translating, reading photos, the Hiligaynon voice and the lessons work offline. '
        'Your progress is saved to your account when you are back online. Speaking to translate uses your '
        "phone's speech service, which may need internet.",
  ),
  (
    'What if a translation looks wrong?',
    'Translations are made on your phone and may not be exact. Try a shorter sentence or check the spelling. '
        'For voice and photos, fix the text in the box, then tap Translate.',
  ),
  (
    'How do I unlock the next lesson?',
    "Pass the lesson's quiz with at least 80%. Lesson 2 unlocks when you finish Lesson 1.",
  ),
  (
    'How do I earn XP?',
    'Finish a lesson (20 XP), answer a quick check right (5 XP) or answer a quiz question right (10 XP). '
        'Each one gives XP only the first time.',
  ),
  ('How do I change my avatar?', 'Go to Me, tap Edit profile, choose an avatar, then tap Save changes.'),
];

/// Help & Support (Figma 612:6044): the FAQ (one answer open at a time) and
/// "Still need help?" which opens the email app.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  /// The open question (the first, as in Figma), or null.
  int? _open = 0;

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: kSupportEmail,
      queryParameters: {'subject': 'Hibalo App - Support Request'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      showV6Snackbar(context, "Couldn't open the email app.", icon: Icons.error_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V6Colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            V6TopAppBar(title: 'Help & Support', onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text('Frequently asked questions', style: V6Text.titleMediumBold),
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
                        for (final (i, (q, a)) in kFaqs.indexed) ...[
                          if (i > 0) const Divider(height: 1, thickness: 1, color: V6Colors.borderDivider),
                          _FaqItem(
                            question: q,
                            answer: a,
                            open: _open == i,
                            onTap: () => setState(() => _open = _open == i ? null : i),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: V6Colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _sendEmail,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: V6Colors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.mail_rounded, size: 20, color: V6Colors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Still need help?', style: V6Text.titleMediumBold),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Email us at $kSupportEmail',
                                    style: V6Text.bodyMedium.copyWith(color: V6Colors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: V6Colors.textPrimary),
                          ],
                        ),
                      ),
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

/// One FAQ row: the question with expand_more / expand_less; the open one
/// has a Primary Container tint and shows the answer.
class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer, required this.open, required this.onTap});

  final String question;
  final String answer;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: open ? V6Colors.primaryContainer.withValues(alpha: 0.6) : V6Colors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                button: true,
                expanded: open,
                child: Row(
                  children: [
                    Expanded(child: Text(question, style: V6Text.titleMediumBold)),
                    const SizedBox(width: 8),
                    Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: V6Colors.primary),
                  ],
                ),
              ),
              if (open) ...[
                const SizedBox(height: 8),
                Text(answer, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
