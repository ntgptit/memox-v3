import 'package:flutter/material.dart';

/// Floating action button wrapper — regular or extended (labelled pill).
///
/// Feature code must not use raw `FloatingActionButton`
/// (`memox.feature_raw_flutter_widget_usage`); compose this instead. Styling
/// (container color, level-2 elevation, radius) comes from the themed
/// `FloatingActionButtonThemeData`.
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
    if (label == null) {
      return FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        heroTag: heroTag,
        child: Icon(icon),
      );
    }
    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: tooltip,
      heroTag: heroTag,
      icon: Icon(icon),
      label: Text(label!),
    );
  }
}
