import 'package:memox/core/error/failure.dart';
import 'package:memox/core/utils/string_utils.dart';

/// Normalization + validation for flashcard tags.
///
/// Tags are trimmed, may not contain commas, and are capped at 50 characters
/// after trim. Leading `#` is treated as presentation sugar and stripped.
abstract final class TagValidator {
  TagValidator._();

  static const int maxLength = 50;

  static String displayValue(String value) {
    final String trimmed = StringUtils.trimmed(value);
    if (trimmed.startsWith('#')) {
      return StringUtils.trimmed(trimmed.substring(1));
    }
    return trimmed;
  }

  static String storageValue(String value) =>
      StringUtils.normalize(displayValue(value));

  static Failure? validate(String value) {
    final String normalized = displayValue(value);
    if (normalized.isEmpty) {
      return const Failure.validation(field: 'tag', code: ValidationCode.empty);
    }
    if (normalized.contains(',')) {
      return const Failure.validation(
        field: 'tag',
        code: ValidationCode.invalidCharacter,
      );
    }
    if (normalized.length > maxLength) {
      return const Failure.validation(
        field: 'tag',
        code: ValidationCode.tooLong,
      );
    }
    return null;
  }
}
