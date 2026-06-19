import 'package:flutter/material.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';

/// A binary confirm/cancel dialog, with an optional destructive treatment.
///
/// Purpose:
/// The single confirmation primitive behind every "are you sure" flow (delete,
/// discard, reset), so confirm/cancel ordering, destructive coloring, and the
/// `Future<bool>` contract are consistent. See `docs/wireframes/24-shared-dialogs.md`.
///
/// Use when:
/// Asking the user to confirm a single action with a specific consequence.
///
/// Do not use when:
/// You need typed input, multiple choices, or a list (use a form / bottom
/// sheet).
///
/// Category:
/// dialog
///
/// Public API:
/// - title: states the action; pass already-localized copy.
/// - message: states the specific consequence; already-localized.
/// - confirmLabel / cancelLabel: action labels (already-localized).
/// - destructive: error-colored confirm + non-dismissible barrier.
///
/// States:
/// - destructive vs safe confirm styling, driven by [destructive].
class MxConfirmDialog extends StatelessWidget {
  const MxConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  /// Shows the dialog and resolves to `true` on confirm, `false` on cancel or
  /// dismissal. Destructive dialogs are modal-locked (no barrier dismiss).
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    bool destructive = false,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: !destructive,
      builder: (BuildContext context) => MxConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) => MxDialog(
    title: title,
    content: Text(message),
    actions: <Widget>[
      MxSecondaryButton(
        label: cancelLabel,
        variant: MxSecondaryVariant.text,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      MxPrimaryButton(
        label: confirmLabel,
        size: MxButtonSize.compact,
        destructive: destructive,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
}
