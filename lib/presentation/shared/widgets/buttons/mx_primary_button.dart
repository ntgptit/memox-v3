import 'package:flutter/material.dart';

import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';

/// Primary CTA primitive — `FilledButton` at a chosen [MxButtonSize].
///
/// Low-level: prefer the semantic `MxActionButton` (intent-driven) in feature
/// code. `stretchOnCompact` defaults to `false` per
/// `docs/ui-ux/action-hierarchy-contract.md` — a button is full-width only when
/// [fullWidth] is set explicitly.
///
/// Purpose:
/// Provides a reusable MemoX button widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared button surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - label: public content.
/// - onPressed: callback.
/// - icon: public content.
/// - size: public configuration.
/// - fullWidth: public property.
/// - stretchOnCompact: public property.
/// Category:
/// button
class MxPrimaryButton extends StatelessWidget {
  const MxPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = MxButtonSize.medium,
    this.fullWidth = false,
    this.stretchOnCompact = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final MxButtonSize size;
  final bool fullWidth;
  final bool stretchOnCompact;

  @override
  Widget build(BuildContext context) {
    final bool expand =
        fullWidth || (stretchOnCompact && size == MxButtonSize.compact);
    final ButtonStyle style = FilledButton.styleFrom(
      minimumSize: Size(0, size.height),
      tapTargetSize: MaterialTapTargetSize.padded,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
    );
    final Widget child = icon == null
        ? FilledButton(onPressed: onPressed, style: style, child: Text(label))
        : FilledButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: SizeTokens.iconSm),
            label: Text(label),
          );
    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}
