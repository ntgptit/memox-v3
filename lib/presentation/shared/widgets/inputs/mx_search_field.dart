import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

/// Rounded search field — leading search glyph + trailing clear
/// (`docs/system-design/MemoX Design System/ui_kits/mobile/index.html`
/// §SearchField).
///
/// Feature code must not use raw `TextField` / `SearchBar`
/// (`memox.feature_raw_flutter_widget_usage`); compose this. The clear button
/// appears only when [controller] has text.
///
/// Purpose:
/// Provides a reusable MemoX input widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared input surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - controller: public property.
/// - hintText: public content.
/// - emptyTrailing: public property.
/// - onChanged: callback.
/// - onClear: callback.
/// - clearTooltip: public property.
/// - autofocus: public property.
/// Category:
/// input
class MxSearchField extends StatelessWidget {
  const MxSearchField({
    required this.controller,
    required this.hintText,
    this.emptyTrailing,
    this.onChanged,
    this.onClear,
    this.clearTooltip,
    this.autofocus = false,
    super.key,
  });

  static const double _fieldHeight = 52;
  static const double _fieldHorizontalPadding = 14;
  static const double _leadingIconGap = 10;

  final TextEditingController controller;
  final String hintText;
  final Widget? emptyTrailing;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String? clearTooltip;

  /// Requests focus on first build (e.g. a dedicated search screen the user
  /// opened specifically to type). Defaults to `false` for inline fields.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        final bool hasText = value.text.isNotEmpty;
        return SizedBox(
          height: _fieldHeight,
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            textAlignVertical: TextAlignVertical.center,
            style: context.textTheme.bodyMedium,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: scheme.surfaceContainer,
              hintText: hintText,
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant.withValues(
                  alpha: OpacityTokens.hint,
                ),
              ),
              contentPadding: const EdgeInsetsDirectional.only(
                start: 0,
                end: _fieldHorizontalPadding,
              ),
              prefixIconConstraints: const BoxConstraints.tightFor(
                width: SizeTokens.buttonSm,
                height: _fieldHeight,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 14,
                  end: _leadingIconGap,
                ),
                child: Icon(
                  Icons.search,
                  size: SizeTokens.iconMinor,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              suffixIconConstraints: const BoxConstraints.tightFor(
                width: _fieldHeight,
                height: _fieldHeight,
              ),
              suffixIcon: hasText
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: SizeTokens.iconXs,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: _fieldHeight,
                        height: _fieldHeight,
                      ),
                      tooltip: clearTooltip,
                      onPressed: () {
                        controller.clear();
                        onChanged?.call('');
                        onClear?.call();
                      },
                    )
                  : emptyTrailing,
              border: const OutlineInputBorder(
                borderRadius: RadiusTokens.brMd,
                borderSide: BorderSide.none,
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: RadiusTokens.brMd,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: RadiusTokens.brMd,
                borderSide: BorderSide(color: scheme.primary),
              ),
            ),
          ),
        );
      },
    );
  }
}
