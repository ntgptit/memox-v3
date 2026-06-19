import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

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

enum NetworkErrorKind { offline, timeout, parse }

enum StorageOp { read, write, transaction, migration }

@freezed
sealed class Failure with _$Failure {
  const factory Failure.validation({
    required String field,
    required ValidationCode code,
    String? message,
  }) = ValidationFailure;

  const factory Failure.notFound({required String entity}) = NotFoundFailure;

  const factory Failure.storage({
    required StorageOp operation,
    String? table,
    required String cause,
  }) = StorageFailure;

  const factory Failure.network({
    required NetworkErrorKind kind,
    required bool retryable,
  }) = NetworkFailure;

  const factory Failure.auth({required String reason}) = AuthFailure;

  const factory Failure.integrity({required String message}) = IntegrityFailure;

  const factory Failure.conflict({required String message}) = ConflictFailure;

  const factory Failure.unsupportedAction({required String message}) =
      UnsupportedActionFailure;

  const factory Failure.cancelled() = CancelledFailure;

  const factory Failure.finalization({required String message}) =
      FinalizationFailure;
}
