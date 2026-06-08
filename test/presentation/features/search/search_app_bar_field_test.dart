import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/search/viewmodels/search_viewmodel.dart';
import 'package:memox/presentation/features/search/widgets/search_app_bar_field.dart';

void main() {
  Widget buildHost({required Widget child}) => ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(appBar: AppBar(title: child)),
    ),
  );

  testWidgets('shows keycap when empty and clear icon after typing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildHost(child: const SearchAppBarField()));

    expect(find.text('K'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    await tester.enterText(find.byType(TextField), 'deck');
    await tester.pump();

    expect(find.text('K'), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(
      ProviderScope.containerOf(
        tester.element(find.byType(Scaffold)),
      ).read(searchQueryProvider),
      'deck',
    );
  });
}
