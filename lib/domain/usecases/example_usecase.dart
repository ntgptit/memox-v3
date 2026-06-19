import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/example_repository.dart';

class ExampleUseCase {
  const ExampleUseCase({required this.repository});

  final ExampleRepository repository;

  Future<Result<String>> call() => repository.example();
}
