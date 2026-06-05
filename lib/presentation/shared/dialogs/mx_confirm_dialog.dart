import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';

/// Binary confirmation dialog (`docs/wireframes/24-shared-dialogs.md`
/// §delete-confirm and other confirm flows).
///
/// Returns `true` only when the user taps confirm; cancel / dismiss returns
/// `false`. All copy is caller-supplied (localized). [destructive] tints the
/// confirm button with the error role for delete-style actions.
Future<bool> showMxConfirmDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required String cancelLabel,
  String? message,
  bool destructive = false,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final ColorScheme scheme = context.colorScheme;
      return AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
