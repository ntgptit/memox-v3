import 'package:flutter/material.dart';
import 'package:memox/core/theme/responsive/breakpoints.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// Centers and width-caps reading content on large screens.
///
/// `docs/ui-ux/ui-ux-contract.md` §Responsive: content must not stretch too
/// wide. Caps at [Breakpoints.maxBodyWidth] (720) and applies horizontal
/// [padding]. Use inside every screen body.
///
/// Purpose:
/// Provides a reusable MemoX layout widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared layout surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - child: public content.
/// - maxWidth: public property.
/// - padding: public property.
/// Category:
/// layout
class MxContentShell extends StatelessWidget {
  const MxContentShell({
    required this.child,
    this.maxWidth = Breakpoints.maxBodyWidth,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SpacingTokens.screenPadding,
    ),
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}
