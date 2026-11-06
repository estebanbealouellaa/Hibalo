import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/translation/hil_numbers.dart';
import '../../services/translation_store.dart';
import '../../services/tts/translation_speaker.dart';
import '../../widgets/filipino_voice_dialog.dart';
import '../../widgets/v6/v6.dart';
import 'clear_dialogs.dart';

/// Translate › History (Figma 623:6168, empty 623:6328) and Saved (628:6142,
/// empty 628:6322), opened from the History icon on Translate. Tapping an
/// item closes this screen with that entry, so Translate can show it again.
class TranslateHistoryScreen extends StatefulWidget {
  const TranslateHistoryScreen({super.key, this.showSaved = false, TranslationStore? store}) : _store = store;

  /// Open on the Saved tab.
  final bool showSaved;
  final TranslationStore? _store;

  @override
  State<TranslateHistoryScreen> createState() => _TranslateHistoryScreenState();
}

class _TranslateHistoryScreenState extends State<TranslateHistoryScreen> {
  late bool _saved = widget.showSaved;
  late final TranslationStore _store = widget._store ?? TranslationStore.instance;
  final TranslationSpeaker _speaker = TranslationSpeaker();

  /// The saved entry whose Listen is playing.
  String? _playing;

  @override
  void initState() {
    super.initState();
    _store.load();
    _speaker.status.addListener(_onSpeak);
    _speaker.onFilipinoVoiceMissing = () {
      if (mounted) showFilipinoVoiceHelp(context);
    };
    _speaker.onFilipinoVoiceNotReady = () {
      if (mounted) showFilipinoVoiceNotReady(context);
    };
  }

  @override
  void dispose() {
    _speaker.dispose();
    super.dispose();
  }

  void _onSpeak() {
    if (!mounted) return;
    setState(() {
      if (_speaker.status.value == SpeakStatus.idle) _playing = null;
    });
  }

  /// Saved › Listen: the Hiligaynon voice for Hiligaynon, the phone's
  /// Filipino voice for Filipino (as on Translate).
  void _listen(TranslationEntry e) {
    final hiligaynon = !e.fromHiligaynon;
    setState(() => _playing = e.key);
    _speaker.toggle(hiligaynon ? numbersToWords(e.translation) : e.translation, hiligaynon: hiligaynon);
  }

  void _open(TranslationEntry e) => Navigator.of(context).pop(e);

  Future<void> _clearAll() async {
    if (await confirmClearHistory(context)) {
      unawaited(_store.clearHistory());
      if (mounted) showV6Snackbar(context, 'Translation history cleared');
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
            V6TopAppBar(title: 'History', onBack: () => Navigator.of(context).pop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _Tabs(saved: _saved, onChanged: (saved) => setState(() => _saved = saved)),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _store,
                builder: (context, _) => _saved ? _savedList() : _historyList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyList() {
    final items = _store.history;
    if (items.isEmpty) {
      return _Empty(
        title: 'No translations yet',
        message: 'Words and phrases you translate will show up here, so you can open them again.',
        onStart: () => Navigator.of(context).pop(),
      );
    }
    final groups = <String, List<TranslationEntry>>{};
    for (final e in items) {
      groups.putIfAbsent(dayLabel(e.time, DateTime.now()), () => []).add(e);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tap a translation to open it again.',
                style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
              ),
            ),
            V6Button(label: 'Clear all', style: V6ButtonStyle.text, onPressed: _clearAll),
          ],
        ),
        for (final MapEntry(key: day, value: entries) in groups.entries) ...[
          const SizedBox(height: 12),
          Text(day, style: V6Text.titleMediumBold),
          const SizedBox(height: 12),
          _Card(
            children: [
              for (final e in entries)
                _HistoryRow(
                  entry: e,
                  saved: _store.isSaved(e),
                  onTap: () => _open(e),
                  onSave: () => _store.toggleSaved(e),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _savedList() {
    final items = _store.saved;
    if (items.isEmpty) {
      return _Empty(
        title: 'No saved words yet',
        message: 'Tap the bookmark on a translation to keep it here for practice.',
        onStart: () => Navigator.of(context).pop(),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          items.length == 1 ? '1 saved word or phrase' : '${items.length} saved words and phrases',
          style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
        ),
        const SizedBox(height: 12),
        _Card(
          children: [
            for (final e in items)
              _SavedRow(
                entry: e,
                speaking: _playing == e.key && _speaker.status.value != SpeakStatus.idle,
                onTap: () => _open(e),
                onListen: () => _listen(e),
                onRemove: () => _store.toggleSaved(e),
              ),
          ],
        ),
      ],
    );
  }
}

/// "Today", "Yesterday", or the date (e.g. "November 4").
String dayLabel(DateTime time, DateTime now) {
  final day = DateTime(time.year, time.month, time.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat(time.year == now.year ? 'MMMM d' : 'MMMM d, y').format(time);
}

/// Figma "Tabs · History | Saved": a Primary Container pill, the active tab
/// violet.
class _Tabs extends StatelessWidget {
  const _Tabs({required this.saved, required this.onChanged});

  final bool saved;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool active, bool value) => Expanded(
      child: Semantics(
        selected: active,
        button: true,
        child: Material(
          color: active ? V6Colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onChanged(value),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              alignment: Alignment.center,
              child: Text(
                label,
                style: V6Text.labelLargeBold.copyWith(color: active ? V6Colors.onPrimary : V6Colors.onPrimaryContainer),
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: V6Colors.primaryContainer, borderRadius: BorderRadius.circular(24)),
      child: Row(children: [tab('History', !saved, false), tab('Saved', saved, true)]),
    );
  }
}

/// White card, radius 20, rows split by dividers.
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, row) in children.indexed) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: V6Colors.borderDivider),
            row,
          ],
        ],
      ),
    );
  }
}

