import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/repositories/example_repository_impl.dart';
import 'package:memox/domain/usecases/example_usecase.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('DI baseline providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('wires DAO → repository → use case', () {
      expect(
        container.read(exampleRepositoryProvider),
        isA<ExampleRepositoryImpl>(),
      );
      expect(container.read(exampleUseCaseProvider), isA<ExampleUseCase>());
    });

    test('use case resolves the chain end to end', () async {
      final result = await container.read(exampleUseCaseProvider)();

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotEmpty);
    });
  });
}
