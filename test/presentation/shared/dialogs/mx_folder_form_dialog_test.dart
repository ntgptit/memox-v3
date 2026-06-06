import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_folder_form_dialog.dart';

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold)));

Widget _wrap({required Widget Function(BuildContext context) builder}) =>
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Builder(builder: builder)),
    );

void main() {
  testWidgets(
    'DT1 onDisplay: create dialog shows the preview, pickers, and CTA',
    (WidgetTester tester) async {
      String? result;
      await tester.pumpWidget(
        _wrap(
          builder: (BuildContext context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await showMxFolderCreateDialog(
                  context,
                  title: AppLocalizations.of(context).folderCreateDialogTitle,
                  description: AppLocalizations.of(
                    context,
                  ).folderCreateDialogDescription,
                  fieldLabel: AppLocalizations.of(
                    context,
                  ).folderCreateFieldLabel,
                  colorLabel: AppLocalizations.of(
                    context,
                  ).folderCreateColorLabel,
                  iconLabel: AppLocalizations.of(context).folderCreateIconLabel,
                  confirmLabel: AppLocalizations.of(context).commonCreate,
                  cancelLabel: AppLocalizations.of(context).commonCancel,
                );
              },
              child: const Text('Open create'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open create'));
      await tester.pumpAndSettle();

      final AppLocalizations l10n = _l10n(tester);
      expect(result, isNull);
      expect(find.text(l10n.folderCreateDialogTitle), findsOneWidget);
      expect(find.text(l10n.folderCreateDialogDescription), findsOneWidget);
      expect(
        find.text(l10n.folderCreateFieldLabel.toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(l10n.folderCreateColorLabel.toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(l10n.folderCreateIconLabel.toUpperCase()),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, l10n.commonCancel),
        findsOneWidget,
      );
      for (int i = 0; i < 6; i++) {
        expect(
          find.byKey(ValueKey<String>('folder_form_color_$i')),
          findsOneWidget,
        );
      }
      for (int i = 0; i < 5; i++) {
        expect(
          find.byKey(ValueKey<String>('folder_form_icon_$i')),
          findsOneWidget,
        );
      }
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, l10n.commonCreate),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .getSize(find.widgetWithText(OutlinedButton, l10n.commonCancel))
            .width,
        closeTo(
          tester
              .getSize(find.widgetWithText(FilledButton, l10n.commonCreate))
              .width,
          0.1,
        ),
      );
      expect(
        tester
            .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
            .where((ConstrainedBox box) => box.constraints.maxWidth == 432),
        isNotEmpty,
      );
    },
  );

  testWidgets('DT3 onUpdate: create dialog trims the submitted name', (
    WidgetTester tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _wrap(
        builder: (BuildContext context) => Center(
          child: ElevatedButton(
            onPressed: () async {
              result = await showMxFolderCreateDialog(
                context,
                title: AppLocalizations.of(context).folderCreateDialogTitle,
                description: AppLocalizations.of(
                  context,
                ).folderCreateDialogDescription,
                fieldLabel: AppLocalizations.of(context).folderCreateFieldLabel,
                colorLabel: AppLocalizations.of(context).folderCreateColorLabel,
                iconLabel: AppLocalizations.of(context).folderCreateIconLabel,
                confirmLabel: AppLocalizations.of(context).commonCreate,
                cancelLabel: AppLocalizations.of(context).commonCancel,
              );
            },
            child: const Text('Open create'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open create'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '  Vietnamese  ');
    await tester.pump();
    await tester.tap(
      find.widgetWithText(FilledButton, _l10n(tester).commonCreate),
    );
    await tester.pumpAndSettle();

    expect(result, 'Vietnamese');
  });

  testWidgets(
    'DT2 onDisplay: rename dialog shows helper copy and full selection',
    (WidgetTester tester) async {
      String? result;
      await tester.pumpWidget(
        _wrap(
          builder: (BuildContext context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await showMxFolderRenameDialog(
                  context,
                  title: AppLocalizations.of(context).foldersRenameTitle,
                  description: AppLocalizations.of(
                    context,
                  ).folderRenameDialogDescription,
                  fieldLabel: AppLocalizations.of(
                    context,
                  ).folderRenameDialogFieldLabel,
                  helperText: AppLocalizations.of(
                    context,
                  ).folderRenameDialogHelper('8 decks · 412 cards'),
                  confirmLabel: AppLocalizations.of(context).commonRename,
                  cancelLabel: AppLocalizations.of(context).commonCancel,
                  initialValue: 'Korean',
                );
              },
              child: const Text('Open rename'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open rename'));
      await tester.pumpAndSettle();

      final AppLocalizations l10n = _l10n(tester);
      final TextField textField = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(result, isNull);
      expect(find.text(l10n.foldersRenameTitle), findsOneWidget);
      expect(find.text(l10n.folderRenameDialogDescription), findsOneWidget);
      expect(
        find.text(l10n.folderRenameDialogFieldLabel.toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text('8 decks · 412 cards will keep this folder as their home.'),
        findsOneWidget,
      );
      expect(textField.controller?.text, 'Korean');
      expect(
        textField.controller?.selection,
        const TextSelection(baseOffset: 0, extentOffset: 6),
      );
      expect(
        find.widgetWithText(OutlinedButton, l10n.commonCancel),
        findsOneWidget,
      );
      expect(
        tester
            .getSize(find.widgetWithText(OutlinedButton, l10n.commonCancel))
            .width,
        greaterThan(100),
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, l10n.commonRename),
            )
            .onPressed,
        isNotNull,
      );
      expect(
        tester
            .getSize(find.widgetWithText(OutlinedButton, l10n.commonCancel))
            .width,
        closeTo(
          tester
              .getSize(find.widgetWithText(FilledButton, l10n.commonRename))
              .width,
          0.1,
        ),
      );
      expect(
        tester
            .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
            .where((ConstrainedBox box) => box.constraints.maxWidth == 432),
        isNotEmpty,
      );
    },
  );

  testWidgets('DT4 onUpdate: rename dialog trims the submitted name', (
    WidgetTester tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _wrap(
        builder: (BuildContext context) => Center(
          child: ElevatedButton(
            onPressed: () async {
              result = await showMxFolderRenameDialog(
                context,
                title: AppLocalizations.of(context).foldersRenameTitle,
                description: AppLocalizations.of(
                  context,
                ).folderRenameDialogDescription,
                fieldLabel: AppLocalizations.of(
                  context,
                ).folderRenameDialogFieldLabel,
                helperText: AppLocalizations.of(
                  context,
                ).folderRenameDialogHelper('8 decks · 412 cards'),
                confirmLabel: AppLocalizations.of(context).commonRename,
                cancelLabel: AppLocalizations.of(context).commonCancel,
                initialValue: 'Korean',
              );
            },
            child: const Text('Open rename'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rename'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '  Mandarin  ');
    await tester.pump();
    await tester.tap(
      find.widgetWithText(FilledButton, _l10n(tester).commonRename),
    );
    await tester.pumpAndSettle();

    expect(result, 'Mandarin');
  });

  testWidgets('DT5 onDismiss: folder dialog stays open until Cancel', (
    WidgetTester tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _wrap(
        builder: (BuildContext context) => Center(
          child: ElevatedButton(
            onPressed: () async {
              result = await showMxFolderRenameDialog(
                context,
                title: AppLocalizations.of(context).foldersRenameTitle,
                description: AppLocalizations.of(
                  context,
                ).folderRenameDialogDescription,
                fieldLabel: AppLocalizations.of(
                  context,
                ).folderRenameDialogFieldLabel,
                helperText: AppLocalizations.of(
                  context,
                ).folderRenameDialogHelper('8 decks · 412 cards'),
                confirmLabel: AppLocalizations.of(context).commonRename,
                cancelLabel: AppLocalizations.of(context).commonCancel,
                initialValue: 'Korean',
              );
            },
            child: const Text('Open rename'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open rename'));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = _l10n(tester);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text(l10n.foldersRenameTitle), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text(l10n.foldersRenameTitle), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, l10n.commonCancel));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text(l10n.foldersRenameTitle), findsNothing);
  });

  testWidgets('DT6 onDismiss: create dialog stays open until Cancel', (
    WidgetTester tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _wrap(
        builder: (BuildContext context) => Center(
          child: ElevatedButton(
            onPressed: () async {
              result = await showMxFolderCreateDialog(
                context,
                title: AppLocalizations.of(context).folderCreateDialogTitle,
                description: AppLocalizations.of(
                  context,
                ).folderCreateDialogDescription,
                fieldLabel: AppLocalizations.of(context).folderCreateFieldLabel,
                colorLabel: AppLocalizations.of(context).folderCreateColorLabel,
                iconLabel: AppLocalizations.of(context).folderCreateIconLabel,
                confirmLabel: AppLocalizations.of(context).commonCreate,
                cancelLabel: AppLocalizations.of(context).commonCancel,
              );
            },
            child: const Text('Open create'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open create'));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = _l10n(tester);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text(l10n.folderCreateDialogTitle), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text(l10n.folderCreateDialogTitle), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, l10n.commonCancel));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text(l10n.folderCreateDialogTitle), findsNothing);
  });
}
