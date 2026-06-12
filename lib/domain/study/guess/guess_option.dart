import 'package:memox/domain/entities/flashcard.dart';

/// One deterministic guess option built from a real flashcard.
final class GuessOption {
  const GuessOption({
    required this.flashcard,
    required this.title,
    required this.description,
    required this.isCorrect,
  });

  final Flashcard flashcard;
  final String title;
  final String description;
  final bool isCorrect;
}
