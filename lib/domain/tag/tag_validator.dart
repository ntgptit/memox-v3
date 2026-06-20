import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';

/// Pure validator/normalizer for a tag name. The single boundary where tag
/// input is checked and lowercased before it reaches storage
/// (`docs/contracts/usecase-contracts/tag.md` §TagValidator). Tags are
/// case-insensitive, comma-free, and at most [maxLength] chars after trim.
abstract final class TagValidator {
  const TagValidator._();

  /// Maximum tag length after trimming.
  static const int maxLength = 50;

  /// Validate [input] and return its normalized (trimmed, lowercased) form.
  ///
  /// Rejects (preserving the offending field as `tag`):
  /// - empty after trim → [ValidationCode.empty];
  /// - containing a comma → [ValidationCode.invalidCharacter];
  /// - longer than [maxLength] after trim → [ValidationCode.tooLong].
  static Result<String> validate(String input) {
    // Normalized form (trim + lowercase) is the stored identity; the empty,
    // comma, and length checks are all case-insensitive so they hold on it.
    final String normalized = StringUtils.normalizeTag(input);
    if (normalized.isEmpty) {
      return _fail(ValidationCode.empty);
    }
    if (normalized.contains(',')) {
      return _fail(ValidationCode.invalidCharacter);
    }
    if (normalized.length > maxLength) {
      return _fail(ValidationCode.tooLong);
    }
    return (failure: null, data: normalized);
  }

  static Result<String> _fail(ValidationCode code) =>
      (failure: Failure.validation(field: 'tag', code: code), data: null);
}
