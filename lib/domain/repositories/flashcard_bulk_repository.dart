import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/bulk_delete_result.dart';
import 'package:memox/domain/types/ids.dart';

/// Flashcard batch mutation contract.
abstract interface class FlashcardBulkRepository {
  Future<Result<BulkDeleteResult>> deleteMany({required List<FlashcardId> ids});
}
