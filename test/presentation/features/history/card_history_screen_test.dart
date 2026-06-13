import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/card_history_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/screens/card_history_screen.dart';
import 'package:memox/presentation/features/history/widgets/card_history_reset_divider.dart';
import 'package:memox/presentation/features/history/widgets/card_history_timeline_row.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

class _FakeCardHistoryRepository implements CardHistoryRepository {
  _FakeCardHistoryRepository({
    this.headerResult,
    this.pageResult,
    this.headerPending = false,
  });

  Result<CardHistoryHeader>? headerResult;
  Result<CardHistoryPage>? pageResult;
  final bool headerPending;

  @override
  Future<Result<CardHistoryHeader>> loadHeader({
    required String flashcardId,
  }) async {
    if (headerPending) {
      // Never completes — drives the loading state.
      return Completer<Result<CardHistoryHeader>>().future;
    }
    return headerResult!;
  }

  @override
  Future<Result<CardHistoryPage>> loadAttempts({
    required String flashcardId,
    CardHistoryCursor? before,
    int limit = kCardHistoryPageSize,
  }) async =>
      pageResult ??
      const Result<CardHistoryPage>.ok(
        CardHistoryPage(attempts: <CardHistoryAttempt>[], nextCursor: null),
      );

  @override
  Future<Result<void>> resetProgress({required String flashcardId}) async =>
      const Result<void>.ok(null);
}

CardHistoryHeader _header({
  int reviewCount = 10,
  int lapseCount = 1,
  DateTime? lastResetAt,
}) => CardHistoryHeader(
  flashcardId: 'c1',
  deckId: 'd1',
  deckName: 'TOPIK II — Vocab',
  breadcrumb: const <FolderBreadcrumbSegment>[
    FolderBreadcrumbSegment(id: 'f1', name: 'Korean'),
  ],
  front: '안녕하세요',
  back: 'Hello',
  boxNumber: 3,
  dueAt: DateTime.utc(2026, 6, 20),
  buriedUntil: null,
  isSuspended: false,
  reviewCount: reviewCount,
  lapseCount: lapseCount,
  correctStreak: 4,
  totalEvents: reviewCount,
  createdAt: DateTime.utc(2026, 5, 21),
  lastResetAt: lastResetAt,
);

CardHistoryAttempt _attempt(
  String id,
  DateTime at, {
  int boxBefore = 1,
  int boxAfter = 2,
  AttemptResult result = AttemptResult.perfect,
}) => CardHistoryAttempt(
  id: id,
  result: result,
  studyMode: StudyMode.review,
  boxBefore: boxBefore,
  boxAfter: boxAfter,
  attemptedAt: at,
  sessionId: 's_$id',
  sessionStatus: SessionStatus.completed,
);

Widget _wrap(_FakeCardHistoryRepository repo) => ProviderScope(
  overrides: [cardHistoryRepositoryProvider.overrideWith((ref) => repo)],
  child: MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const CardHistoryScreen(deckId: 'd1', flashcardId: 'c1'),
  ),
);

