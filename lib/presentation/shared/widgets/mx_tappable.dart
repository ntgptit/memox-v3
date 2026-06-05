import 'package:flutter/material.dart';

import 'package:memox/core/theme/tokens/radius_tokens.dart';

/// The single shaped tap primitive every interactive surface routes through.
///
/// Per the MemoX guard rule `memox.no_raw_ink_surface`, this is the **only**
/// place allowed to use a raw `InkWell` — feature and shared widgets compose
/// `MxTappable` instead of hand-rolling `InkWell` / `InkResponse` / tap-only
/// `GestureDetector`. It guarantees hover/focus/pressed overlays clipped to the
/// widget's visual shape ([borderRadius] or [customBorder]).
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
