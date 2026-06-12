import 'dart:math' as math;

import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/study/guess/guess_option.dart';

/// Builds the 5-option Guess-mode selection deterministically.
final class GuessOptionBuilder {
  const GuessOptionBuilder._();

  static const int maxOptionCount = 5;
  static const int maxDecoyCount = maxOptionCount - 1;

  static bool canBuild({
    required Flashcard current,
    required Iterable<Flashcard> scopeCards,
  }) =>
      _validDecoyCount(current: current, scopeCards: scopeCards) >=
      maxDecoyCount;

  static List<GuessOption> build({
    required String sessionId,
    required Flashcard current,
    required Iterable<Flashcard> scopeCards,
  }) {
    if (!canBuild(current: current, scopeCards: scopeCards)) {
      throw UnsupportedError(
        'Guess mode requires at least 4 valid unique decoys.',
      );
    }

    final Map<String, Flashcard> uniqueDecoysByBack = _uniqueDecoysByBack(
      current: current,
      scopeCards: scopeCards,
    );
    final String seedKey = '$sessionId|${current.id}';
    final List<Flashcard> decoys = uniqueDecoysByBack.values.toList()
      ..sort(
        (Flashcard left, Flashcard right) =>
            _compareBySeed(seedKey, left, right),
      );

    final List<GuessOption> options = <GuessOption>[
      GuessOption(
        flashcard: current,
        title: _displayText(current.back),
        description: _buildDescription(current),
        isCorrect: true,
      ),
      ...decoys
          .take(maxDecoyCount)
          .map(
            (Flashcard card) => GuessOption(
              flashcard: card,
              title: _displayText(card.back),
              description: _buildDescription(card),
              isCorrect: false,
            ),
          ),
    ];

    options.sort(
      (GuessOption left, GuessOption right) =>
          _compareBySeed(seedKey, left.flashcard, right.flashcard),
    );
    return options;
  }

  static Map<String, Flashcard> _uniqueDecoysByBack({
    required Flashcard current,
    required Iterable<Flashcard> scopeCards,
  }) {
    final String currentBackKey = _normalizedKey(current.back);
    final Map<String, Flashcard> uniqueDecoysByBack = <String, Flashcard>{};
    for (final Flashcard card in scopeCards) {
      if (card.id == current.id) {
        continue;
      }

      final String backKey = _normalizedKey(card.back);
      if (backKey.isEmpty || backKey == currentBackKey) {
        continue;
      }

      uniqueDecoysByBack.putIfAbsent(backKey, () => card);
    }
    return uniqueDecoysByBack;
  }

  static int _validDecoyCount({
    required Flashcard current,
    required Iterable<Flashcard> scopeCards,
  }) => _uniqueDecoysByBack(current: current, scopeCards: scopeCards).length;

  static int _compareBySeed(String seedKey, Flashcard left, Flashcard right) {
    final int leftScore = _stableHash('$seedKey|${left.id}');
    final int rightScore = _stableHash('$seedKey|${right.id}');
    if (leftScore != rightScore) {
      return leftScore.compareTo(rightScore);
    }
    return left.id.compareTo(right.id);
  }

  static String _normalizedKey(String value) => StringUtils.normalize(value);

  static String _displayText(String value) =>
      _collapseWhitespace(StringUtils.trimmed(value));

  static String _buildDescription(Flashcard card) {
    final String source = _firstNonEmpty(<String?>[
      card.hint,
      card.exampleSentence,
      card.back,
    ]);
    return _truncate(_collapseWhitespace(source), 96);
  }

  static String _firstNonEmpty(Iterable<String?> values) {
    for (final String? value in values) {
      final String trimmed = StringUtils.trimmed(value ?? '');
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return '';
  }

  static String _collapseWhitespace(String value) =>
      StringUtils.trimmed(value.replaceAll(RegExp(r'\s+'), ' '));

  static String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, math.max(0, maxLength - 3)).trimRight()}...';
  }

  static int _stableHash(String value) {
    const int fnvOffset = 0x811C9DC5;
    const int fnvPrime = 0x01000193;
    int hash = fnvOffset;
    for (final int unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0x7fffffff;
    }
    return hash;
  }
}
