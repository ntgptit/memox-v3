import 'package:memox/core/error/result.dart';

abstract interface class ExampleRepository {
  Future<Result<String>> example();
}
