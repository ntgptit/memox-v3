import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/learning_settings_providers.dart';
import 'package:memox/app/di/progress_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/data/repositories/progress_repository_impl.dart';
import 'package:memox/domain/models/dashboard_progress_summary.dart';
import 'package:memox/domain/models/learning_settings.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/usecases/progress/load_dashboard_progress_summary_usecase.dart';
import 'package:riverpod/misc.dart';

int _epochMs(DateTime value) => value.millisecondsSinceEpoch;

class _FakeLearningSettingsRepository implements LearningSettingsRepository {
  _FakeLearningSettingsRepository(this.settings);

  final Result<LearningSettings> settings;

  @override
  Future<Result<LearningSettings>> load() async => settings;

  @override
  Future<Result<void>> save(LearningSettings settings) async =>
      const Result<void>.ok(null);
}

class _FakeProgressRepository implements ProgressRepository {
  _FakeProgressRepository({
    Result<ProgressDueSummary>? dueSummary,
    Result<Map<DateTime, int>>? attemptCountsByDay,
  }) : dueSummary =
           dueSummary ??
           const Result<ProgressDueSummary>.ok(
             ProgressDueSummary(totalDueCount: 0, decks: <DeckDueSummary>[]),
           ),
       attemptCountsByDay =
           attemptCountsByDay ??
           const Result<Map<DateTime, int>>.ok(<DateTime, int>{});

  final Result<ProgressDueSummary> dueSummary;
  final Result<Map<DateTime, int>> attemptCountsByDay;

  @override
  Future<Result<ProgressDueSummary>> loadProgressDueSummary({
    required DateTime now,
  }) async => dueSummary;

  @override
  Future<Result<Map<DateTime, int>>> loadAttemptCountsByDay() async =>
      attemptCountsByDay;

  @override
  Future<Result<BoxDistribution>> loadBoxDistribution() async {
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
    throw UnimplementedError();
  }
}

class _DashboardProgressFixture {
  _DashboardProgressFixture(this.db, this.now);

  final AppDatabase db;
  final DateTime now;

  int get nowMs => now.millisecondsSinceEpoch;

  Future<void> insertFolder({
    required String id,
    required String name,
    required int sortOrder,
  }) async {
    await db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(
            id: id,
            parentId: const Value<String?>(null),
            name: name,
            contentMode: const Value<String>('decks'),
            sortOrder: Value<int>(sortOrder),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
  }

  Future<void> insertDeck({
    required String id,
    required String folderId,
    required String name,
    required int sortOrder,
  }) async {
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: id,
            folderId: folderId,
            name: name,
            sortOrder: Value<int>(sortOrder),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
  }

  Future<void> insertCard({
    required String id,
    required String deckId,
    required String front,
    required String back,
    required int dueAtMs,
    int boxNumber = 1,
    int? buriedUntilMs,
    bool isSuspended = false,
  }) async {
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
    await db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion(
            flashcardId: Value<String>(id),
            boxNumber: Value<int>(boxNumber),
            dueAt: Value<int?>(dueAtMs),
            buriedUntil: Value<int?>(buriedUntilMs),
            isSuspended: Value<bool>(isSuspended),
            reviewCount: const Value<int>(0),
            lapseCount: const Value<int>(0),
            lastStudiedAt: const Value<int?>(null),
          ),
        );
  }

