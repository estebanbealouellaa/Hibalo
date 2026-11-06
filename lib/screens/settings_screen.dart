import 'dart:async';

import 'package:flutter/material.dart';

import '../services/translation_store.dart';
import '../widgets/v6/v6.dart';
import 'about_screens.dart';
import 'translate/clear_dialogs.dart';

/// Me › Settings (Figma 611:5521): Data (Clear translation history 619:5983,
/// snackbar 619:6183; Clear saved words 619:6084, snackbar 629:6361) and
/// About (Privacy policy, Credits & licences). The App version row is hidden
/// for now (no version source in the app yet).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, TranslationStore? store}) : _store = store;

  final TranslationStore? _store;

  TranslationStore get store => _store ?? TranslationStore.instance;

  Future<void> _clearHistory(BuildContext context) async {
    if (!await confirmClearHistory(context)) return;
    unawaited(store.clearHistory());
    if (context.mounted) showV6Snackbar(context, 'Translation history cleared');
  }

  Future<void> _clearSaved(BuildContext context) async {
    if (!await confirmClearSaved(context)) return;
    unawaited(store.clearSaved());
    if (context.mounted) showV6Snackbar(context, 'Saved words cleared');
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
            V6TopAppBar(title: 'Settings', onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text('Data', style: V6Text.titleMediumBold),
                  const SizedBox(height: 12),
                  V6ListCard(
                    children: [
                      V6ListRow(
                        icon: Icons.history_rounded,
                        title: 'Clear translation history',
                        onTap: () => _clearHistory(context),
                      ),
                      V6ListRow(
                        icon: Icons.bookmark_border_rounded,
                        title: 'Clear saved words',
                        onTap: () => _clearSaved(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('About', style: V6Text.titleMediumBold),
                  const SizedBox(height: 12),
                  V6ListCard(
                    children: [
                      V6ListRow(
                        icon: Icons.shield_rounded,
                        title: 'Privacy policy',
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                      ),
                      V6ListRow(
                        icon: Icons.info_rounded,
                        title: 'Credits & licences',
                        subtitle: 'Voice, data, icons and fonts',
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreditsScreen())),
                      ),
                    ],
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
