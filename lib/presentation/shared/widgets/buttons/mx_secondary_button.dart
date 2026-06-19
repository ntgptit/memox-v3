import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';

/// Emphasis variant for [MxSecondaryButton].
enum MxSecondaryVariant {
  /// Soft accent fill — the default lighter-than-primary action.
  tonal,

  /// Text-only — inline/toolbar low-emphasis action.
  text,

  /// Outlined — bordered low-emphasis action.
  outlined,
}

/// A lower-emphasis button that stays visually lighter than the primary.
///
/// Purpose:
/// The companion to `MxPrimaryButton` for secondary actions, so "lighter than
/// the primary" is a built-in property (tonal/text/outlined) rather than a
/// per-screen guess.
///
/// Use when:
/// Offering a secondary, inline, or toolbar action alongside (or instead of) a
/// primary.
///
/// Do not use when:
/// The action is the dominant one (use `MxPrimaryButton`) or you want
/// intent-driven density (use `MxActionButton`).
///
/// Category:
/// button
///
/// Public API:
/// - label: button text; pass already-localized copy.
/// - onPressed: tap handler; null disables the button.
/// - icon: optional leading glyph.
/// - size: density (defaults to compact).
/// - variant: emphasis style (defaults to tonal).
/// - fullWidth: stretch to the available width (defaults to false).
///
/// Variants:
/// - variant: [MxSecondaryVariant.tonal] / [MxSecondaryVariant.text] /
///   [MxSecondaryVariant.outlined].
class MxSecondaryButton extends StatelessWidget {
  const MxSecondaryButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.size = MxButtonSize.compact,
    this.variant = MxSecondaryVariant.tonal,
    this.fullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final MxButtonSize size;
  final MxSecondaryVariant variant;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final Widget button = _buildVariant(context);
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildVariant(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    final Size minimumSize = Size(0, size.height);
    const EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: MxSpacing.space4,
    );
    final Widget child = _MxLabel(icon: icon, label: label);

    return switch (variant) {
      MxSecondaryVariant.tonal => FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.accentSoft,
          foregroundColor: colors.accent,
          elevation: 0,
          shape: const StadiumBorder(),
          minimumSize: minimumSize,
          padding: padding,
          textStyle: theme.textTheme.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        child: child,
      ),
      MxSecondaryVariant.text => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          shape: const StadiumBorder(),
          minimumSize: minimumSize,
          padding: padding,
          textStyle: theme.textTheme.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        child: child,
      ),
      MxSecondaryVariant.outlined => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.accent,
          side: BorderSide(color: colors.borderStrong),
          shape: const StadiumBorder(),
          minimumSize: minimumSize,
          padding: padding,
          textStyle: theme.textTheme.labelLarge,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        child: child,
      ),
    };
  }
}

/// Shared icon+label content for the button primitives.
class _MxLabel extends StatelessWidget {
  const _MxLabel({required this.icon, required this.label});

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: MxSpacing.space2),
        Text(label),
      ],
    );
  }
}
