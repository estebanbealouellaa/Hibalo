import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/translator_provider.dart';
import '../services/tts/translation_speaker.dart';
import '../models/translator_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/user_stats.dart';
import '../widgets/lessons/lessons_header.dart';

class _CommonPhrase {
  final String category;
  final String emoji;
  final String hil;
  final String fil;

  const _CommonPhrase(this.category, this.emoji, this.hil, this.fil);
}

const _commonPhrases = [
  _CommonPhrase('Greeting', '👋', 'Maayong aga', 'Magandang umaga'),
  _CommonPhrase('Ask', '💬', 'Kamusta ka?', 'Kumusta ka?'),
  _CommonPhrase('Thanks', '🙏', 'Salamat gid', 'Maraming salamat'),
  _CommonPhrase('Polite', '🤲', 'Palihog', 'Pakiusap'),
  _CommonPhrase('Where', '📍', 'Diin ka na?', 'Nasaan ka na?'),
  _CommonPhrase('Farewell', '👋', 'Palaabuton', 'Paalam'),
];

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focus = FocusNode();
  final TranslationSpeaker _speaker = TranslationSpeaker();
  TranslatorProvider? _translator;

  late final AnimationController _swap;

  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _speaker.status.addListener(_onSpeakStatus);
    TranslationSpeaker.warmUp();
    _translator = context.read<TranslatorProvider>()
      ..addListener(_prepareVoice);
    _prepareVoice();

    _swap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _inputController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focus.dispose();
    _swap.dispose();
    _translator?.removeListener(_prepareVoice);
    _speaker.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────
  void _translate() {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    context.read<TranslatorProvider>().updateOriginalText(
      _inputController.text,
    );
  }

  void _applyPhrase(_CommonPhrase phrase, String sourceLanguage) {
    HapticFeedback.selectionClick();
    final text = sourceLanguage == Languages.hiligaynon
        ? phrase.hil
        : phrase.fil;
    _inputController.text = text;
    context.read<TranslatorProvider>().updateOriginalText(text);
  }

  void _clear() {
    HapticFeedback.selectionClick();
    _inputController.clear();
    context.read<TranslatorProvider>().updateOriginalText('');
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty || !mounted) return;
    HapticFeedback.selectionClick();
    _inputController.text = text;
    context.read<TranslatorProvider>().updateOriginalText(text);
  }

  void _onSpeakStatus() {
    if (mounted) setState(() {});
  }

  /// Starts making the Hiligaynon audio as soon as a translation is shown,
  /// so "Listen" can play right away.
  void _prepareVoice() {
    final s = _translator?.state;
    if (s == null || s.isTranslating || s.translatedText.isEmpty) return;
    if (s.sourceLanguage == Languages.tagalog) {
      TranslationSpeaker.prepare(s.translatedText);
    }
  }

  /// Filipino -> Hiligaynon results use the native Hiligaynon voice.
  Future<void> _speakResult(String text) {
    final source = context.read<TranslatorProvider>().state.sourceLanguage;
    return _speaker.toggle(text, hiligaynon: source == Languages.tagalog);
  }

  void _copyResult(String text) {
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  // ── UI ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslatorProvider>();
    final state = provider.state;
    final isFilToHil = state.sourceLanguage == Languages.tagalog;

    // Keep the field in step when the text changes from somewhere else
    // (a phrase chip, or the voice screen).
    if (_inputController.text != state.originalText && !_focus.hasFocus) {
      _inputController.text = state.originalText;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Consumer<UserStats>(
                    builder: (context, stats, _) => LessonsHeader(
                      title: 'Translate',
                      streak: stats.streak,
                      lessonsCompleted: stats.lessonsCompleted,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _languageCard(isFilToHil),
                const SizedBox(height: 14),
                _inputCard(isFilToHil),
                const SizedBox(height: 14),
                _resultCard(state, isFilToHil),
                const SizedBox(height: 26),
                _phrases(state, isFilToHil),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Language picker ─────────────────────────────────────────────────────
  Widget _languageCard(bool isFilToHil) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _langBox(
              isFilToHil ? 'Filipino' : 'Hiligaynon',
              'From',
              true,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _swap.forward(from: 0);
              context.read<TranslatorProvider>().swapLanguages();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [purple, purpleMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: purple.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: RotationTransition(
                turns: Tween<double>(begin: 0, end: 0.5).animate(
                  CurvedAnimation(parent: _swap, curve: Curves.easeOutBack),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ),
          Expanded(
            child: _langBox(
              isFilToHil ? 'Hiligaynon' : 'Filipino',
              'To',
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _langBox(String name, String role, bool source) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: source ? purplePale : purple.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            role.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
              color: purple.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.displaySmall.copyWith(fontSize: 16, color: ink),
          ),
        ],
      ),
    );
  }

  // ── Input ───────────────────────────────────────────────────────────────
  Widget _inputCard(bool isFilToHil) {
    final text = _inputController.text;
    final empty = text.trim().isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _focus.hasFocus ? purple.withValues(alpha: 0.5) : borderLight,
          width: _focus.hasFocus ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'YOUR TEXT',
                style: AppTheme.labelCaps.copyWith(
                  fontSize: 10,
                  color: inkMuted,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (empty)
                _miniBtn(Icons.content_paste_rounded, 'Paste', _paste)
              else
                _miniBtn(Icons.close_rounded, 'Clear', _clear),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _inputController,
            focusNode: _focus,
            maxLines: 4,
            minLines: 3,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              color: ink,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: isFilToHil ? 'Magandang umaga' : 'Maayong aga',
              hintStyle: TextStyle(
                color: inkMuted.withValues(alpha: 0.55),
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${text.characters.length} characters',
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: 11,
                  color: inkMuted,
                ),
              ),
              const Spacer(),
              _PushButton(
                onTap: empty ? null : _translate,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Translate'),
                    SizedBox(width: 7),
                    Icon(Icons.arrow_forward_rounded, size: 17),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: purplePale,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: purple),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Result ──────────────────────────────────────────────────────────────
  Widget _resultCard(TranslatorState state, bool isFilToHil) {
    final on = state.translatedText.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [purple, purpleMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                (isFilToHil ? 'HILIGAYNON' : 'FILIPINO'),
                style: AppTheme.labelCaps.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (state.isTranslating)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 84),
            child: SizedBox(
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.14),
                      end: Offset.zero,
                    ).animate(a),
                    child: c,
                  ),
                ),
                child: Text(
                  on ? state.translatedText : 'Your translation appears here',
                  key: ValueKey(state.translatedText),
                  style: on
                      ? AppTheme.displayMedium.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.4,
                        )
                      : TextStyle(
                          fontSize: 19,
                          color: Colors.white.withValues(alpha: 0.4),
                          height: 1.5,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _resultAction(
                icon: switch (_speaker.status.value) {
                  SpeakStatus.idle => Icons.volume_up_rounded,
                  SpeakStatus.preparing => Icons.hourglass_top_rounded,
                  SpeakStatus.speaking => Icons.stop_rounded,
                },
                label: switch (_speaker.status.value) {
                  SpeakStatus.idle => 'Listen',
                  SpeakStatus.preparing => 'Preparing',
                  SpeakStatus.speaking => 'Stop',
                },
                enabled: on,
                primary: true,
                onTap: () => _speakResult(state.translatedText),
              ),
              const SizedBox(width: 9),
              _resultAction(
                icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
                label: _copied ? 'Copied' : 'Copy',
                enabled: on,
                onTap: () => _copyResult(state.translatedText),
              ),
              const SizedBox(width: 9),
              _resultAction(
                icon: Icons.ios_share_rounded,
                label: 'Share',
                enabled: on,
                onTap: () => _copyResult(
                  '${state.originalText}\n→ ${state.translatedText}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    bool primary = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.4,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: primary ? 0.24 : 0.13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Common phrases ──────────────────────────────────────────────────────
  Widget _phrases(TranslatorState state, bool isFilToHil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Text(
                'Common phrases',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'tap to translate',
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: 11.5,
                  color: inkMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: _commonPhrases.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final phrase = _commonPhrases[index];
              final primary = isFilToHil ? phrase.fil : phrase.hil;
              final secondary = isFilToHil ? phrase.hil : phrase.fil;
              return _Bouncy(
                onTap: () => _applyPhrase(phrase, state.sourceLanguage),
                child: Container(
                  width: 158,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            phrase.emoji,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            phrase.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: purple,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.north_east_rounded,
                            size: 12,
                            color: purpleMid,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        primary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        secondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyMedium.copyWith(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PUSH BUTTON — presses down like a real key
// ═════════════════════════════════════════════════════════════════════════════
class _PushButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PushButton({required this.child, required this.onTap});

  @override
  State<_PushButton> createState() => _PushButtonState();
}

class _PushButtonState extends State<_PushButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    const depth = 4.0;
    final enabled = widget.onTap != null;
    final base = enabled ? purple : Colors.grey.shade300;
    final edge = HSLColor.fromColor(base)
        .withLightness(
          (HSLColor.fromColor(base).lightness - 0.14).clamp(0.0, 1.0),
        )
        .toColor();

    return GestureDetector(
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled
          ? (_) {
              _set(false);
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled ? () => _set(false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: _down ? depth : 0,
          bottom: _down ? 0 : depth,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: edge, offset: Offset(0, _down ? 0 : depth)),
          ],
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: enabled ? Colors.white : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          child: IconTheme(
            data: IconThemeData(
              color: enabled ? Colors.white : Colors.grey.shade600,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Shrinks slightly while pressed, for cards.
class _Bouncy extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Bouncy({required this.child, required this.onTap});

  @override
  State<_Bouncy> createState() => _BouncyState();
}

class _BouncyState extends State<_Bouncy> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) {
        _set(false);
        widget.onTap();
      },
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
