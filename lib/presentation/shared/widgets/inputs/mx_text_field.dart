import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// Shared multiline text field primitive used by feature forms.
///
/// The feature layer must not use raw `TextField` / `TextFormField` directly.
/// This wrapper centralizes the MemoX field chrome while keeping the input
/// semantics flexible enough for form screens.
class MxTextField extends StatelessWidget {
  const MxTextField({
    required this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.hintText,
    this.trailingIcon,
    this.autofocus = false,
    this.prominent = false,
    this.minLines = 1,
    this.maxLines,
    this.textInputAction = TextInputAction.newline,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final IconData? trailingIcon;
  final bool autofocus;
  final bool prominent;
  final int minLines;
  final int? maxLines;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final TextStyle? textStyle = prominent
        ? context.textTheme.bodyLarge
        : context.textTheme.bodyMedium;
    final Color fill = prominent
        ? scheme.surfaceContainerLowest
        : scheme.surfaceContainerLowest;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
      onChanged: onChanged,
      style: textStyle,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: textStyle?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: OpacityTokens.hint),
        ),
        filled: true,
        fillColor: fill,
        suffixIcon: trailingIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: SpacingTokens.md),
                child: Icon(
                  trailingIcon,
                  size: SizeTokens.iconMd,
                  color: scheme.onSurfaceVariant,
                ),
              ),
        suffixIconConstraints: trailingIcon == null
            ? null
            : const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: const EdgeInsets.all(SpacingTokens.md),
        border: OutlineInputBorder(
          borderRadius: RadiusTokens.brLg,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.brLg,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.brLg,
          borderSide: BorderSide(color: scheme.primary, width: BorderTokens.focusWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.brLg,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.brLg,
          borderSide: BorderSide(color: scheme.error, width: BorderTokens.focusWidth),
        ),
      ),
    );
  }
}
