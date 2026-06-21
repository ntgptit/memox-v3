import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Buries a card in the active study session until tomorrow (WBS 4.11.2).
///
/// Owns the `now` clock and delegates to
/// [StudyRepository.buryStudySessionCard]: the card's `buried_until` is set to
/// tomorrow's local midnight + 1 second, its queue item is removed, and the
/// session's `updated_at` is touched — no attempt is recorded and SRS box/due/
/// counters are preserved (`docs/contracts/usecase-contracts/study.md`
/// §BuryStudySessionCardUseCase). A non-`in_progress` session or an
/// already-answered/absent card fails with `UnsupportedActionFailure` /
/// `NotFoundFailure`.
class BuryStudySessionCardUseCase {
  const BuryStudySessionCardUseCase({required this.repository});

  final StudyRepository repository;

  Future<Result<void>> call({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) => repository.buryStudySessionCard(
    sessionId: sessionId,
    flashcardId: flashcardId,
    now: DateTime.now().millisecondsSinceEpoch,
  );
}
