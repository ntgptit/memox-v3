import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_radius.dart';

/// The single shaped tap primitive: a clipped ink surface for hover/focus/press.
///
/// Purpose:
/// Centralizes interactive ink so every tappable MemoX surface gets a hover,
/// focus, and pressed overlay whose shape matches the visual — no hand-rolled
/// `InkWell`/`GestureDetector` scattered across widgets (guard
/// `memox.design_system.no_raw_ink_surface` allows ink only here).
///
/// Use when:
/// Building a tappable shared surface (card, list row, tile) that needs a
/// correctly shaped ripple.
///
/// Do not use when:
/// The element is non-interactive (omit it) or needs gesture semantics beyond a
/// simple tap (compose a dedicated detector with documented reason).
///
/// Category:
/// utility
///
/// Public API:
/// - child: the content the ink is drawn over.
/// - onTap: optional tap handler; null renders a non-interactive surface.
/// - onLongPress: optional long-press handler (e.g. a row's overflow actions).
/// - borderRadius: shape of the ripple and clip (defaults to the small radius).
class MxTappable extends StatelessWidget {
  const MxTappable({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = MxRadius.smAll,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    borderRadius: borderRadius,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: borderRadius,
      child: child,
    ),
  );
}
