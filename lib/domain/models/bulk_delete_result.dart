/// Result payload for transactional bulk flashcard deletion.
class BulkDeleteResult {
  const BulkDeleteResult({
    required this.deletedCount,
    required this.skippedCount,
  });

  final int deletedCount;
  final int skippedCount;
}
