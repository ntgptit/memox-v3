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
  _present(
    ScaffoldMessenger.of(context),
    context,
    message: message,
    isError: isError,
  );
}

/// Variant for app-wide callers that already hold the [ScaffoldMessengerState]
/// (e.g. the global provider observer via `appMessengerKey`). Avoids the
/// ancestor lookup `ScaffoldMessenger.of` does, which fails when invoked from
/// the messenger's own context. [context] supplies theme colors only.
void showMxSnackbarOn(
  ScaffoldMessengerState messenger,
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  _present(messenger, context, message: message, isError: isError);
}

void _present(
  ScaffoldMessengerState messenger,
  BuildContext context, {
  required String message,
  required bool isError,
}) {
  final ColorScheme scheme = context.colorScheme;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? scheme.onErrorContainer : scheme.onInverseSurface,
          ),
        ),
        backgroundColor: isError
            ? scheme.errorContainer
            : scheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
