import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/study_entry_repository.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_scope.dart';

/// Resolves the ordered eligible flashcard ids for a study scope — the queue the
/// session-creation flow draws from (WBS 4.11.1).
///
/// Owns the `now` clock (epoch ms) and delegates to
/// [StudyEntryRepository.resolveEligibleCardIds]; suspended / currently-buried
/// cards are excluded in the repository query, and ordering is due-date for
/// `srs_review` / sort-order for `new_cards`. The `maxSessionItems` batch cap
/// (WBS 4.2.4) is applied by `CreateStudySessionUseCase` on this list's head.
class ResolveEligibleStudyCardsUseCase {
  const ResolveEligibleStudyCardsUseCase({required this.repository});

  final StudyEntryRepository repository;

  Future<Result<List<FlashcardId>>> call({required StudyScope scope}) =>
      repository.resolveEligibleCardIds(
        scope: scope,
        now: DateTime.now().millisecondsSinceEpoch,
      );
}
