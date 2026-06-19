import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';

/// The accent-filled primary button — the single dominant action on a surface.
///
/// Purpose:
/// The one high-emphasis CTA primitive, flat (no shadow) per the MemoX calm
/// aesthetic, with token color and a pill shape, so primaries look identical
/// everywhere. Density/full-width are usually chosen by `MxActionButton`.
///
/// Use when:
/// Rendering the single dominant action of a screen, card, dialog, or bottom
/// bar.
///
/// Do not use when:
/// The action is secondary (use `MxSecondaryButton`) or you want intent-driven
/// density (use `MxActionButton`).
///
/// Category:
/// button
///
/// Public API:
/// - label: button text; pass already-localized copy.
/// - onPressed: tap handler; null disables the button.
/// - icon: optional leading glyph.
/// - size: density (defaults to medium).
/// - fullWidth: stretch to the available width (defaults to false).
/// - destructive: use the danger fill for irreversible actions (delete/discard).
class MxPrimaryButton extends StatelessWidget {
  const MxPrimaryButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.size = MxButtonSize.medium,
    this.fullWidth = false,
    this.destructive = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final MxButtonSize size;
  final bool fullWidth;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    final Widget button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: destructive ? colors.danger : colors.accent,
        foregroundColor: colors.accentContrast,
        disabledBackgroundColor: colors.surfaceMuted,
        disabledForegroundColor: colors.textTertiary,
        elevation: 0,
        shape: const StadiumBorder(),
        minimumSize: Size(0, size.height),
        padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space5),
        textStyle: theme.textTheme.labelLarge,
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: _MxButtonLabel(icon: icon, label: label),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Shared icon+label content for the button primitives.
class _MxButtonLabel extends StatelessWidget {
  const _MxButtonLabel({required this.icon, required this.label});

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
