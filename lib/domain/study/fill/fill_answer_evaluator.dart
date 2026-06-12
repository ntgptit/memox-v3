import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/types/attempt_result.dart';

/// Pure Fill answer evaluator.
///
/// Conservative availability length uses code-point count because the project
/// does not currently ship a grapheme utility without adding a dependency.
abstract final class FillAnswerEvaluator {
  FillAnswerEvaluator._();

  static FillAnswerEvaluation evaluate({
    required String typedInput,
    required String expectedFront,
    required bool hintUsed,
    bool overrideApplied = false,
  }) {
    final String trimmedTypedInput = StringUtils.trimmed(typedInput);
    final String trimmedExpectedFront = StringUtils.trimmed(expectedFront);
    final bool exactMatch = trimmedTypedInput == trimmedExpectedFront;

    final AttemptResult result = overrideApplied
        ? AttemptResult.recovered
        : exactMatch
        ? (hintUsed ? AttemptResult.recovered : AttemptResult.perfect)
        : AttemptResult.forgot;

    return FillAnswerEvaluation(
      result: result,
      isExactMatch: exactMatch,
      hintUsed: hintUsed,
      overrideApplied: overrideApplied,
    );
  }

  static bool isAvailable(String front) {
    final String trimmedFront = StringUtils.trimmed(front);
    if (_codePointCount(trimmedFront) < 3) {
      return false;
    }
    return _containsNonAsciiLetter(trimmedFront);
  }

  static int _codePointCount(String value) => value.runes.length;

  static bool _containsNonAsciiLetter(String value) =>
      value.runes.any((int rune) => !_isAsciiDigitOrSymbol(rune));

  static bool _isAsciiDigitOrSymbol(int rune) =>
      (rune >= 0x30 && rune <= 0x39) ||
      (rune >= 0x21 && rune <= 0x2F) ||
      (rune >= 0x3A && rune <= 0x40) ||
      (rune >= 0x5B && rune <= 0x60) ||
      (rune >= 0x7B && rune <= 0x7E) ||
      rune == 0x20;
}

/// Result metadata for Fill answer evaluation.
final class FillAnswerEvaluation {
  const FillAnswerEvaluation({
    required this.result,
    required this.isExactMatch,
    required this.hintUsed,
    required this.overrideApplied,
  });

  final AttemptResult result;
  final bool isExactMatch;
  final bool hintUsed;
  final bool overrideApplied;
}
