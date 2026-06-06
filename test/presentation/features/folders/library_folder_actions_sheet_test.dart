import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_actions_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

void main() {
  testWidgets(
    'library folder action rows keep an outer inset so focus does not touch the edge',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    await showLibraryFolderActions(
                      context,
                      name: 'Korean',
                      subtitle: '8 decks · 412 cards',
                      showImport: true,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final Finder actionRow = find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(MxTappable),
          )
          .first;

      expect(tester.getRect(actionRow).left, greaterThanOrEqualTo(8));
      expect(tester.getRect(actionRow).top, greaterThanOrEqualTo(4));
    },
  );
}
