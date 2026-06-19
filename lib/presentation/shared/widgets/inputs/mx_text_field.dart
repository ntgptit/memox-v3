import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';

/// The base MemoX text input: a themed, filled, rounded field.
///
/// Purpose:
/// One styled text-entry primitive so every input shares the same fill, radius,
/// border, and focus treatment instead of raw `TextField`s with ad-hoc
/// `InputDecoration`.
///
/// Use when:
/// Collecting single- or multi-line free text (names, fronts/backs, notes).
///
/// Do not use when:
/// Searching a list (use the dedicated search field) or choosing from options
/// (use a select/segmented control).
///
/// Category:
/// input
///
/// Public API:
/// - controller: optional external text controller.
/// - hintText / labelText: optional placeholder / floating label
///   (already-localized).
/// - prefixIcon / suffixIcon: optional leading / trailing widgets.
/// - onChanged / onSubmitted: text callbacks.
/// - keyboardType / textInputAction / inputFormatters: input behavior.
/// - obscureText / maxLines / autofocus / enabled: field modes.
class MxTextField extends StatelessWidget {
  const MxTextField({
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.autofocus = false,
    this.enabled = true,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int maxLines;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    final OutlineInputBorder base = OutlineInputBorder(
      borderRadius: MxRadius.mdAll,
      borderSide: BorderSide(color: colors.border),
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      autofocus: autofocus,
      enabled: enabled,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.surfaceMuted,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: colors.textTertiary,
        ),
        enabledBorder: base,
        border: base,
        focusedBorder: base.copyWith(
          borderSide: BorderSide(color: colors.accent),
        ),
      ),
    );
  }
}