  Future<void> insertSession({
    required String id,
    required int startedAtMs,
  }) async {
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: id,
            entryType: 'deck',
            entryRefId: const Value<String?>(null),
            studyType: 'new_cards',
            status: 'in_progress',
            startedAt: startedAtMs,
            updatedAt: startedAtMs,
          ),
        );
  }

  Future<void> insertSessionItem({
    required String id,
    required String sessionId,
    required String flashcardId,
    required int sortOrder,
    required int answeredAtMs,
  }) async {
    await db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            flashcardId: flashcardId,
            sortOrder: sortOrder,
            answeredAt: Value<int?>(answeredAtMs),
            createdAt: answeredAtMs,
            updatedAt: answeredAtMs,
          ),
        );
  }

  Future<void> insertAttempt({
    required String id,
    required String sessionItemId,
    required String result,
    required String studyMode,
    required int attemptedAtMs,
    required int boxBefore,
    required int boxAfter,
  }) async {
    await db
        .into(db.studyAttempts)
        .insert(
          StudyAttemptsCompanion.insert(
            id: id,
            sessionItemId: sessionItemId,
            result: result,
            studyMode: studyMode,
            boxBefore: Value<int>(boxBefore),
            boxAfter: Value<int>(boxAfter),
            attemptedAt: attemptedAtMs,
          ),
        );
  }
}

