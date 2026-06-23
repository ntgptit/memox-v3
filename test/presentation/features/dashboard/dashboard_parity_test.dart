import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';

import '../../../support/parity_contract.dart';

/// Spec-driven parity contract for the dashboard, identity by STABLE KEY.
///
/// The required list is `mx-node:<screen>/<node>` key STRINGS derived from the
/// design — strings, so this test compiles no matter what the FE has (or hasn't)
/// built. The FE tags the matching widget with that key
/// (`key: ValueKey('mx-node:...')`); if a required node isn't implemented, its key
/// is absent → the contract fails listing it. That is how this catches "FE chưa
/// implement đủ", which `find.byType` cannot (the type must already exist to
/// compile) and a golden image cannot (FE-vs-FE regression only).
Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

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

    expectParityContract('02-dashboard', <String, Finder>{
      'due summary card': _node('02-dashboard/due-summary'),
      'Progress shortcut row': _node('02-dashboard/shortcut-progress'),
      'Library shortcut row': _node('02-dashboard/shortcut-library'),
    });
  });
}
