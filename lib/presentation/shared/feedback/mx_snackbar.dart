import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';

/// The sanctioned snackbar surface — feature code must route transient feedback
/// through this helper instead of raw `SnackBar` / `ScaffoldMessenger`
/// (`memox.snackbar_usage`, `memox.snackbar_messenger_usage`).
///
/// [message] is caller-supplied (localized). [isError] tints the container with
/// the error color.
void showMxSnackbar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  final ColorScheme scheme = context.colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? scheme.onErrorContainer : scheme.onInverseSurface,
          ),
        ),
        backgroundColor:
            isError ? scheme.errorContainer : scheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
