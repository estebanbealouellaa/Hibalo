import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../widgets/v6/v6.dart';

/// The support address (Lance, Nov 6).
const String kSupportEmail = 'hibalo@gmail.com';

/// Figma 612:6044 questions. The first answer is Figma's; the others are
/// written from how the app works (Figma has no answer text for them).
List<(String, String)> faqs(AppLocalizations t) => [
  (t.helpQ1, t.helpA1),
  (t.helpQ2, t.helpA2),
  (t.helpQ3, t.helpA3),
  (t.helpQ4, t.helpA4),
  (t.helpQ5, t.helpA5),
  (t.helpQ6, t.helpA6),
];

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
      showV6Snackbar(context, AppLocalizations.of(context).helpCantOpenEmail, icon: Icons.error_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final kFaqs = faqs(t);
    return Scaffold(
      backgroundColor: V6Colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            V6TopAppBar(title: t.helpTitle, onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(t.helpFaqTitle, style: V6Text.titleMediumBold),
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
                                  Text(t.helpStillNeed, style: V6Text.titleMediumBold),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.helpEmailUs(kSupportEmail),
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
