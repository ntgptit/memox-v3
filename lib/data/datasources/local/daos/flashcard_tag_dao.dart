import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'flashcard_tag_dao.g.dart';

/// Thin Drift accessor for tag-management operations over `flashcard_tags`.
///
/// Single-table reads/mutations only — validation and normalization live in the
/// domain layer (`TagValidator`); collision policy and merge orchestration in
/// `TagRepositoryImpl`. Tags are stored lowercased, so equality comparisons are
/// already case-insensitive (`docs/database/drift-guide.md`).
@DriftAccessor(include: <String>{'../drift/tag_queries.drift'})
class FlashcardTagDao extends DatabaseAccessor<AppDatabase>
    with _$FlashcardTagDaoMixin {
  FlashcardTagDao(super.db);

  /// Live stream of distinct tags with their card counts (count desc, name asc).
  Stream<List<TagsWithCountResult>> watchTagsWithCount() =>
      tagsWithCount().watch();

  /// Whether any row carries [normalizedName] (tags are stored lowercased).
  Future<bool> tagExists(String normalizedName) async {
    final Expression<int> count = flashcardTags.tag.count();
    final TypedResult row =
        await (selectOnly(flashcardTags)
              ..addColumns(<Expression<Object>>[count])
              ..where(flashcardTags.tag.equals(normalizedName)))
            .getSingle();
    return (row.read(count) ?? 0) > 0;
  }

  /// Number of cards carrying [normalizedName].
  Future<int> countCardsWithTag(String normalizedName) async {
    final Expression<int> count = flashcardTags.flashcardId.count();
    final TypedResult row =
        await (selectOnly(flashcardTags)
              ..addColumns(<Expression<Object>>[count])
              ..where(flashcardTags.tag.equals(normalizedName)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  /// Rewrite every [oldName] row to [newName]. Safe only when [newName] does not
  /// already exist (the repository enforces that to avoid a PK collision).
  Future<int> renameTag(String oldName, String newName) =>
      (update(flashcardTags)..where((FlashcardTags t) => t.tag.equals(oldName)))
          .write(FlashcardTagsCompanion(tag: Value(newName)));

  /// Copy [source] rows onto [destination] for cards that lack it (the
  /// `INSERT OR IGNORE` handles per-card de-dup), then drop the source rows.
  /// Runs in one transaction.
  Future<void> mergeTag(String source, String destination) =>
      transaction(() async {
        await customStatement(
          'INSERT OR IGNORE INTO flashcard_tags (flashcard_id, tag) '
          'SELECT flashcard_id, ? FROM flashcard_tags WHERE tag = ?',
          <Object?>[destination, source],
        );
        await (delete(
          flashcardTags,
        )..where((FlashcardTags t) => t.tag.equals(source))).go();
      });

  /// Delete every row carrying [normalizedName]. Returns rows removed.
  Future<int> deleteTag(String normalizedName) => (delete(
    flashcardTags,
  )..where((FlashcardTags t) => t.tag.equals(normalizedName))).go();
}
