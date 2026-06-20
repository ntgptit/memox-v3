import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// The sanctioned snackbar surface — feature code must route transient feedback
/// through this helper instead of a raw `SnackBar` / `ScaffoldMessenger`
/// (`memox.design_system.no_raw_snackbar`,
/// `memox.design_system.no_direct_scaffold_messenger`). Lives in
/// `shared/feedback` (outside the feature guard scope, the sole sanctioned
/// `ScaffoldMessenger` caller). WBS 1.2.7.
///
/// [message] is caller-supplied (already localized). [isError] adds an
/// error-accent leading icon while keeping the shared snackbar surface tone.
void showMxSnackbar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  final TextStyle messageStyle = TextStyle(color: scheme.onSurface);
  final Widget content = isError
      ? Row(
          children: <Widget>[
            ExcludeSemantics(
              child: Icon(Icons.error_outline, color: scheme.error),
            ),
            const SizedBox(width: MxSpacing.space2),
            Expanded(child: Text(message, style: messageStyle)),
          ],
        )
      : Text(message, style: messageStyle);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: scheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
