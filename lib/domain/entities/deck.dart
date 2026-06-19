import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

part 'deck.freezed.dart';

/// A deck of flashcards owned by exactly one folder.
///
/// Every deck is folder-owned: [folderId] is non-null and references a folder
/// whose `content_mode` allows decks (root-level decks are Rejected / Out of
/// Scope). [targetLanguage] declares the front-field language and gates TTS. See
/// `docs/business/deck/deck-management.md` and the `decks` table in
/// `docs/database/schema-contract.md`.
///
/// Timestamps are UTC epoch milliseconds (as persisted); the mapper converts to
/// [DateTime] at the data boundary.
@freezed
sealed class Deck with _$Deck {
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
