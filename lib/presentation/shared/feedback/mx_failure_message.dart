import 'package:memox/core/error/failure.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

/// The single place the presentation layer turns a [Failure] into user-safe,
/// localized copy (`docs/contracts/error-contract.md` §Error mapping by layer).
///
/// Defaults cover the whole sealed taxonomy with the shared `error*` ARB
/// strings, so a screen never re-implements the `switch (failure)`. Two
/// optional overrides handle what legitimately varies per call site:
///
/// * [duplicate] — entity-specific duplicate copy (e.g. "folder" vs "deck").
/// * [fallback] — an action-specific generic line (e.g. "Couldn't create the
///   folder...") used in place of the bare generic for storage / not-found /
///   uncategorized cases, matching the action the user just attempted.
///
/// Generated `AppLocalizations` getters cannot be looked up by string key, so
/// this maps directly to getters rather than returning ARB key names.
extension MxFailureMessage on AppLocalizations {
  String failureMessage(
    Failure failure, {
    String? duplicate,
    String? fallback,
  }) => switch (failure) {
    ValidationFailure(code: ValidationCode.duplicate) =>
      duplicate ?? fallback ?? errorUnexpected,
    ValidationFailure(code: ValidationCode.cycleDetected) =>
      folderMovePickerCycleReason,
    ValidationFailure(code: ValidationCode.parentModeLocked) =>
      folderModeLockHint,
    // Remaining validation codes have no dedicated snackbar copy yet; the
    // action-specific fallback is more useful than a bare generic line.
    ValidationFailure() => fallback ?? errorUnexpected,
    // The only producers are folder content-mode violations.
    UnsupportedActionFailure() => folderModeLockHint,
    NotFoundFailure() => fallback ?? errorUnexpected,
    StorageFailure() => fallback ?? errorUnexpected,
    NetworkFailure(:final NetworkErrorKind kind) => switch (kind) {
      NetworkErrorKind.timeout => errorUnexpected,
      NetworkErrorKind.parse => errorUnexpected,
      NetworkErrorKind.offline || NetworkErrorKind.http => errorUnexpected,
    },
    AuthFailure() => errorUnexpected,
    ConflictFailure() ||
    IntegrityFailure() ||
    CancelledFailure() ||
    FinalizationFailure() => fallback ?? errorUnexpected,
  };
}
