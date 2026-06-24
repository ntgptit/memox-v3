import 'package:memox/app/di/learning_settings_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/usecases/learning_settings_usecases.dart';
import 'package:memox/presentation/features/settings/controllers/learning_settings_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'learning_settings_controller.g.dart';

/// Drives the Learning-settings screen (kit screen 22): loads the persisted
/// [LearningSettings], then toggles the daily goal and updates the daily new-card
/// limit, persisting each change through `UpdateLearningSettingsUseCase`. The
/// reminder card is a Future affordance (no reminder BE / notification scheduling
/// yet — `docs/wireframes/20-settings-learning.md` §status), so this controller
/// owns only the daily-goal state.
@riverpod
class LearningSettingsController extends _$LearningSettingsController {
  @override
  Future<LearningSettingsView> build() async {
    final LoadLearningSettingsUseCase useCase = await ref.watch(
      loadLearningSettingsUseCaseProvider.future,
    );
    final Result<LearningSettings> result = await useCase.call();
    final Failure? failure = result.failure;
    if (failure != null) {
      // Surface the load failure as AsyncError (the error state) rather than
      // masking it with defaults — masking would let a later save overwrite the
      // real persisted value with the default.
      throw _LearningSettingsException(failure);
    }
    // failure == null ⇒ data is non-null by the Result contract; the default
    // only guards a contract violation (it never masks a real failure).
    return LearningSettingsView(
      settings: result.data ?? const LearningSettings(),
    );
  }

  /// Turns the daily goal on (clears `goalDisabledSince`) or off (stamps it).
  Future<void> setGoalEnabled(bool enabled) {
    final LearningSettingsView? current = state.asData?.value;
    if (current == null) {
      return Future<void>.value();
    }
    // freezed copyWith cannot clear a nullable field, so rebuild when enabling.
    final LearningSettings next = enabled
        ? LearningSettings(dailyNewLimit: current.settings.dailyNewLimit)
        : current.settings.copyWith(goalDisabledSince: DateTime.now());
    return _persist(current, next);
  }

  /// Updates the daily new-card limit (must be a valid 5..200 step-5 value).
  Future<void> setDailyLimit(int limit) {
    final LearningSettingsView? current = state.asData?.value;
    if (current == null || !LearningSettings.isValidDailyNewLimit(limit)) {
      return Future<void>.value();
    }
    return _persist(current, current.settings.copyWith(dailyNewLimit: limit));
  }

  // Optimistic update: each call captures its own [current] snapshot, so a
  // failed revert restores from that snapshot (last-write-wins for overlapping
  // calls — an already-succeeded earlier change is not undone).
  Future<void> _persist(
    LearningSettingsView current,
    LearningSettings next,
  ) async {
    state = AsyncData<LearningSettingsView>(
      current.copyWith(settings: next, saving: true),
    );
    final UpdateLearningSettingsUseCase useCase = await ref.read(
      updateLearningSettingsUseCaseProvider.future,
    );
    final Result<void> result = await useCase.call(settings: next);
    // On failure, revert to the pre-change settings; on success, keep the change.
    state = AsyncData<LearningSettingsView>(
      result.failure != null
          ? current.copyWith(saving: false)
          : LearningSettingsView(settings: next),
    );
  }
}

/// Carries a domain [Failure] through `AsyncError` so the screen renders its
/// load-error state (mirrors the study-entry controller pattern).
class _LearningSettingsException implements Exception {
  const _LearningSettingsException(this.failure);

  final Failure failure;

  @override
  String toString() => 'LearningSettingsException($failure)';
}
