import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/box_distribution.dart';
import 'package:memox/domain/models/due_summary.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/models/study_statistics.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/usecases/progress/load_progress_read_model_usecase.dart';

class _FakeProgressRepository implements ProgressRepository {
  int? requestedNow;

  @override
  Future<Result<ProgressReadModel>> loadProgressReadModel({
    required int now,
  }) async {
    requestedNow = now;
    return (
      failure: null,
      data: const ProgressReadModel(
        dueSummary: DueSummary(totalDueCount: 4, decksWithDue: []),
        boxDistribution: BoxDistribution(countsByBox: {1: 4}),
        statistics: StudyStatistics(
          completedSessions: 1,
          totalAttempts: 4,
          correctCount: 3,
          forgotCount: 1,
          lastStudiedAt: 123,
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  test('delegates to the repository and injects a current clock', () async {
    final repo = _FakeProgressRepository();
    final useCase = LoadProgressReadModelUseCase(repository: repo);

    final before = DateTime.now().millisecondsSinceEpoch;
    final result = await useCase.call();
    final after = DateTime.now().millisecondsSinceEpoch;

    expect(result.failure, isNull);
    expect(result.data!.dueSummary.totalDueCount, 4);
    expect(result.data!.statistics.completedSessions, 1);
    expect(repo.requestedNow, inInclusiveRange(before, after));
  });
}
