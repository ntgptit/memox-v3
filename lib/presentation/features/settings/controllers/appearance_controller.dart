import 'package:flutter/material.dart';
import 'package:memox/app/di/appearance_settings_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/types/app_theme_mode.dart';
import 'package:memox/domain/usecases/appearance_settings_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appearance_controller.g.dart';

/// Drives the app's theme preference (kit screen 24 — Appearance). App-level
/// (`keepAlive`): `MemoXApp` watches it to drive `MaterialApp.themeMode`, and the
/// Appearance screen reads/sets it. Loads the persisted [AppThemeMode], then
/// updates it (optimistically, reverting on a persist failure).
@Riverpod(keepAlive: true)
class AppearanceController extends _$AppearanceController {
  @override
  Future<AppThemeMode> build() async {
    final LoadAppearanceSettingsUseCase useCase = await ref.watch(
      loadAppearanceSettingsUseCaseProvider.future,
    );
    final Result<AppThemeMode> result = await useCase.call();
    final Failure? failure = result.failure;
    if (failure != null) {
      throw _AppearanceException(failure);
    }
    return result.data ?? AppThemeMode.system;
  }

  /// Selects [mode], updating the app theme immediately and persisting it;
  /// reverts to the previous mode on a persist failure.
  Future<void> setMode(AppThemeMode mode) async {
    // Inert while loading or in error (the screen shows those states, not the
    // picker) — never overwrite a non-loaded state with an optimistic value.
    final AppThemeMode? previous = state.asData?.value;
    if (previous == null || mode == previous) {
      return;
    }
    state = AsyncData<AppThemeMode>(mode);
    final UpdateAppearanceSettingsUseCase useCase = await ref.read(
      updateAppearanceSettingsUseCaseProvider.future,
    );
    final Result<void> result = await useCase.call(mode: mode);
    if (result.failure != null) {
      state = AsyncData<AppThemeMode>(previous);
    }
  }
}

/// Maps the domain [AppThemeMode] to Flutter's [ThemeMode] (presentation only;
/// the domain stays Flutter-free).
extension AppThemeModeX on AppThemeMode {
  ThemeMode get materialThemeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

/// Carries a domain [Failure] through `AsyncError` so the screen renders its
/// load-error state.
class _AppearanceException implements Exception {
  const _AppearanceException(this.failure);

  final Failure failure;

  @override
  String toString() => 'AppearanceException($failure)';
}
