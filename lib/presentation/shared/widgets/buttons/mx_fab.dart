import 'package:flutter/material.dart';

/// Floating action button wrapper — minimal icon-only FAB.
///
/// Feature code must not use raw `FloatingActionButton`
/// (`memox.design_system.no_raw_fab`); compose this instead. Styling
/// (container color, level-2 elevation, radius) comes from the themed
/// `FloatingActionButtonThemeData`.
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
/// - icon: public content.
/// - label: accessibility hint / tooltip text.
/// - onPressed: callback.
/// - tooltip: public property.
/// - heroTag: public property.
/// Category:
/// button
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

  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final String? resolvedTooltip = tooltip ?? label;
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: resolvedTooltip,
      heroTag: heroTag,
      child: Icon(icon),
    );
  }
}
