import 'package:flutter/material.dart';

import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// Base container — flat surface + ghost border, no shadow.
///
/// Section C of the handoff. Inherits color/border/radius from the themed
/// `CardThemeData` (`surfaceContainerLowest` + 1px ghost border, radius lg).
/// Adds the standard 12dp content padding and optional tap behavior so
/// features stop hand-rolling `Container(decoration: ...)`.
class MxCard extends StatelessWidget {
  const MxCard({
    required this.child,
    this.padding = const EdgeInsets.all(SpacingTokens.md),
    this.onTap,
    this.clip = Clip.antiAlias,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Clip clip;

  @override
  Widget build(BuildContext context) => Card(
      clipBehavior: clip,
      child: MxTappable(
        onTap: onTap,
        borderRadius: RadiusTokens.brLg,
        child: Padding(padding: padding, child: child),
      ),
    );
}
