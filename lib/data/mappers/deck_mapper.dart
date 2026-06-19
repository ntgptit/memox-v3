import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/types/target_language.dart';

/// Maps between the Drift `DeckRow` and the domain [Deck] entity.
///
/// Storage conventions (`docs/database/schema-contract.md`): `target_language`
/// is the lowercase enum name; timestamps are UTC epoch milliseconds.
/// Repositories MUST map rows through here and never leak `DeckRow` past the
/// data layer (`docs/contracts/repository-contracts/deck-repository.md`
/// §Forbidden).
abstract final class DeckMapper {
  const DeckMapper._();

  static Deck fromRow(DeckRow row) => Deck(
    id: row.id,
    folderId: row.folderId,
    name: row.name,
    targetLanguage: targetLanguageFromStorage(row.targetLanguage),
    sortOrder: row.sortOrder,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt, isUtc: true),
  );

  static TargetLanguage targetLanguageFromStorage(String value) =>
      switch (value) {
        'korean' => TargetLanguage.korean,
        'english' => TargetLanguage.english,
        'unsupported' => TargetLanguage.unsupported,
        _ => throw ArgumentError.value(
          value,
          'target_language',
          'Unknown TargetLanguage',
        ),
      };

  static String targetLanguageToStorage(TargetLanguage language) =>
      language.name;
}
