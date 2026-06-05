import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

part 'deck.freezed.dart';

/// A deck of flashcards (`docs/business/deck/deck-management.md`).
///
/// Every deck belongs to exactly one folder ([folderId] is non-null — the
/// folder-owned-deck invariant). [targetLanguage] gates TTS.
@freezed
abstract class Deck with _$Deck {
  const factory Deck({
    required DeckId id,
    required FolderId folderId,
    required String name,
    required TargetLanguage targetLanguage,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Deck;
}
