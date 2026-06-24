import 'package:flutter/material.dart';
import 'package:memox/app/di/language_settings_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/types/app_language.dart';
import 'package:memox/domain/usecases/language_settings_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_controller.g.dart';

/// Drives the app's UI-language preference (kit screen 25 — Language). App-level
/// (`keepAlive`): `MemoXApp` watches it to drive `MaterialApp.locale`, and the
/// Language screen reads/sets it. Loads the persisted [AppLanguage], then updates
/// it (optimistically, reverting on a persist failure).
@Riverpod(keepAlive: true)
class LanguageController extends _$LanguageController {
  @override
  Future<AppLanguage> build() async {
    final LoadLanguageSettingsUseCase useCase = await ref.watch(
      loadLanguageSettingsUseCaseProvider.future,
    );
    final Result<AppLanguage> result = await useCase.call();
    final Failure? failure = result.failure;
    if (failure != null) {
      throw _LanguageException(failure);
    }
    return result.data ?? AppLanguage.system;
  }

  /// Selects [language], switching the app locale immediately and persisting it;
  /// reverts to the previous language on a persist failure.
  Future<void> setLanguage(AppLanguage language) async {
    // Inert while loading or in error (the screen shows those states, not the
    // picker) — never overwrite a non-loaded state with an optimistic value.
    final AppLanguage? previous = state.asData?.value;
    if (previous == null || language == previous) {
      return;
    }
    state = AsyncData<AppLanguage>(language);
    final UpdateLanguageSettingsUseCase useCase = await ref.read(
      updateLanguageSettingsUseCaseProvider.future,
    );
    final Result<void> result = await useCase.call(language: language);
    if (result.failure != null) {
      state = AsyncData<AppLanguage>(previous);
    }
  }
}

/// Maps the domain [AppLanguage] to a Flutter [Locale] (presentation only; the
/// domain stays Flutter-free). [AppLanguage.system] → `null` (follow device).
extension AppLanguageX on AppLanguage {
  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.english => const Locale('en'),
    AppLanguage.vietnamese => const Locale('vi'),
  };
}

/// Carries a domain [Failure] through `AsyncError` so the screen renders its
/// load-error state.
class _LanguageException implements Exception {
  const _LanguageException(this.failure);

  final Failure failure;

  @override
  String toString() => 'LanguageException($failure)';
}
