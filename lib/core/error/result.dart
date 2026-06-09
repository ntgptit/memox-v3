import 'package:memox/core/error/failure.dart';

/// Synchronous result of an operation that can fail with a [Failure].
///
/// This is MemoX's existing result/failure contract — failures are values,
/// not thrown exceptions (`docs/contracts/error-contract.md`). The target
/// architecture migrates this to `fpdart`'s `Either<Failure, T>`; until that
/// dependency/API migration is approved, use [Result].
///
/// ```dart
/// final result = await getFlashcard(id);
/// return switch (result) {
///   Ok(:final value) => state = AsyncData(value),
///   Err(:final failure) => state = AsyncError(failure, StackTrace.current),
/// };
/// ```
sealed class Result<T> {
  const Result();

  /// Wraps a success value.
  const factory Result.ok(T value) = Ok<T>;

  /// Wraps a [Failure].
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// Success value, or `null` when this is an [Err].
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  /// Failure, or `null` when this is an [Ok].
  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  /// Collapses both branches to a single [R].
  R fold<R>(R Function(Failure failure) onErr, R Function(T value) onOk) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };

  /// Transforms the success value, preserving any [Failure].
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Ok<R>(transform(value)),
    Err<T>(:final failure) => Err<R>(failure),
  };

  /// Chains another fallible operation onto the success value.
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => transform(value),
    Err<T>(:final failure) => Err<R>(failure),
  };
}

/// Success branch of a [Result].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Failure branch of a [Result].
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Err<T> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;
}
