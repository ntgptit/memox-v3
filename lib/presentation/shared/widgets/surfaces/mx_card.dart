import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// Base container — flat surface + ghost border, no shadow.
///
/// Section C of the handoff. Inherits color/border/radius from the themed
/// `CardThemeData` (`surfaceContainerLowest` + 1px ghost border, radius lg).
/// Adds the design-system 16dp card padding (`--memox-space-card`) and optional
/// tap behavior so features stop hand-rolling `Container(decoration: ...)`.
///
/// Purpose:
/// Provides a reusable MemoX card widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared card surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - child: public content.
/// - padding: public property.
/// - onTap: callback.
/// - onLongPress: callback.
/// - clip: public property.
/// Category:
/// card
class MxCard extends StatelessWidget {
  const MxCard({
    required this.child,
    this.padding = const EdgeInsets.all(SpacingTokens.cardPadding),
    this.onTap,
    this.onLongPress,
    this.clip = Clip.antiAlias,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Clip clip;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: clip,
    child: MxTappable(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: RadiusTokens.brLg,
      child: Padding(padding: padding, child: child),
    ),
  );
}
