import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';

import '../../../support/golden_harness.dart';
import '../../../support/structural_dump.dart';

/// Emits the structural dump for the dashboard's `loaded` state (light + dark) so
/// `tool/parity/structural_inventory.mjs` can check it against
/// `specs/02-dashboard.md`. This is the deterministic, geometry-based half of the
/// parity loop's node inventory (the pixel half is golden_diff). Re-run after a
/// dashboard layout change; the dumps under test/_parity_dump/ are committed
/// artifacts (like goldens).
void main() {
  Result<DashboardSummary> ok(DashboardSummary s) => (failure: null, data: s);

  Future<void> pump(WidgetTester tester, Brightness brightness) async {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardSummaryProvider.overrideWith(
            (ref) => ok(const DashboardSummary(cardsDue: 12, decksWithDue: 3)),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('dashboard structural dump', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('loaded — ${brightness.name}', (tester) async {
        await pump(tester, brightness);
        await dumpStructure(tester, 'dashboard_loaded__${brightness.name}');
        // Sanity: the dump is non-trivial (the screen rendered content).
        expect(find.byType(DashboardScreen), findsOneWidget);
      });
    }
  });
}
