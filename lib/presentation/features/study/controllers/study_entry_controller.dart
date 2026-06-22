import 'package:memox/app/di/study_entry_providers.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/presentation/features/study/controllers/study_entry_outcome.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_entry_controller.g.dart';

/// Drives the study entry gate (WBS 4.1.2 / 4.2.2) for one [StudyScope].
///
/// `build` resolves the controlled start outcome (`ResolveStudyEntryStartUseCase`,
/// no silent resume): a resumable session → [StudyEntryOutcome.resumeRequired];
/// an empty scope → [StudyEntryOutcome.blocked]; an eligible scope is
/// **auto-created** into a session → [StudyEntryOutcome.ready] (the screen
/// `pushReplacement`s to it). [startOver] discards a resumable session and
/// creates a fresh one. Errors surface as `AsyncError`; preparing is
/// `AsyncLoading`.
@riverpod
class StudyEntryController extends _$StudyEntryController {
  @override
  Future<StudyEntryOutcome> build(StudyScope scope) async {
    final Result<StudyEntryStartResult> start = await ref
        .read(resolveStudyEntryStartUseCaseProvider)
        .call(scope: scope);
    final StudyEntryStartResult? result = start.data;
    if (result == null) {
      throw _StudyEntryException(start.failure);
    }
    return switch (result) {
      StudyEntryResumeRequired(:final StudySession session) =>
        StudyEntryOutcome.resumeRequired(session),
      StudyEntryBlocked(:final reason, :final nextDueAt) =>
        StudyEntryOutcome.blocked(reason, nextDueAt: nextDueAt),
      // Eligible scope: create the session now and hand the gate the id to
      // navigate to (the gate is transient — it never stays in the stack).
      StudyEntryCanStart() => await _createSession(),
    };
  }

  /// Resolves the eligible queue and creates a session, returning [ready].
  Future<StudyEntryOutcome> _createSession() async {
    final Result<List<FlashcardId>> cards = await ref
        .read(resolveEligibleStudyCardsUseCaseProvider)
        .call(scope: scope);
    final List<FlashcardId>? ids = cards.data;
    if (ids == null) {
      throw _StudyEntryException(cards.failure);
    }
    final Result<StudySession> created = await ref
        .read(createStudySessionUseCaseProvider)
        .call(scope: scope, flashcardIds: ids);
    final StudySession? session = created.data;
    if (session == null) {
      throw _StudyEntryException(created.failure);
    }
    return StudyEntryOutcome.ready(session.id);
  }

  /// Discard the resumable session for this scope and start a fresh one
  /// (decision row S28 "Start over"). Cancels [session], then creates anew.
  ///
  /// Only invoked from the `resumeRequired` surface (the gate has NOT navigated
  /// away yet, so this provider is still alive). On success the new `ready`
  /// emission drives the gate's `pushReplacement`. (This provider is
  /// autoDispose; were it called after navigation, Riverpod would drop the
  /// post-dispose `state =` write — not a path WP-SR1a can reach.)
  Future<void> startOver(StudySession session) async {
    state = const AsyncValue<StudyEntryOutcome>.loading();
    state = await AsyncValue.guard<StudyEntryOutcome>(() async {
      final Result<void> cancelled = await ref
          .read(cancelStudySessionUseCaseProvider)
          .call(id: session.id);
      if (cancelled.failure != null) {
        throw _StudyEntryException(cancelled.failure);
      }
      return _createSession();
    });
  }
}

/// Carries a domain [Failure] through `AsyncError` so the gate can render it.
class _StudyEntryException implements Exception {
  const _StudyEntryException(this.failure);

  final Failure? failure;
}
