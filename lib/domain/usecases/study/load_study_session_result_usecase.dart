import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Loads a session's result summary — header + ordered, flashcard-joined items
/// with their terminal outcomes and aggregate counts (WBS 4.7.1).
///
/// Thin delegation to [StudyRepository.loadStudySessionResult]; the result
/// screen (WBS 4.7.2) reads total / answered / forgot / passed off the returned
/// [StudySessionResult] getters. A missing session is a `NotFoundFailure`; an
/// item-less session is a controlled `ValidationFailure`
/// (`docs/contracts/usecase-contracts/study.md` §LoadStudySessionResultUseCase).
class LoadStudySessionResultUseCase {
  const LoadStudySessionResultUseCase({required this.repository});

  final StudyRepository repository;

  Future<Result<StudySessionResult>> call({required SessionId sessionId}) =>
      repository.loadStudySessionResult(id: sessionId);
}
