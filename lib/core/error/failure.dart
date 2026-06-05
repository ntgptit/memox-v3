import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Validation failure codes (`docs/contracts/error-contract.md`
/// §ValidationFailure subtypes). Maps to localized copy via
/// `ValidationMessages`.
enum ValidationCode {
  empty,
  tooLong,
  tooShort,
  invalidCharacter,
  duplicate,
  invalidFormat,
  outOfRange,
  parentModeLocked,
  cycleDetected,
  insufficientContent,
}

/// Database operation that produced a [StorageFailure].
enum StorageOp { read, write, transaction, migration }

/// Class of a [NetworkFailure]. `http` carries a status in
/// [NetworkFailure.statusCode].
enum NetworkErrorKind { offline, timeout, http, parse }

/// Stable string codes for specific failures that need a dedicated localized
/// message rather than the generic per-(field, code) mapping.
///
/// These mirror MemoX's existing folder lock-mode codes; see
/// `docs/contracts/error-contract.md` (folder lock-mode note).
abstract final class FailureCodes {
  FailureCodes._();

  static const String folderContainsDecks = 'folder_contains_decks';
  static const String folderContainsSubfolders = 'folder_contains_subfolders';
}

/// Sealed taxonomy of every recoverable failure in MemoX.
///
/// The taxonomy is **closed**: adding a top-level variant requires updating
/// `docs/contracts/error-contract.md` and every UI mapper. Pattern-match
/// exhaustively; never stringify a failure for the UI.
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// Input violates a business rule. Save button stays enabled; show inline.
  const factory Failure.validation({
    required String field,
    required ValidationCode code,
    String? message,
  }) = ValidationFailure;

  /// Referenced entity does not exist.
  const factory Failure.notFound({required String entity, String? id}) =
      NotFoundFailure;

  /// Database read/write failed. [cause] is for logs only — never shown.
  const factory Failure.storage({
    required StorageOp operation,
    required String cause,
    String? table,
  }) = StorageFailure;

  /// Network IO failed (Drive sync, OAuth). Hide retry when not [retryable].
  const factory Failure.network({
    required NetworkErrorKind kind,
    @Default(true) bool retryable,
    int? statusCode,
  }) = NetworkFailure;

  /// OAuth token invalid / refresh failed / scope changed.
  const factory Failure.auth({String? message}) = AuthFailure;

  /// Data invariant violated (cycle, orphan, schema mismatch). Log SEVERE,
  /// abort, no automated recovery.
  const factory Failure.integrity({required String message, String? cause}) =
      IntegrityFailure;

  /// Concurrent modification or duplicate during create/update.
  const factory Failure.conflict({String? message}) = ConflictFailure;

  /// Action invoked in an invalid state. UI should prevent reaching this.
  const factory Failure.unsupportedAction({String? action}) =
      UnsupportedActionFailure;

  /// User cancelled mid-operation. Silent; revert UI.
  const factory Failure.cancelled() = CancelledFailure;

  /// Session completion partially failed; session marked failed_to_finalize.
  const factory Failure.finalization({String? sessionId}) = FinalizationFailure;
}
