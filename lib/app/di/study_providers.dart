import 'dart:async';

import 'package:memox/app/di/database_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_parser.dart';
import 'package:memox/domain/study/study_entry_route_input.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/study/usecases/study_usecases.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_providers.g.dart';

@Riverpod(keepAlive: true)
StudySessionDao studySessionDao(Ref ref) =>
    StudySessionDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
StudyRepository studyRepository(Ref ref) =>
    StudyRepositoryImpl(ref.watch(studySessionDaoProvider));

@Riverpod(keepAlive: true)
StartStudySessionUseCase startStudySessionUseCase(Ref ref) =>
    StartStudySessionUseCase(ref.watch(studyRepositoryProvider));

@Riverpod(keepAlive: true)
LoadStudySessionReviewUseCase loadStudySessionReviewUseCase(Ref ref) =>
    LoadStudySessionReviewUseCase(ref.watch(studyRepositoryProvider));

@Riverpod(keepAlive: true)
LoadStudySessionResultUseCase loadStudySessionResultUseCase(Ref ref) =>
    LoadStudySessionResultUseCase(ref.watch(studyRepositoryProvider));

@Riverpod(keepAlive: true)
RecordStudySessionAnswerUseCase recordStudySessionAnswerUseCase(Ref ref) =>
    RecordStudySessionAnswerUseCase(ref.watch(studyRepositoryProvider));

@Riverpod(keepAlive: true)
LoadDashboardResumeSessionSummaryUseCase
loadDashboardResumeSessionSummaryUseCase(Ref ref) =>
    LoadDashboardResumeSessionSummaryUseCase(
      ref.watch(studyRepositoryProvider),
    );

@Riverpod(keepAlive: true)
FinalizeStudySessionUseCase finalizeStudySessionUseCase(Ref ref) =>
    FinalizeStudySessionUseCase(ref.watch(studyRepositoryProvider));

@Riverpod(keepAlive: true)
CancelStudySessionUseCase cancelStudySessionUseCase(Ref ref) =>
    CancelStudySessionUseCase(ref.watch(studyRepositoryProvider));

@riverpod
Future<StudyEntryStartResult> studyEntry(
  Ref ref,
  StudyEntryRouteInput input,
) async {
  await Future<void>.delayed(Duration.zero);

  final EntryType entryType = parseStudyEntryType(input.entryType);
  final String? entryRefId = normalizeStudyEntryRefId(
    entryType: entryType,
    entryRefId: input.entryRefId,
  );
  if (entryType != EntryType.today && entryRefId == null) {
    throw const FormatException('Study entryRefId is required.');
  }

  final StudyType studyType = resolveStudyType(
    entryType: entryType,
    studyTypeQuery: input.studyTypeQuery,
  );
  final StudyMode? mode = resolveStudyMode(input.modeQuery);
  final StudyScope scope = StudyScope(
    entryType: entryType,
    entryRefId: entryRefId,
    studyType: studyType,
  );

  final Result<StudyEntryStartResult> result = await ref
      .read(startStudySessionUseCaseProvider)
      .call(scope: scope, mode: mode);

  return switch (result) {
    Ok<StudyEntryStartResult>(:final value) => value,
    Err<StudyEntryStartResult>(:final failure) =>
      throw StudyEntryFailureException(failure),
  };
}

@riverpod
Future<StudySessionReview> studySessionReview(
  Ref ref,
  SessionId sessionId,
) async {
  final Result<StudySessionReview> result = await ref
      .read(loadStudySessionReviewUseCaseProvider)
      .call(sessionId: sessionId);

  return switch (result) {
    Ok<StudySessionReview>(:final value) => value,
    Err<StudySessionReview>(:final failure) =>
      throw StudySessionFailureException(failure),
  };
}

class StudySessionFailureException implements Exception {
  const StudySessionFailureException(this.failure);

  final Failure failure;
}
