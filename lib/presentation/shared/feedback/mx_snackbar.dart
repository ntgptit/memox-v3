import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// The sanctioned snackbar surface — feature code must route transient feedback
/// through this helper instead of raw `SnackBar` / `ScaffoldMessenger`
/// (`memox.snackbar_usage`, `memox.snackbar_messenger_usage`).
///
/// [message] is caller-supplied (localized). [isError] adds an error-accent
/// leading icon while keeping the shared snackbar surface tone from the mock.
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
  final TextStyle messageStyle = TextStyle(color: scheme.onSurface);
  final Widget content = isError
      ? Row(
          children: <Widget>[
            ExcludeSemantics(
              child: Icon(
                Icons.error_outline,
                size: SizeTokens.iconXs,
                color: scheme.error,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(child: Text(message, style: messageStyle)),
          ],
        )
      : Text(message, style: messageStyle);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: scheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