void main() {
  test('provider wiring resolves the dashboard progress summary use case', () {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        progressRepositoryProvider.overrideWithValue(_FakeProgressRepository()),
        learningSettingsRepositoryProvider.overrideWithValue(
          _FakeLearningSettingsRepository(
            const Result<LearningSettings>.ok(LearningSettings.defaults),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final LoadDashboardProgressSummaryUseCase useCase = container.read(
      loadDashboardProgressSummaryUseCaseProvider,
    );

    expect(useCase, isA<LoadDashboardProgressSummaryUseCase>());
  });

  test('empty data returns a zero-safe dashboard summary', () async {
    final LoadDashboardProgressSummaryUseCase useCase =
        LoadDashboardProgressSummaryUseCase(
          _FakeProgressRepository(),
          _FakeLearningSettingsRepository(
            const Result<LearningSettings>.ok(LearningSettings.defaults),
          ),
        );

    final Result<DashboardProgressSummary> result = await useCase.call(
      now: DateTime(2026, 1, 10, 12),
    );

    expect(result, isA<Ok<DashboardProgressSummary>>());
    final DashboardProgressSummary summary =
        (result as Ok<DashboardProgressSummary>).value;
    expect(summary.dueTodayCount, 0);
    expect(
      summary.goal,
      const DashboardGoalSummary.enabled(
        dailyGoal: LearningSettings.defaultDailyNewLimit,
        todayAttemptCount: 0,
      ),
    );
    expect(
      summary.streak,
      const DashboardStreakSummary.known(currentStreak: 0),
    );
  });

  test(
    'computes due counts, daily progress, and streak from persisted data',
    () async {
      final DateTime now = DateTime(2026, 1, 10, 12);
      final AppDatabase db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final _DashboardProgressFixture fixture = _DashboardProgressFixture(
        db,
        now,
      );
      await fixture.insertFolder(
        id: 'folder-1',
        name: 'Folder 1',
        sortOrder: 0,
      );
      await fixture.insertDeck(
        id: 'deck-1',
        folderId: 'folder-1',
        name: 'Deck 1',
        sortOrder: 0,
      );
      await fixture.insertCard(
        id: 'due-card',
        deckId: 'deck-1',
        front: 'Due',
        back: 'Due',
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'suspended-card',
        deckId: 'deck-1',
        front: 'Suspended',
        back: 'Suspended',
        dueAtMs: now.millisecondsSinceEpoch,
        isSuspended: true,
      );
      await fixture.insertCard(
        id: 'buried-card',
        deckId: 'deck-1',
        front: 'Buried',
        back: 'Buried',
        dueAtMs: now.millisecondsSinceEpoch,
        buriedUntilMs: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await fixture.insertSession(id: 'session-1', startedAtMs: _epochMs(now));
      await fixture.insertSessionItem(
        id: 'item-1',
        sessionId: 'session-1',
        flashcardId: 'due-card',
        sortOrder: 0,
        answeredAtMs: _epochMs(now.subtract(const Duration(days: 2))),
      );
      await fixture.insertAttempt(
        id: 'attempt-1',
        sessionItemId: 'item-1',
        result: 'perfect',
        studyMode: 'recall',
        attemptedAtMs: _epochMs(now.subtract(const Duration(days: 2))),
        boxBefore: 1,
        boxAfter: 2,
      );
      await fixture.insertSession(
        id: 'session-2',
        startedAtMs: _epochMs(now.subtract(const Duration(days: 1))),
      );
      await fixture.insertSessionItem(
        id: 'item-2',
        sessionId: 'session-2',
        flashcardId: 'due-card',
        sortOrder: 0,
        answeredAtMs: _epochMs(now.subtract(const Duration(days: 1))),
      );
      await fixture.insertAttempt(
        id: 'attempt-2',
        sessionItemId: 'item-2',
        result: 'perfect',
        studyMode: 'recall',
        attemptedAtMs: _epochMs(now.subtract(const Duration(days: 1))),
        boxBefore: 2,
        boxAfter: 3,
      );
      await fixture.insertSession(id: 'session-3', startedAtMs: _epochMs(now));
      await fixture.insertSessionItem(
        id: 'item-3',
        sessionId: 'session-3',
        flashcardId: 'due-card',
        sortOrder: 0,
        answeredAtMs: _epochMs(now),
      );
      await fixture.insertAttempt(
        id: 'attempt-3',
        sessionItemId: 'item-3',
        result: 'perfect',
        studyMode: 'recall',
        attemptedAtMs: _epochMs(now),
        boxBefore: 3,
        boxAfter: 4,
      );

      final ProgressRepositoryImpl progressRepository = ProgressRepositoryImpl(
        ProgressDao(db),
      );

      final LoadDashboardProgressSummaryUseCase useCase =
          LoadDashboardProgressSummaryUseCase(
            progressRepository,
            _FakeLearningSettingsRepository(
              const Result<LearningSettings>.ok(
                LearningSettings(dailyNewLimit: 1, goalDisabledSince: null),
              ),
            ),
          );

      final Result<DashboardProgressSummary> result = await useCase.call(
        now: now,
      );

      expect(result, isA<Ok<DashboardProgressSummary>>());
      final DashboardProgressSummary summary =
          (result as Ok<DashboardProgressSummary>).value;

      final Result<ProgressReadModel> readModelResult =
          await ProgressRepositoryImpl(
            ProgressDao(db),
          ).loadProgressReadModel(now: now);
      final ProgressReadModel readModel =
          (readModelResult as Ok<ProgressReadModel>).value;

      expect(summary.dueTodayCount, readModel.dueSummary.totalDueCount);
      expect(summary.dueTodayCount, 1);
      expect(
        summary.goal,
        const DashboardGoalSummary.enabled(dailyGoal: 1, todayAttemptCount: 1),
      );
      expect(
        summary.streak,
        const DashboardStreakSummary.known(currentStreak: 3),
      );
      expect(readModel.studyStatistics.totalAttemptCount, 3);
    },
  );

  test(
    'disabled goal returns a disabled goal state and unknown streak',
    () async {
      final LoadDashboardProgressSummaryUseCase useCase =
          LoadDashboardProgressSummaryUseCase(
            _FakeProgressRepository(
              attemptCountsByDay: const Result<Map<DateTime, int>>.ok(
                <DateTime, int>{},
              ),
            ),
            _FakeLearningSettingsRepository(
              Result<LearningSettings>.ok(
                LearningSettings(
                  dailyNewLimit: 20,
                  goalDisabledSince: DateTime(2026, 1, 8),
                ),
              ),
            ),
          );

      final Result<DashboardProgressSummary> result = await useCase.call(
        now: DateTime(2026, 1, 10, 12),
      );

      expect(result, isA<Ok<DashboardProgressSummary>>());
      final DashboardProgressSummary summary =
          (result as Ok<DashboardProgressSummary>).value;
      expect(
        summary.goal,
        DashboardGoalSummary.disabled(
          dailyGoal: 20,
          disabledSince: DateTime(2026, 1, 8),
          todayAttemptCount: 0,
        ),
      );
      expect(summary.streak, const DashboardStreakSummary.unknown());
    },
  );
}
