import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';
import '../../learning/theme/v6_text.dart';
import 'v6_button.dart';

/// Shared pieces of Translate, Voice and Camera (Figma 03–05).

/// Figma "Language Switch / Card" (448:1728): 64 high, the source language
/// on violet, the target on lavender, a 48 citrus swap button in the middle.
class LanguageSwitchCard extends StatelessWidget {
  const LanguageSwitchCard({super.key, required this.from, required this.to, required this.onSwap, this.swapTurns});

  final String from;
  final String to;
  final VoidCallback? onSwap;

  /// Optional rotation for the swap icon (an animation, in turns).
  final Animation<double>? swapTurns;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final label = V6Text.labelLanguage;
    final icon = Icon(Icons.swap_horiz_rounded, size: 24, color: V6Colors.onCitrus);
    return Semantics(
      label: t.trFromTo(from, to),
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: V6Colors.primaryContainer, borderRadius: BorderRadius.circular(16)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(color: V6Colors.primary, borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(from, style: label.copyWith(color: V6Colors.onPrimary)),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(to, style: label.copyWith(color: V6Colors.primary)),
                  ),
                ),
              ],
            ),
            Material(
              color: V6Colors.citrus,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onSwap,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Tooltip(
                    message: t.trSwap,
                    child: swapTurns == null ? icon : RotationTransition(turns: swapTurns!, child: icon),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A 48 tonal icon button (Primary Container circle, violet icon).
class TonalIconButton extends StatelessWidget {
  const TonalIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(backgroundColor: V6Colors.primaryContainer, foregroundColor: V6Colors.primary),
        icon: Icon(icon, size: 24),
      ),
    );
  }
}

/// Figma "Translation Input / With actions" (448:1738): Surface card
/// (1 px Border/Input, 2 px Border/Focus when filled), the source language,
/// a Surface Tint text area (Body/Input 20/28), "N characters", then the
/// Speak and Scan buttons and Translate.
class TranslationInputCard extends StatelessWidget {
  const TranslationInputCard({
    super.key,
    required this.language,
    required this.textArea,
    required this.characters,
    required this.filled,
    required this.onSpeak,
    required this.onScan,
    required this.onTranslate,
    this.translating = false,
    this.onClear,
  });

  /// Clears the text; the clear button shows only while [filled].
  final VoidCallback? onClear;

  /// Figma "Translating": the button shows a spinner and "Translating…".
  final bool translating;

  final String language;