/// Card History is a tall screen (header + progress + timeline). Use a
/// device-sized surface so SliverFillRemaining empty/error states aren't
/// squeezed by the default 800×600 test window.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Loading — shows skeleton while header pending', (
    WidgetTester tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      _wrap(_FakeCardHistoryRepository(headerPending: true)),
    );
    await tester.pump();
    expect(find.byType(MxLoadingState), findsWidgets);
  });

  testWidgets('H1 — data renders header and timeline rows newest-first', (
    WidgetTester tester,
  ) async {
    final repo = _FakeCardHistoryRepository(
      headerResult: Result<CardHistoryHeader>.ok(_header()),
      pageResult: Result<CardHistoryPage>.ok(
        CardHistoryPage(
          attempts: <CardHistoryAttempt>[
            _attempt('a2', DateTime.utc(2026, 6, 12)),
            _attempt('a1', DateTime.utc(2026, 6, 10)),
          ],
          nextCursor: null,
        ),
      ),
    );
    _useTallSurface(tester);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('안녕하세요'), findsOneWidget);
    expect(find.byType(CardHistoryTimelineRow), findsNWidgets(2));
  });

  testWidgets('H2 — empty state with Start study CTA when no attempts', (
    WidgetTester tester,
  ) async {
    final repo = _FakeCardHistoryRepository(
      headerResult: Result<CardHistoryHeader>.ok(
        _header(reviewCount: 0, lapseCount: 0),
      ),
      pageResult: const Result<CardHistoryPage>.ok(
        CardHistoryPage(attempts: <CardHistoryAttempt>[], nextCursor: null),
      ),
    );
    _useTallSurface(tester);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(MxEmptyState)),
    );
    expect(find.byType(MxEmptyState), findsOneWidget);
    expect(find.text(l10n.cardHistoryEmptyAction), findsOneWidget);
  });

  testWidgets('H5 — reset divider sits between newer and older attempts', (
    WidgetTester tester,
  ) async {
    final repo = _FakeCardHistoryRepository(
      headerResult: Result<CardHistoryHeader>.ok(
        _header(lastResetAt: DateTime.utc(2026, 6, 11)),
      ),
      pageResult: Result<CardHistoryPage>.ok(
        CardHistoryPage(
          attempts: <CardHistoryAttempt>[
            _attempt('a2', DateTime.utc(2026, 6, 12)),
            _attempt('a1', DateTime.utc(2026, 6, 10)),
          ],
          nextCursor: null,
        ),
      ),
    );
    _useTallSurface(tester);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byType(CardHistoryResetDivider), findsOneWidget);
  });

  testWidgets('H6 — pre-migration box (0) renders as dash', (
    WidgetTester tester,
  ) async {
    final repo = _FakeCardHistoryRepository(
      headerResult: Result<CardHistoryHeader>.ok(_header()),
      pageResult: Result<CardHistoryPage>.ok(
        CardHistoryPage(
          attempts: <CardHistoryAttempt>[
            _attempt(
              'a1',
              DateTime.utc(2026, 6, 10),
              boxBefore: 0,
              boxAfter: 0,
            ),
          ],
          nextCursor: null,
        ),
      ),
    );
    _useTallSurface(tester);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('—'), findsWidgets);
  });

  testWidgets('H7 — header sub-label shown when last_reset_at set', (
    WidgetTester tester,
  ) async {
    final repo = _FakeCardHistoryRepository(
      headerResult: Result<CardHistoryHeader>.ok(
        _header(lastResetAt: DateTime.utc(2026, 4, 12)),
      ),
    );
    _useTallSurface(tester);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.textContaining('2026-04-12'), findsWidgets);
  });

  testWidgets('Error — storage failure shows retryable error state', (
    WidgetTester tester,
  ) async {
    final repo = _FakeCardHistoryRepository(
      headerResult: const Result<CardHistoryHeader>.err(
        Failure.storage(operation: StorageOp.read, cause: 'boom'),
      ),
    );
    _useTallSurface(tester);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(MxErrorState)),
    );
    expect(find.text(l10n.cardHistoryErrorTitle), findsOneWidget);
    expect(find.text(l10n.commonRetry), findsOneWidget);
  });

  testWidgets('Card not found — shows not-found state, no retry', (
    WidgetTester tester,
  ) async {
    final repo = _FakeCardHistoryRepository(
      headerResult: const Result<CardHistoryHeader>.err(
        Failure.notFound(entity: 'flashcard', id: 'c1'),
      ),
    );
    _useTallSurface(tester);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(MxErrorState)),
    );
    expect(find.text(l10n.cardHistoryNotFoundTitle), findsOneWidget);
    expect(find.text(l10n.commonRetry), findsNothing);
  });
}
