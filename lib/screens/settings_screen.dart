import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import '../services/translation_store.dart';
import '../widgets/v6/v6.dart';
import 'about_screens.dart';
import 'translate/clear_dialogs.dart';

/// Me › Settings (Figma 611:5521): Data and About.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, TranslationStore? store}) : _store = store;

  final TranslationStore? _store;

  TranslationStore get store => _store ?? TranslationStore.instance;

  Future<void> _clearHistory(BuildContext context) async {
    if (!await confirmClearHistory(context)) return;
    unawaited(store.clearHistory());
    if (context.mounted) showV6Snackbar(context, AppLocalizations.of(context).histCleared);
  }

  Future<void> _clearSaved(BuildContext context) async {
    if (!await confirmClearSaved(context)) return;
    unawaited(store.clearSaved());
    if (context.mounted) showV6Snackbar(context, AppLocalizations.of(context).savedCleared);
  }

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: V6Colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            V6TopAppBar(title: t.settingsTitle, onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(t.settingsData, style: V6Text.titleMediumBold),
                  const SizedBox(height: 12),
                  V6ListCard(
                    children: [
                      V6ListRow(
                        icon: Icons.history_rounded,
                        title: t.settingsClearHistory,
                        onTap: () => _clearHistory(context),
                      ),
                      V6ListRow(
                        icon: Icons.bookmark_border_rounded,
                        title: t.clearSavedAction,
                        onTap: () => _clearSaved(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(t.settingsAbout, style: V6Text.titleMediumBold),
                  const SizedBox(height: 12),
                  V6ListCard(
                    children: [
                      V6ListRow(
                        icon: Icons.shield_rounded,
                        title: t.settingsPrivacy,
                        onTap: () => _open(context, const PrivacyPolicyScreen()),
                      ),
                      V6ListRow(
                        icon: Icons.info_rounded,
                        title: t.settingsCredits,
                        subtitle: t.settingsCreditsSub,
                        onTap: () => _open(context, const CreditsScreen()),
                      ),
                      const _AppVersionRow(),
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

/// "App version · Hibalo 1.0.0" (from the installed app, package_info_plus).
class _AppVersionRow extends StatelessWidget {
  const _AppVersionRow();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(t.settingsAppVersion, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => Text(
              snap.hasData ? t.settingsVersionValue(snap.data!.version) : '',
              style: V6Text.labelLargeBold.copyWith(color: V6Colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
