import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_due_summary.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_shortcut_row.dart';

import '../../../support/golden_harness.dart';

Result<DashboardSummary> _ok(DashboardSummary s) => (failure: null, data: s);
Result<DashboardSummary> _fail() => (
  failure: const Failure.storage(
    operation: StorageOp.read,
    table: 'flashcard_progress',
    cause: 'boom',
  ),
  data: null,
);

Future<void> _pump(
  WidgetTester tester, {
  required FutureOr<Result<DashboardSummary>> Function() summary,
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dashboardSummaryProvider.overrideWith((ref) => summary())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DashboardScreen(),
      ),
    ),
  );
}

Future<Result<DashboardSummary>> _never() =>
    Completer<Result<DashboardSummary>>().future;

void main() {
  group('DashboardScreen states', () {
    testWidgets('due summary + shortcut rows', (tester) async {
      await _pump(
        tester,
        summary: () =>
            _ok(const DashboardSummary(cardsDue: 12, decksWithDue: 3)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MxDueSummary), findsOneWidget);
      expect(find.text('12 cards due'), findsOneWidget);
      expect(find.byType(MxShortcutRow), findsNWidgets(2));
    });

    testWidgets('caught up hides the count', (tester) async {
      await _pump(tester, summary: () => _ok(const DashboardSummary()));
      await tester.pumpAndSettle();
      expect(find.text('All caught up'), findsOneWidget);
    });

    testWidgets('failure shows the error state', (tester) async {
      await _pump(tester, summary: _fail);
      await tester.pumpAndSettle();
      expect(find.byType(MxErrorState), findsOneWidget);
    });
  });

  group('DashboardScreen goldens', () {
    final Map<String, ({FutureOr<Result<DashboardSummary>> Function() summary})>
    cases = <String, ({FutureOr<Result<DashboardSummary>> Function() summary})>{
      'loaded': (
        summary: () =>
            _ok(const DashboardSummary(cardsDue: 12, decksWithDue: 3)),
      ),
      'caught-up': (summary: () => _ok(const DashboardSummary())),
      'loading': (summary: _never),
      'error': (summary: _fail),
    };
    for (final entry in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${entry.key} — ${brightness.name}', (tester) async {
          await _pump(
            tester,
            summary: entry.value.summary,
            brightness: brightness,
            golden: true,
          );
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(DashboardScreen),
            matchesGoldenFile(
              'goldens/dashboard_${entry.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
