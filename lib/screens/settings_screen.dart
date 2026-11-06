import 'dart:async';

import 'package:flutter/material.dart';

import '../services/translation_store.dart';
import '../widgets/v6/v6.dart';
import 'translate/clear_dialogs.dart';

/// Me › Settings (Figma 06 · Me). For now only the Data rows: Clear
/// translation history (619:5983, snackbar 619:6183) and Clear saved words
/// (619:6084, snackbar 629:6361). About (Privacy policy, Credits, version)
/// comes in Stage D.
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
