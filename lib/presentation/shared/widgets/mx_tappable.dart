import 'package:flutter/material.dart';

import 'package:memox/core/theme/tokens/radius_tokens.dart';

/// The single shaped tap primitive every interactive surface routes through.
///
/// Per the MemoX guard rule `memox.design_system.no_raw_ink_surface`, this is the **only**
/// place allowed to use a raw `InkWell` — feature and shared widgets compose
/// `MxTappable` instead of hand-rolling `InkWell` / `InkResponse` / tap-only
/// `GestureDetector`. It guarantees hover/focus/pressed overlays clipped to the
/// widget's visual shape ([borderRadius] or [customBorder]).
///
/// Purpose:
/// Provides a reusable MemoX utility widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared utility surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - child: public content.
/// - onTap: callback.
/// - onLongPress: callback.
/// - borderRadius: public property.
/// - customBorder: public property.
/// - focusNode: public property.
/// - autofocus: public property.
/// - excludeFromSemantics: public property.
/// Category:
/// utility
class MxTappable extends StatelessWidget {
  const MxTappable({
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.borderRadius = RadiusTokens.brMd,
    this.customBorder,
    this.focusNode,
    this.autofocus = false,
    this.excludeFromSemantics = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Shape of the interaction overlay. Ignored when [customBorder] is set.
  final BorderRadius borderRadius;
  final ShapeBorder? customBorder;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: customBorder == null ? borderRadius : null,
      customBorder: customBorder,
      focusNode: focusNode,
      autofocus: autofocus,
      excludeFromSemantics: excludeFromSemantics,
      child: child,
    ),
  );
}
