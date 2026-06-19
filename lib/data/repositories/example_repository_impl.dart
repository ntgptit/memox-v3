import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/example_dao.dart';
import 'package:memox/domain/repositories/example_repository.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  const ExampleRepositoryImpl({required this.exampleDao});

  final ExampleDao exampleDao;

  @override
  Future<Result<String>> example() async {
    try {
      final result = await exampleDao.getExample();
      return (failure: null, data: result);
    } catch (e) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          cause: e.toString(),
        ),
        data: null,
      );
    }
  }
}
