import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// Page body wrapper that owns the horizontal screen gutter and an optional
/// max-width cap.
///
/// Purpose:
/// Centralizes the page gutter so every screen aligns to the same left/right
/// margin, and caps content width on wide screens so lines never stretch
/// edge-to-edge. Owning the gutter here is what lets feature screens add only
/// vertical spacing in their bodies.
///
/// Use when:
/// Wrapping a screen's scrollable or column body (a scaffold normally applies
/// this for you).
///
/// Do not use when:
/// You are already inside a scaffold/shell that applies the gutter — wrapping
/// again double-insets the content.
///
/// Category:
/// layout
///
/// Public API:
/// - child: the page content to inset and (optionally) width-cap.
/// - maxWidth: optional max content width; when null the content fills the
///   available width (phone default).
class MxContentShell extends StatelessWidget {
  const MxContentShell({required this.child, this.maxWidth, super.key});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final Widget gutter = Padding(
      padding: const EdgeInsets.symmetric(horizontal: MxSpacing.screen),
      child: child,
    );
    final double? maxWidth = this.maxWidth;
    if (maxWidth == null) {
      return gutter;
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: gutter,
      ),
    );
  }
}
