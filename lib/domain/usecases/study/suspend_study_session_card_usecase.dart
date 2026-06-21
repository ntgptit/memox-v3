import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Suspends a card from the active study session indefinitely (WBS 4.11.2).
///
/// Owns the `now` clock and delegates to
/// [StudyRepository.suspendStudySessionCard]: the card's `is_suspended` is set
/// true, its queue item is removed, and the session's `updated_at` is touched —
/// no attempt is recorded and SRS box/due/counters are preserved
/// (`docs/contracts/usecase-contracts/study.md`
/// §SuspendStudySessionCardUseCase). A non-`in_progress` session or an
/// already-answered/absent card fails with `UnsupportedActionFailure` /
/// `NotFoundFailure`.
class SuspendStudySessionCardUseCase {
  const SuspendStudySessionCardUseCase({required this.repository});

  final StudyRepository repository;

  Future<Result<void>> call({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) => repository.suspendStudySessionCard(
    sessionId: sessionId,
    flashcardId: flashcardId,
    now: DateTime.now().millisecondsSinceEpoch,
  );
}
