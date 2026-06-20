import 'package:memox/core/error/failure.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

/// Maps a folder-mutation [Failure] to localized snackbar copy.
///
/// Typed failures (validation code, content-mode lock, not-found) get a specific
/// message; everything else falls back to the generic action error. Never
/// surfaces raw exception text (`memox.error_handling.no_ui_error_stringify`).
/// WBS 2.2.2 / 2.3.2 / 2.4.2.
String folderFailureMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      ValidationFailure(:final ValidationCode code) => switch (code) {
        ValidationCode.empty => l10n.folderErrorNameEmpty,
        ValidationCode.duplicate => l10n.folderErrorNameDuplicate,
        ValidationCode.cycleDetected => l10n.folderErrorMoveCycle,
        _ => l10n.folderActionGenericError,
      },
      NotFoundFailure() => l10n.folderErrorNotFound,
      UnsupportedActionFailure(:final String message)
          when message == 'folder_contains_decks' =>
        l10n.folderErrorMoveLockedDecks,
      _ => l10n.folderActionGenericError,
    };
