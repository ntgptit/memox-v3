import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';

/// App-wide error observer (`docs/contracts/error-contract.md`).
///
/// Two always-on responsibilities, independent of Riverpod diagnostics:
///
/// * **Logging.** Every provider error — [providerDidFail] also fires for
///   `Future`/`Stream` errors — is routed to [AppLogger], so production
///   failures are never silently dropped (previously they were when
///   diagnostics were off).
/// * **User feedback for retained-data refetch failures.** When a provider that
///   was showing data transitions to an error (a background refetch failed),
///   the screen keeps its stale data and renders no error widget, so a snackbar
///   is the only signal. This generalizes what Library used to do inline to
///   every query screen.
///
/// First-load errors (`previous` = loading) are rendered full-screen by
/// `MxRetainedAsyncState` and intentionally skipped here. Mutation controllers
/// set loading before failing (so `previous` is never [AsyncData] on the error
/// transition) and stay handled inline at the call site — neither is
/// double-reported.
final class MxAppFeedbackObserver extends ProviderObserver {
  MxAppFeedbackObserver({required this.logger, required this.messengerKey});

  final AppLogger logger;
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    logger.error(
      'Provider failed: ${context.provider.name ?? context.provider.runtimeType}',
      error,
      stackTrace,
    );
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    // Only a retained-data → error transition (a background refetch failure)
    // warrants a snackbar; see class doc.
    if (previousValue is! AsyncData || newValue is! AsyncError) {
      return;
    }
    _showRefetchFailure(newValue.error);
  }

  void _showRefetchFailure(Object error) {
    final BuildContext? ctx = messengerKey.currentContext;
    if (ctx == null) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(ctx);
    final String message = error is Failure
        ? l10n.failureMessage(error)
        : l10n.errorUnexpected;
    // The transition fires mid-notification; defer so showing the snackbar
    // does not mutate the messenger during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ScaffoldMessengerState? messenger = messengerKey.currentState;
      final BuildContext? current = messengerKey.currentContext;
      if (messenger == null || current == null) {
        return;
      }
      showMxSnackbarOn(messenger, current, message: message, isError: true);
    });
  }
}
