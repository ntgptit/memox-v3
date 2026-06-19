import 'package:memox/data/datasources/local/daos/example_dao.dart';

/// Skeleton stub implementation of [ExampleDao].
///
/// Exists to demonstrate the `DAO → repository → use case → provider` wiring
/// of the Clean Architecture baseline (WBS 1.1.1). Real DAOs are Drift-generated
/// and replace this once a Drift database is introduced.
final class ExampleStubDao implements ExampleDao {
  const ExampleStubDao();

  static const String _placeholderValue = 'example';

  @override
  Future<String> getExample() async => _placeholderValue;
}
