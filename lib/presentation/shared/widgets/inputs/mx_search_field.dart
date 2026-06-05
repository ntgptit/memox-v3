import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// Pill search field — leading search glyph + trailing clear
/// (`docs/system-design/MemoX Design System/ui_kits/mobile/index.html`
/// §SearchField).
///
/// Feature code must not use raw `TextField` / `SearchBar`
/// (`memox.feature_raw_flutter_widget_usage`); compose this. The clear button
/// appears only when [controller] has text.
class MxSearchField extends StatelessWidget {
  const MxSearchField({
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.clearTooltip,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String? clearTooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        final bool hasText = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
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
            constraints: const BoxConstraints(minHeight: SizeTokens.button),
            contentPadding: const EdgeInsets.symmetric(
              vertical: SpacingTokens.md,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: SizeTokens.iconSm,
              color: scheme.onSurfaceVariant,
            ),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: SizeTokens.iconSm,
                    tooltip: clearTooltip,
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                      onClear?.call();
                    },
                  )
                : null,
            border: const OutlineInputBorder(
              borderRadius: RadiusTokens.brFull,
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: RadiusTokens.brFull,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: RadiusTokens.brFull,
              borderSide: BorderSide(color: scheme.primary),
            ),
          ),
        );
      },
    );
  }
}
