import 'package:memox/core/error/failure.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

/// Maps a flashcard/deck-mutation [Failure] to localized snackbar copy.
///
/// Never surfaces raw exception text
/// (`memox.error_handling.no_ui_error_stringify`). WBS 3.4.2 / 2.7.2.
String flashcardFailureMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      ValidationFailure(:final ValidationCode code) => switch (code) {
        ValidationCode.empty => l10n.flashcardErrorEmpty,
        ValidationCode.duplicate => l10n.flashcardErrorDuplicate,
        _ => l10n.flashcardActionGenericError,
      },
      NotFoundFailure() => l10n.flashcardErrorNotFound,
      _ => l10n.flashcardActionGenericError,
    };
