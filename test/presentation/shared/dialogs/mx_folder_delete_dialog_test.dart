import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/extensions/custom_colors.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_folder_delete_dialog.dart';

Widget _wrap({ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (BuildContext context) => Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showMxFolderDeleteDialog(
            context,
            folderName: 'TOPIK II',
            summaryText: '5 decks',
            title: AppLocalizations.of(context).folderDeleteDialogTitle,
            reassuranceText: AppLocalizations.of(
              context,
            ).folderDeleteDialogReassurance,
            confirmLabel: AppLocalizations.of(
              context,
            ).folderDeleteDialogConfirmLabel,
            deleteButtonLabel: AppLocalizations.of(
              context,
            ).folderDeleteDialogDeleteButton,
            cancelLabel: AppLocalizations.of(context).commonCancel,
            confirmHint: AppLocalizations.of(
              context,
            ).folderDeleteDialogConfirmLabel,
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  ),
);

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold)));

void main() {
  testWidgets('matches the stronger folder delete mock and gates delete', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap());

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = _l10n(tester);

    expect(find.text(l10n.folderDeleteDialogTitle), findsOneWidget);
    expect(
      find.text('TOPIK II and its 5 decks will be removed from your library.'),
      findsOneWidget,
    );
    expect(find.text(l10n.folderDeleteDialogReassurance), findsOneWidget);
    expect(
      find.text(l10n.folderDeleteDialogConfirmLabel.toUpperCase()),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);

    final Finder deleteButton = find.widgetWithText(
      FilledButton,
      l10n.folderDeleteDialogDeleteButton,
    );
    expect(tester.widget<FilledButton>(deleteButton).onPressed, isNull);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text(l10n.folderDeleteDialogTitle), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(l10n.folderDeleteDialogTitle), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'TOPIK II');
    await tester.pump();

    expect(tester.widget<FilledButton>(deleteButton).onPressed, isNotNull);
  });

  testWidgets('uses the destructive container colors in dark theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap(theme: AppTheme.dark()));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final BuildContext buttonContext = tester.element(
      find.widgetWithText(FilledButton, 'Delete folder'),
    );
    final FilledButton button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Delete folder'),
    );
    final CustomColors colors = Theme.of(
      buttonContext,
    ).extension<CustomColors>()!;

    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{}),
      colors.destructiveFill,
    );
    expect(
      button.style?.foregroundColor?.resolve(<WidgetState>{}),
      colors.onDestructiveFill,
    );
  });
}
