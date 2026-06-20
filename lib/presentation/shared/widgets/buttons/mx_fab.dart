import 'package:flutter/material.dart';

/// Floating action button wrapper — minimal icon-only (or extended) FAB.
///
/// Purpose:
/// Feature code must not use a raw `FloatingActionButton`
/// (`memox.design_system.no_raw_fab`); compose this instead. Container colour /
/// elevation / radius come from the themed `FloatingActionButtonThemeData`
/// (Material defaults from the `ColorScheme` until a token override ships).
/// WBS 1.2.6.
///
/// Use when:
/// A screen needs a primary create/add action anchored to the corner.
///
/// Do not use when:
/// The action belongs inline in content (use the shared button primitives).
///
/// Category:
/// button
///
/// Public API:
/// - icon: the leading glyph.
/// - label: trailing label for the extended variant (`null` = icon-only).
/// - onPressed: tap handler (`null` disables the button).
/// - tooltip: accessibility tooltip (falls back to [label]).
/// - heroTag: hero tag override when multiple FABs can coexist.
class MxFab extends StatelessWidget {
  const MxFab({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.heroTag,
    super.key,
  }) : label = null;

  /// Extended FAB with a trailing [label] (e.g. the Library `New folder` pill).
  const MxFab.extended({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tooltip,
    this.heroTag,
    super.key,
  });

  /// Leading glyph.
  final IconData icon;

  /// Trailing label for the extended variant; `null` = icon-only FAB.
  final String? label;

  /// Tap handler; `null` disables the button.
  final VoidCallback? onPressed;

  /// Accessibility tooltip; falls back to [label] when omitted.
  final String? tooltip;

  /// Hero tag override (set when more than one FAB can coexist in a route).
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final String? fabLabel = label;
    final String? resolvedTooltip = tooltip ?? fabLabel;
    if (fabLabel == null) {
      return FloatingActionButton(
        onPressed: onPressed,
        tooltip: resolvedTooltip,
        heroTag: heroTag,
        child: Icon(icon),
      );
    }
    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: resolvedTooltip,
      heroTag: heroTag,
      icon: Icon(icon),
      label: Text(fabLabel),
    );
  }
}
