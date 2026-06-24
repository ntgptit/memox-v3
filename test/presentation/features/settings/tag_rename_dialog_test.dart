import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/widgets/tag_rename_dialog.dart';

/// The rename dialog detects a name collision and switches to a merge prompt
/// (kit `11--rename` → `11--rename-merge`).
Future<void> _open(
  WidgetTester tester, {
  required String current,
  required Set<String> existing,
  required void Function(TagRenameOutcome?) onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MxTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async {
              final TagRenameOutcome? r = await showTagRenameDialog(
                context,
                currentName: current,
                existingNames: existing,
              );
              onResult(r);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a fresh name renames (Save → merge:false)', (tester) async {
    TagRenameOutcome? outcome;
    await _open(
      tester,
      current: 'kanji',
      existing: <String>{'kanji', 'vocab'},
      onResult: (TagRenameOutcome? r) => outcome = r,
    );

    await tester.enterText(find.byType(TextField), 'kanji2');
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(outcome, isNotNull);
    expect(outcome!.name, 'kanji2');
    expect(outcome!.merge, isFalse);
  });

  testWidgets('the unchanged name keeps Save disabled (no no-op submit)', (
    tester,
  ) async {
    bool resolved = false;
    await _open(
      tester,
      current: 'kanji',
      existing: <String>{'kanji', 'vocab'},
      onResult: (TagRenameOutcome? _) => resolved = true,
    );

    // Prefilled with the current name → Save is present but disabled.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(resolved, isFalse, reason: 'a same-name Save must not submit');
  });

  testWidgets(
    'a colliding name switches to a merge (Merge tags → merge:true)',
    (tester) async {
      TagRenameOutcome? outcome;
      await _open(
        tester,
        current: 'kanji',
        existing: <String>{'kanji', 'vocab'},
        onResult: (TagRenameOutcome? r) => outcome = r,
      );

      await tester.enterText(find.byType(TextField), 'vocab');
      await tester.pumpAndSettle();
      expect(find.text('Merge tags'), findsOneWidget);
      expect(find.text('Save'), findsNothing);

      await tester.tap(find.text('Merge tags'));
      await tester.pumpAndSettle();
      expect(outcome, isNotNull);
      expect(outcome!.name, 'vocab');
      expect(outcome!.merge, isTrue);
    },
  );
}
