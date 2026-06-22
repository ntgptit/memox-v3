import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_scoped_search_dock.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';

import '../../../../support/golden_harness.dart';

void main() {
  group('MxTextField', () {
    testWidgets('renders hint and reports changes', (tester) async {
      String? latest;
      await pumpThemed(
        tester,
        MxTextField(hintText: 'Front', onChanged: (String v) => latest = v),
      );
      expect(find.text('Front'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'hello');
      expect(latest, 'hello');
    });
  });

  group('MxSearchField', () {
    testWidgets('shows the search glyph and no clear button when empty', (
      tester,
    ) async {
      await pumpThemed(tester, const MxSearchField(hintText: 'Search'));
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('reveals a clear button after typing and clears it', (
      tester,
    ) async {
      String? latest;
      await pumpThemed(
        tester,
        MxSearchField(hintText: 'Search', onChanged: (String v) => latest = v),
      );

      await tester.enterText(find.byType(TextField), 'lang');
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(latest, 'lang');

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.byIcon(Icons.close), findsNothing);
      expect(latest, '');
    });
  });

  group('MxScopedSearchDock', () {
    testWidgets('hosts the given child inside the dock chrome', (tester) async {
      await pumpThemed(
        tester,
        const MxScopedSearchDock(child: Text('scoped-field')),
      );
      expect(find.text('scoped-field'), findsOneWidget);
      // The dock owns the top-hairline surface chrome + the home-indicator safe area.
      expect(find.byType(DecoratedBox), findsWidgets);
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