  /// The text field (or read-only text) inside the tinted area.
  final Widget textArea;
  final int characters;
  final bool filled;
  final VoidCallback? onSpeak;
  final VoidCallback? onScan;
  final VoidCallback? onTranslate;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: filled ? V6Colors.borderFocus : V6Colors.borderInput, width: filled ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(language, style: V6Text.labelLarge.copyWith(color: V6Colors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(color: V6Colors.surfaceTint, borderRadius: BorderRadius.circular(12)),
            child: Stack(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(12, 12, filled && onClear != null ? 44 : 12, 12), child: textArea),
                if (filled && onClear != null)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      tooltip: t.trClearText,
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 22, color: V6Colors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.trCharacters(characters),
            textAlign: TextAlign.right,
            style: V6Text.caption.copyWith(color: V6Colors.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TonalIconButton(icon: Icons.mic_rounded, tooltip: t.trSpeak, onPressed: onSpeak),
              const SizedBox(width: 8),
              TonalIconButton(icon: Icons.photo_camera_rounded, tooltip: t.trScanPhoto, onPressed: onScan),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: translating ? () {} : onTranslate,
                      style: FilledButton.styleFrom(
                        backgroundColor: V6Colors.primary,
                        foregroundColor: V6Colors.onPrimary,
                        disabledBackgroundColor: V6Colors.stateDisabled,
                        disabledForegroundColor: V6Colors.textDisabled,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        textStyle: V6Text.button,
                        shape: const StadiumBorder(),
                      ),
                      child: translating
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.2, color: V6Colors.onPrimary),
                                ),
                                const SizedBox(width: 8),
                                Flexible(child: Text(t.trTranslating, maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            )
                          : Text(t.trTranslateButton),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The text style inside the input's tinted area (V6/Body/Input).
TextStyle get translationInputStyle => V6Text.bodyInput.copyWith(color: V6Colors.textPrimary);

/// The Listen button's look while the voice is idle, preparing or speaking.
enum ListenState { idle, preparing, speaking }

/// Figma "Result card": Glow Container Soft with a Glow border, the target
/// language, the translation (Headline/Medium, at least 72 high, or two
/// skeleton lines while translating), an optional note, then Listen (48
/// violet circle), Copy (a check for 1.5 s after copying), Share and Save
/// (Figma 628:6382: a tonal circle with a filled bookmark when saved).
class TranslationResultCard extends StatelessWidget {
  const TranslationResultCard({
    super.key,
    required this.language,
    required this.text,
    required this.translating,
    required this.onListen,
    required this.onCopy,
    this.listen = ListenState.idle,
    this.copied = false,
    this.note,
    this.onShare,
    this.onSave,
    this.saved = false,
  });

  /// Share and Save show only when given; both wait until the translation
  /// is finished.
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final bool saved;

  final String language;
  final String text;
  final bool translating;
  final VoidCallback? onListen;
  final VoidCallback? onCopy;
  final ListenState listen;
  final bool copied;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final showSkeleton = translating && text.isEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: V6Colors.glowContainerSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V6Colors.glow),
        boxShadow: const [
          BoxShadow(color: Color(0x0F321B58), blurRadius: 6, offset: Offset(0, 2)),
          BoxShadow(color: Color(0x0F321B58), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(language, style: V6Text.labelLarge.copyWith(color: V6Colors.glowText)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: showSkeleton
                ? Semantics(
                    label: t.trTranslatingShort,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6),
                        _SkeletonLine(width: 220),
                        SizedBox(height: 10),
                        _SkeletonLine(width: 150),
                      ],
                    ),
                  )
                : SelectableText(text, style: V6Text.headlineMedium),
          ),
          if (note != null && !showSkeleton) ...[
            const SizedBox(height: 4),
            Text(note!, style: V6Text.caption.copyWith(color: V6Colors.textMuted)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (onListen != null)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    tooltip: switch (listen) {
                      ListenState.idle => t.commonListen,
                      ListenState.preparing => t.trPreparingVoice,
                      ListenState.speaking => t.commonStop,
                    },
                    onPressed: showSkeleton ? null : onListen,
                    style: IconButton.styleFrom(
                      backgroundColor: V6Colors.primary,
                      foregroundColor: V6Colors.onPrimary,
                      disabledBackgroundColor: V6Colors.stateDisabled,
                    ),
                    icon: Icon(switch (listen) {
                      ListenState.idle => Icons.volume_up_rounded,
                      ListenState.preparing => Icons.hourglass_top_rounded,
                      ListenState.speaking => Icons.stop_rounded,
                    }),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: copied ? t.trCopied : t.trCopy,
                  onPressed: showSkeleton ? null : onCopy,
                  icon: Icon(
                    copied ? Icons.check_rounded : Icons.content_copy_rounded,
                    color: copied ? V6Colors.success : V6Colors.primary,
                  ),
                ),
              ),
              if (onShare != null)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    tooltip: t.trShare,
                    onPressed: translating ? null : onShare,
                    icon: const Icon(Icons.ios_share_rounded, color: V6Colors.primary),
                  ),
                ),
              if (onSave != null)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    tooltip: saved ? t.commonSaved : t.commonSave,
                    onPressed: translating ? null : onSave,
                    style: IconButton.styleFrom(
                      backgroundColor: saved ? V6Colors.primaryContainer : Colors.transparent,
                    ),
                    icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: V6Colors.primary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 22,
      decoration: BoxDecoration(color: V6Colors.glowTonal, borderRadius: BorderRadius.circular(8)),
    );
  }
}

/// "From your voice / photo · check for mistakes" with an action
/// (Speak again / Scan again): Primary Container, radius 16, 48 high.
class FromSourceRow extends StatelessWidget {
  const FromSourceRow({
    super.key,
    required this.leading,
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  final Widget leading;
  final String text;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      decoration: BoxDecoration(color: V6Colors.primaryContainer, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          SizedBox(width: 36, height: 36, child: leading),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: V6Text.labelMedium.copyWith(color: V6Colors.textPrimary)),
          ),
          V6Button(label: actionLabel, style: V6ButtonStyle.text, onPressed: onAction),
        ],
      ),
    );
  }
}

/// The round icon tile used by [FromSourceRow] (white circle, violet icon).
class SourceIconTile extends StatelessWidget {
  const SourceIconTile({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: V6Colors.surface, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: V6Colors.primary),
    );
  }
}
