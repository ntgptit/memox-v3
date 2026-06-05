import 'package:drift/drift.dart' show QueryRow;

import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/types/target_language.dart';

/// Maps Drift rows to deck domain types
/// (`docs/contracts/repository-contracts/deck-repository.md`).
abstract final class DeckMapper {
  DeckMapper._();

  static TargetLanguage targetLanguageFromStorage(String value) =>
      switch (value) {
        'english' => TargetLanguage.english,
        'unsupported' => TargetLanguage.unsupported,
        _ => TargetLanguage.korean,
      };

  /// Enum name matches storage form (`korean` / `english` / `unsupported`).
  static String targetLanguageToStorage(TargetLanguage language) =>
      language.name;

  static DateTime _dateFromMs(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  static Deck fromRow(DeckRow row) => Deck(
    id: row.id,
    folderId: row.folderId,
    name: row.name,
    targetLanguage: targetLanguageFromStorage(row.targetLanguage),
    sortOrder: row.sortOrder,
    createdAt: _dateFromMs(row.createdAt),
    updatedAt: _dateFromMs(row.updatedAt),
  );

  /// Builds a [DeckWithCount] from a folder-detail deck query row.
  static DeckWithCount deckWithCountFromQueryRow(QueryRow row) => DeckWithCount(
    deck: Deck(
      id: row.read<String>('id'),
      folderId: row.read<String>('folder_id'),
      name: row.read<String>('name'),
      targetLanguage: targetLanguageFromStorage(row.read<String>('target_language')),
      sortOrder: row.read<int>('sort_order'),
      createdAt: _dateFromMs(row.read<int>('created_at')),
      updatedAt: _dateFromMs(row.read<int>('updated_at')),
    ),
    cardCount: row.read<int>('card_count'),
    dueCount: row.read<int>('due_count'),
  );
}
