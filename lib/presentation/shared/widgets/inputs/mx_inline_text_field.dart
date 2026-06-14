import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';

/// Borderless single-line text field used for inline study surfaces.
///
/// Purpose:
/// Provides a reusable MemoX input widget for card-centered typing surfaces
/// that need live editing without field chrome.
///
/// Use when:
/// A screen needs a plain inline typing surface instead of a one-off raw
/// `TextField`.
///
/// Do not use when:
/// The input needs full form chrome, multiline wrapping, or a different
/// interaction pattern.
///
/// Public API:
/// - controller: public property.
/// - focusNode: public property.
/// - onChanged: callback.
/// - hintText: public content.
/// - autofocus: public property.
/// - textAlign: public property.
/// - textInputAction: public property.
/// Category:
/// input
class MxInlineTextField extends StatelessWidget {
  const MxInlineTextField({
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.hintText,
    this.autofocus = false,
    this.textAlign = TextAlign.center,
    this.textInputAction = TextInputAction.done,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final bool autofocus;
  final TextAlign textAlign;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle =
        context.textTheme.displayLarge ?? const TextStyle();
    final TextStyle hintStyle = baseStyle.copyWith(
      color: context.colorScheme.onSurfaceVariant.withValues(
        alpha: OpacityTokens.hint,
      ),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      textAlign: textAlign,
      textAlignVertical: TextAlignVertical.center,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.text,
      textInputAction: textInputAction,
      style: baseStyle,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: const OutlineInputBorder(
          borderRadius: RadiusTokens.brLg,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: RadiusTokens.brLg,
          borderSide: BorderSide.none,
        ),
        isDense: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        hintStyle: hintStyle,
      ),
    );
  }
}
