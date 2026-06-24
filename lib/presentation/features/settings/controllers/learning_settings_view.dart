import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/learning_settings.dart';

part 'learning_settings_view.freezed.dart';

/// The Learning-settings screen view-state (kit screen 22): the persisted
/// [LearningSettings] plus a transient [saving] flag (the kit "saving" state's
/// busy overlay while a write is in flight).
@freezed
sealed class LearningSettingsView with _$LearningSettingsView {
  const factory LearningSettingsView({
    required LearningSettings settings,
    @Default(false) bool saving,
  }) = _LearningSettingsView;
  const LearningSettingsView._();

  /// The daily goal is on when no "disabled since" date is stored.
  bool get goalEnabled => settings.goalDisabledSince == null;
}
