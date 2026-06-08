import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/folder_move_picker_sheet.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

List<FolderMoveTarget> _targets() => <FolderMoveTarget>[
  const FolderMoveTarget(
    id: null,
    breadcrumb: <String>[],
    isCurrentParent: false,
  ),
  const FolderMoveTarget(
    id: 'parent',
    breadcrumb: <String>['Korean'],
    isCurrentParent: true,
  ),
  const FolderMoveTarget(
    id: 'grammar',
    breadcrumb: <String>['Korean', 'Grammar'],
    isCurrentParent: false,
  ),
  const FolderMoveTarget(
    id: 'blocked',
    breadcrumb: <String>['Korean', 'Blocked'],
    isCurrentParent: false,
    block: FolderMoveBlock.cycle,
  ),
];

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Builder(builder: (_) => child)),
);

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold)));

void main() {
  testWidgets(
    'keeps the current parent selected, disables Move, and leaves blocked rows inert',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (BuildContext context) => ElevatedButton(
              onPressed: () async {
                await showFolderMovePicker(context, targets: _targets());
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final AppLocalizations l10n = _l10n(tester);
      final Finder moveButton = find.widgetWithText(
        MxActionButton,
        l10n.commonMove,
      );
      expect(tester.widget<MxActionButton>(moveButton).onPressed, isNull);
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Korean'),
            matching: find.byType(MxTappable),
          ),
          matching: find.byIcon(Icons.radio_button_checked),
        ),
        findsOneWidget,
      );

      final Finder blockedRow = find.ancestor(
        of: find.text('Korean / Blocked'),
        matching: find.byType(MxTappable),
      );
      expect(tester.widget<MxTappable>(blockedRow).onTap, isNull);

      await tester.enterText(find.byType(TextField), 'grammar');
      await tester.pump();

      expect(find.text(l10n.foldersMoveRootTitle), findsOneWidget);
      expect(find.text('Korean / Grammar'), findsOneWidget);
      expect(find.text('Korean / Blocked'), findsNothing);
    },
  );

  testWidgets('cancel returns null and Move returns the selected target', (
    WidgetTester tester,
  ) async {
    FolderMoveTarget? result;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (BuildContext context) => ElevatedButton(
            onPressed: () async {
              result = await showFolderMovePicker(context, targets: _targets());
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = _l10n(tester);
    await tester.tap(find.widgetWithText(MxActionButton, l10n.commonCancel));
    await tester.pumpAndSettle();

    expect(result, isNull);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.foldersMoveRootTitle));
    await tester.pump();
    await tester.tap(find.widgetWithText(MxActionButton, l10n.commonMove));
    await tester.pumpAndSettle();

    expect(
      result,
      const FolderMoveTarget(
        id: null,
        breadcrumb: <String>[],
        isCurrentParent: false,
      ),
    );
  });
}