/// The bookmark: outline, or a tonal circle with a filled bookmark when
/// saved.
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saved, required this.onPressed});

  final bool saved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: saved ? 'Remove from saved' : 'Save',
        onPressed: onPressed,
        style: IconButton.styleFrom(backgroundColor: saved ? V6Colors.primaryContainer : Colors.transparent),
        icon: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: saved ? V6Colors.primary : V6Colors.textPrimary,
        ),
      ),
    );
  }
}

/// Figma History item: input-type tile, "From → To", the text (one line),
/// the translation (bold, two lines), and the bookmark.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.saved, required this.onTap, required this.onSave});

  final TranslationEntry entry;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: V6Colors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  switch (entry.input) {
                    EntryInput.typed => Icons.translate_rounded,
                    EntryInput.voice => Icons.mic_rounded,
                    EntryInput.photo => Icons.photo_camera_rounded,
                  },
                  size: 20,
                  color: V6Colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.fromLanguage} → ${entry.toLanguage}',
                      style: V6Text.caption.copyWith(color: V6Colors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.translation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: V6Text.titleMediumBold,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _SaveButton(saved: saved, onPressed: onSave),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma Saved item: the target language, the translation (bold), the
/// original text, Listen, and the filled bookmark (tap to remove).
class _SavedRow extends StatelessWidget {
  const _SavedRow({
    required this.entry,
    required this.speaking,
    required this.onTap,
    required this.onListen,
    required this.onRemove,
  });

  final TranslationEntry entry;
  final bool speaking;
  final VoidCallback onTap;
  final VoidCallback onListen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.toLanguage, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(entry.translation, maxLines: 2, overflow: TextOverflow.ellipsis, style: V6Text.titleMediumBold),
                  const SizedBox(height: 2),
                  Text(
                    entry.source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                tooltip: speaking ? 'Stop' : 'Listen',
                onPressed: onListen,
                icon: Icon(speaking ? Icons.stop_rounded : Icons.volume_up_rounded, color: V6Colors.primary),
              ),
            ),
            const SizedBox(width: 4),
            _SaveButton(saved: true, onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}

/// Figma "History empty" / "Saved empty": mascot, title, message and
/// Start translating.
class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.message, required this.onStart});

  final String title;
  final String message;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      children: [
        const Center(child: V6MascotCircle(mascot: 'firefly_idk', size: 160, circleSize: 130)),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: V6Text.titleLargeBold),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
        ),
        const SizedBox(height: 16),
        V6Button(label: 'Start translating', expand: true, onPressed: onStart),
      ],
    );
  }
}
