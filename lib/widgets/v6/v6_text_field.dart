import '../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';
import '../../learning/theme/v6_text.dart';
import 'v6_styles.dart';

/// Figma "Text Field" (448:1563): the label above a 52-high white field.
/// Border Border/Neutral; focus 2 px Primary; error 2 px Error with the
/// message below (16 px icon + caption). Disabled: State/Disabled fill.
/// [obscure] adds the 48 × 48 show / hide password button.
///
/// [fieldLabel] uses the auth screens' uppercase violet label (V6/Label/Field);
/// otherwise the label is Label/Large in Text/Neutral Strong.
class V6TextField extends StatefulWidget {
  const V6TextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    this.fieldLabel = false,
    this.errorText,
    this.prefixIcon,
    this.maxLength,
    this.helperText,
  });

  /// A caption under the field (hidden while there is an error).
  final String? helperText;

  /// A 24 icon at the start of the field (Text/Neutral Strong).
  final IconData? prefixIcon;

  /// Limits the length and shows "n/max" under the field (Caption).
  final int? maxLength;

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool fieldLabel;

  /// Shows the error state without a validator (e.g. "email already in use").
  final String? errorText;

  @override
  State<V6TextField> createState() => _V6TextFieldState();
}

class _V6TextFieldState extends State<V6TextField> {
  late bool _hidden = widget.obscure;

  @override
  void didUpdateWidget(V6TextField old) {
    super.didUpdateWidget(old);
    if (old.obscure != widget.obscure) _hidden = widget.obscure;
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final labelStyle = widget.fieldLabel
        ? V6AppText.labelField.copyWith(color: widget.enabled ? V6Colors.primary : V6Colors.textDisabled)
        : V6Text.labelLarge.copyWith(color: widget.enabled ? V6Colors.textNeutralStrong : V6Colors.textDisabled);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.fieldLabel ? widget.label.toUpperCase() : widget.label, style: labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          validator: widget.validator,
          maxLength: widget.maxLength,
          // The counter is drawn below, at the field's left edge (Figma).
          buildCounter: widget.maxLength == null
              ? null
              : (context, {required currentLength, required isFocused, maxLength}) => null,
          style: V6Text.bodyLarge.copyWith(
            color: widget.enabled ? V6Colors.textPrimary : V6Colors.textDisabled,
          ),
          cursorColor: V6Colors.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: V6Text.bodyLarge.copyWith(color: V6Colors.textNeutral),
            filled: true,
            fillColor: widget.enabled ? V6Colors.surface : V6Colors.stateDisabled,
            isDense: true,
            constraints: const BoxConstraints(minHeight: 52),
            contentPadding: EdgeInsets.fromLTRB(16, 14, widget.obscure ? 4 : 16, 14),
            errorText: widget.errorText,
            errorMaxLines: 2,
            // Error helper: caption in Error colour under the field.
            errorStyle: V6Text.caption.copyWith(color: V6Colors.error),
            enabledBorder: _border(V6Colors.borderNeutral, 1),
            disabledBorder: _border(V6Colors.borderNeutral, 1),
            focusedBorder: _border(V6Colors.primary, 2),
            errorBorder: _border(V6Colors.error, 2),
            focusedErrorBorder: _border(V6Colors.error, 2),
            suffixIcon: widget.obscure
                ? IconButton(
                    tooltip: _hidden ? t.commonShowPassword : t.commonHidePassword,
                    onPressed: widget.enabled ? () => setState(() => _hidden = !_hidden) : null,
                    icon: Icon(
                      _hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: widget.enabled ? V6Colors.textNeutralStrong : V6Colors.textDisabled,
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(
                    widget.prefixIcon,
                    color: widget.enabled ? V6Colors.textNeutralStrong : V6Colors.textDisabled,
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ),
        if (widget.errorText == null && (widget.maxLength != null || widget.helperText != null))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: widget.maxLength != null && widget.controller != null
                ? ListenableBuilder(
                    listenable: widget.controller!,
                    builder: (context, _) => Text(
                      '${widget.controller!.text.characters.length}/${widget.maxLength}',
                      style: V6Text.caption.copyWith(color: V6Colors.textMuted),
                    ),
                  )
                : Text(widget.helperText ?? '', style: V6Text.caption.copyWith(color: V6Colors.textMuted)),
          ),
      ],
    );
  }
}
