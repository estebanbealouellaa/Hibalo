import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/app_localizations.dart';
import '../services/language_prompt.dart';
import '../widgets/v6/v6.dart';

const List<String> kLanguages = ['English', 'Filipino', 'Hiligaynon'];

/// Shows the language pop-up only right after Sign Up (see LanguagePrompt), never when an existing account signs in.
Future<void> askLanguageAfterSignUp(BuildContext context, {String? uid}) async {
  if (!LanguagePrompt.takePending(uid)) return;
  if (!context.mounted) return;
  await showLanguagePopup(context);
}

/// Figma 705:7496: mascot, "Choose your language", the three choices and
/// Continue. The choice is saved on the phone (AppLanguage).
Future<void> showLanguagePopup(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: V6Colors.primaryStrong.withValues(alpha: 0.45),
    builder: (_) => const _LanguagePopup(),
  );
}

class _LanguagePopup extends StatefulWidget {
  const _LanguagePopup();

  @override
  State<_LanguagePopup> createState() => _LanguagePopupState();
}

class _LanguagePopupState extends State<_LanguagePopup> {
  late String _picked = AppLanguage.instance.language;

  @override
  Widget build(BuildContext context) {
    final t = lookupAppLocalizations(AppLanguage.locales[_picked]!);
    return Dialog(
      backgroundColor: V6Colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: V6MascotCircle(mascot: 'firefly_hello', circleColor: V6Colors.citrus)),
            const SizedBox(height: 12),
            Text(t.langChooseTitle, textAlign: TextAlign.center, style: V6Text.titleLargeBold),
            const SizedBox(height: 16),
            for (final language in kLanguages) ...[
              LanguageOption(
                language: language,
                selected: language == _picked,
                onTap: () => setState(() => _picked = language),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            V6Button(
              label: t.langContinue,
              expand: true,
              onPressed: () async {
                await AppLanguage.instance.setLanguage(_picked);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Me › Language (Figma 703:7482): the three choices change the app right
/// away, with "Language changed to …" (706:7609, 706:7656).
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _pick(BuildContext context, String language) async {
    if (language == AppLanguage.instance.language) return;
    await AppLanguage.instance.setLanguage(language);
    if (!context.mounted) return;
    final t = lookupAppLocalizations(AppLanguage.locales[language]!);
    showV6Snackbar(context, t.langChangedTo(language));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: AppLanguage.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: V6Colors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              V6TopAppBar(title: t.langTitle, onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Text(t.langAppLanguage, style: V6Text.titleMediumBold),
                    const SizedBox(height: 12),
                    for (final language in kLanguages) ...[
                      LanguageOption(
                        language: language,
                        selected: language == AppLanguage.instance.language,
                        onTap: () => _pick(context, language),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    Text(t.langNote, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One language choice: a radio dot and the name; selected = Primary
/// Container with a 2 px violet border.
class LanguageOption extends StatelessWidget {
  const LanguageOption({super.key, required this.language, required this.selected, required this.onTap});

  final String language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? V6Colors.primaryContainer : V6Colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? V6Colors.primary : V6Colors.borderDivider,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: V6Colors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    language,
                    style: (selected ? V6Text.titleMediumBold : V6Text.bodyLarge).copyWith(color: V6Colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
