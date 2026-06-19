import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_duplicate_check_result.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Manual duplicate **soft-warning** check (WBS 2.20.1). Non-blocking: the
/// editor calls this before save to decide whether to show a "save anyway?"
/// confirm. It never rejects the save — the create/update proceeds regardless.
///
/// A card is a duplicate when its trimmed, case-insensitive `front` + `back`
/// matches an existing card in the same deck (excluding the card itself on
/// edit via [excludeId]). Detection logic lives in
/// [FlashcardRepository.checkManualDuplicate].
///
/// Contract: `docs/contracts/usecase-contracts/flashcard.md`
/// §CheckManualDuplicateFlashcardUseCase. Decision row C40.
class CheckManualDuplicateFlashcardUseCase {
  const CheckManualDuplicateFlashcardUseCase({required this.repository});

  final FlashcardRepository repository;

  Future<Result<FlashcardDuplicateCheckResult>> call({
    required DeckId deckId,
    required String front,
    required String back,
    FlashcardId? excludeId,
  }) => repository.checkManualDuplicate(
    deckId: deckId,
    front: front,
    back: back,
    excludeId: excludeId,
  );
}
