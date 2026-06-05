import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';

/// Visual emphasis for a secondary action.
enum MxSecondaryVariant {
  /// `FilledButton.tonal` — sits on surface (card secondary).
  tonal,

  /// `OutlinedButton` — cancel / low-emphasis.
  outlined,

  /// `TextButton` — inline link-style / toolbar.
  text,
}

/// Secondary action primitive — tonal / outlined / text at an [MxButtonSize].
///
/// Low-level: prefer the semantic `MxActionButton` in feature code. Always
/// visually lighter than the primary per
/// `docs/ui-ux/action-hierarchy-contract.md`.
class MxSecondaryButton extends StatelessWidget {
  const MxSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = MxSecondaryVariant.tonal,
    this.size = MxButtonSize.medium,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final MxSecondaryVariant variant;
  final MxButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = _styleFor(variant);
    final Widget? leading = icon == null
        ? null
        : Icon(icon, size: SizeTokens.iconSm);
    final Widget child = switch (variant) {
      MxSecondaryVariant.tonal =>
        leading == null
            ? FilledButton.tonal(
                onPressed: onPressed,
                style: style,
                child: Text(label),
              )
            : FilledButton.tonalIcon(
                onPressed: onPressed,
                style: style,
                icon: leading,
                label: Text(label),
              ),
      MxSecondaryVariant.outlined =>
        leading == null
            ? OutlinedButton(
                onPressed: onPressed,
                style: style,
                child: Text(label),
              )
            : OutlinedButton.icon(
                onPressed: onPressed,
                style: style,
                icon: leading,
                label: Text(label),
              ),
      MxSecondaryVariant.text =>
        leading == null
            ? TextButton(onPressed: onPressed, style: style, child: Text(label))
            : TextButton.icon(
                onPressed: onPressed,
                style: style,
                icon: leading,
                label: Text(label),
              ),
    };
    return fullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }

  ButtonStyle _styleFor(MxSecondaryVariant variant) {
    final double horizontal = variant == MxSecondaryVariant.text
        ? SpacingTokens.md
        : SpacingTokens.xl;
    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(Size(0, size.height)),
      tapTargetSize: MaterialTapTargetSize.padded,
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: horizontal),
      ),
    );
  }
}
