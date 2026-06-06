import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/feedback/app_messenger.dart';
import 'package:memox/app/feedback/mx_app_feedback_observer.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

final class _RecordingLogger implements AppLogger {
  Object? capturedError;
  String? capturedMessage;

  @override
  void error(String message, Object error, StackTrace stackTrace) {
    capturedMessage = message;
    capturedError = error;
  }
}

Widget _host(StreamProvider<int> provider, MxAppFeedbackObserver observer) =>
    ProviderScope(
      observers: <ProviderObserver>[observer],
      child: MaterialApp(
        scaffoldMessengerKey: appMessengerKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(
          builder: (BuildContext _, WidgetRef ref, Widget? _) {
            ref.watch(provider);
            return const Scaffold();
          },
        ),
      ),
    );

void main() {
  group('MxAppFeedbackObserver — logging', () {
    test('providerDidFail routes every provider error to the logger', () {
      final _RecordingLogger logger = _RecordingLogger();
      final ProviderContainer container = ProviderContainer(
        observers: <ProviderObserver>[
          MxAppFeedbackObserver(logger: logger, messengerKey: appMessengerKey),
        ],
      );
      addTearDown(container.dispose);

      final Provider<int> boom = Provider<int>(
        (Ref ref) => throw StateError('boom'),
        name: 'boomProvider',
      );

      expect(() => container.read(boom), throwsA(anything));
      expect(logger.capturedError, isNotNull);
      expect(logger.capturedError.toString(), contains('boom'));
      expect(logger.capturedMessage, contains('boomProvider'));
    });
  });

  group('MxAppFeedbackObserver — user feedback', () {
    testWidgets('retained-data refetch failure shows a snackbar', (
      WidgetTester tester,
    ) async {
      final StreamController<int> controller = StreamController<int>();
      addTearDown(controller.close);
      final StreamProvider<int> provider = StreamProvider<int>(
        (Ref ref) => controller.stream,
        name: 'retainedProvider',
      );

      await tester.pumpWidget(
        _host(
          provider,
          MxAppFeedbackObserver(
            logger: _RecordingLogger(),
            messengerKey: appMessengerKey,
          ),
        ),
      );

      controller.add(1); // AsyncData
      await tester.pump();
      controller.addError(StateError('refetch failed')); // AsyncError
      await tester.pump(); // schedules the post-frame snackbar
      await tester.pump(); // runs it
      await tester.pump(const Duration(milliseconds: 750)); // entrance

      final AppLocalizations l10n = await AppLocalizations.delegate.load(
        const Locale('en'),
      );
      expect(find.text(l10n.errorUnexpected), findsOneWidget);
    });

    testWidgets('first-load error does not show a snackbar', (
      WidgetTester tester,
    ) async {
      final StreamProvider<int> provider = StreamProvider<int>(
        (Ref ref) => Stream<int>.error(StateError('first-load')),
        name: 'firstLoadProvider',
      );

      await tester.pumpWidget(
        _host(
          provider,
          MxAppFeedbackObserver(
            logger: _RecordingLogger(),
            messengerKey: appMessengerKey,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
