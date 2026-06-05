import 'package:memox/core/error/failure.dart';
import 'package:memox/core/utils/string_utils.dart';

/// Maps a [Failure] to the ARB key the presentation layer resolves for copy.
///
/// Core stays l10n-free: this returns key *names* (strings), and the widget
/// looks them up on `AppLocalizations`. Keys mirror the existing `error*`
/// entries in `lib/l10n/app_en.arb` and the per-(field, code) convention in
/// `docs/contracts/error-contract.md`.
abstract final class ValidationMessages {
  ValidationMessages._();

  static const String _genericKey = 'errorUnexpected';

  /// Per-field validation key, e.g. `('tag', invalidCharacter)` →
  /// `errorValidationTagInvalidCharacter`.
  static String arbKey(String field, ValidationCode code) =>
      'errorValidation${StringUtils.capitalize(field)}'
      '${StringUtils.capitalize(code.name)}';

  /// Dedicated key for a [FailureCodes] string (folder lock-mode messages).
  static String folderLockArbKey(String failureCode) => switch (failureCode) {
    FailureCodes.folderContainsDecks => 'errorFolderContainsDecks',
    FailureCodes.folderContainsSubfolders => 'errorFolderContainsSubfolders',
    _ => _genericKey,
  };

  /// Generic top-level mapping for non-validation failures, using the existing
  /// shared `error*` ARB keys. Validation failures resolve via [arbKey].
  static String failureArbKey(Failure failure) => switch (failure) {
    ValidationFailure(:final field, :final code) => arbKey(field, code),
    NotFoundFailure() => 'errorNotFound',
    StorageFailure() => 'errorStorage',
    NetworkFailure(:final kind) => switch (kind) {
      NetworkErrorKind.timeout => 'errorRequestTimedOut',
      NetworkErrorKind.parse => 'errorInvalidData',
      NetworkErrorKind.offline || NetworkErrorKind.http => 'errorNetwork',
    },
    AuthFailure() => 'errorConfiguration',
    UnsupportedActionFailure() => 'errorUnsupportedAction',
    IntegrityFailure() ||
    ConflictFailure() ||
    CancelledFailure() ||
    FinalizationFailure() => _genericKey,
  };
}
