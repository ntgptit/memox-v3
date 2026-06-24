import 'package:memox/app/di/card_history_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_history_viewmodel.g.dart';

/// Loads the Card History read model for [flashcardId] (kit screen 09; WBS 7.6.3).
/// Failure stays in-band in the [Result] so the screen renders the error state;
/// refresh by invalidating this provider.
@riverpod
Future<Result<CardHistory>> cardHistory(Ref ref, String flashcardId) =>
    ref.watch(getCardHistoryUseCaseProvider).call(flashcardId: flashcardId);
