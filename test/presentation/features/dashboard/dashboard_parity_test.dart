import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';

import '../../../support/parity_contract.dart';

/// Parity contract for the dashboard, identity by STABLE KEY, driven by the
/// GENERATED contract (`tool/parity/contracts/contracts.json`).
///
/// The required `mx-node:<id>` keys come from the kit's `data-mx-node` ids via
/// the spec → `gen_contract.mjs` pipeline — no hand-coded list here. The FE tags
/// the matching widget with `key: ValueKey('mx-node:...')`; if a required node
/// isn't rendered, its key is absent → `expectGeneratedParityContract` fails
/// listing it (catches "FE chưa implement đủ", which `find.byType` and goldens
/// cannot). Removing any of the three dashboard FE keys makes this test red.
void main() {
  testWidgets('02-dashboard parity contract (loaded)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardSummaryProvider.overrideWith(
            (ref) => (
              failure: null,
              data: const DashboardSummary(cardsDue: 12, decksWithDue: 3),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MxTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expectGeneratedParityContract('02-dashboard');
  });
}
