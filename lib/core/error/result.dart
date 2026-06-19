import 'package:memox/core/error/failure.dart';

typedef Result<T> = ({Failure? failure, T? data});

extension ResultExt<T> on Result<T> {
  bool get isSuccess => failure == null;

  bool get isFailure => failure != null;

  T? get dataOrNull => data;

  Failure? get failureOrNull => failure;
}
