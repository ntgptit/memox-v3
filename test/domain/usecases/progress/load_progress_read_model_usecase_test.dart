import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/database_providers.dart';
import 'package:memox/app/di/progress_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/types/progress_range.dart';
import 'package:memox/domain/usecases/progress/load_progress_read_model_usecase.dart';
import 'package:riverpod/misc.dart';

class _RecordingProgressRepository implements ProgressRepository {
  _RecordingProgressRepository({Result<ProgressReadModel>? result})
    : result =
          result ??
          const Result<ProgressReadModel>.ok(
            ProgressReadModel(
              dueSummary: ProgressDueSummary(
                totalDueCount: 0,
                decks: <DeckDueSummary>[],
              ),
              boxDistribution: BoxDistribution(boxes: <BoxDistributionItem>[]),
              studyStatistics: StudyStatistics(
                completedSessionCount: 0,
                totalAttemptCount: 0,
                correctCount: 0,
                forgotCount: 0,
                lastStudiedAt: null,
              ),
            ),
          );

  final Result<ProgressReadModel> result;
  DateTime? lastNow;

  @override
  Future<Result<ProgressDueSummary>> loadProgressDueSummary({
    required DateTime now,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<DateTime, int>>> loadAttemptCountsByDay() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<BoxDistribution>> loadBoxDistribution() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<ProgressOverview>> loadProgressOverview({
    required DateTime now,
    required ProgressRange range,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudyStatistics>> loadStudyStatistics() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<ProgressReadModel>> loadProgressReadModel({
    required DateTime now,
  }) async {
    lastNow = now;
    return result;
  }
}

void main() {
  test('forwards now to the repository', () async {
    final _RecordingProgressRepository repository =
        _RecordingProgressRepository();
    final LoadProgressReadModelUseCase useCase = LoadProgressReadModelUseCase(
      repository,
    );
    final DateTime now = DateTime.utc(2026, 1, 10, 12);

    final Result<ProgressReadModel> result = await useCase.call(now: now);

    expect(result, isA<Ok<ProgressReadModel>>());
    expect(repository.lastNow, now);
  });

  test(
    'provider wiring resolves the use case and loads an empty model',
    () async {
      final AppDatabase db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final LoadProgressReadModelUseCase useCase = container.read(
        loadProgressReadModelUseCaseProvider,
      );
      expect(useCase, isA<LoadProgressReadModelUseCase>());

      final Result<ProgressReadModel> result = await useCase.call(
        now: DateTime.utc(2026, 1, 10, 12),
      );

      final ProgressReadModel model = (result as Ok<ProgressReadModel>).value;
      expect(model.dueSummary.totalDueCount, 0);
      expect(model.dueSummary.decks, isEmpty);
      expect(model.boxDistribution.boxes.map((row) => row.cardCount), <int>[
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ]);
      expect(model.studyStatistics.completedSessionCount, 0);
      expect(model.studyStatistics.totalAttemptCount, 0);
      expect(model.studyStatistics.correctCount, 0);
      expect(model.studyStatistics.forgotCount, 0);
      expect(model.studyStatistics.lastStudiedAt, isNull);
    },
  );
}
