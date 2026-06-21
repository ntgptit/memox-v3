import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/models/deck_move_target.dart';
import 'package:memox/domain/models/deck_summary.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/deck_actions_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/deck_move_picker_sheet.dart';

final DateTime _t = DateTime.utc(2026);

DeckSummary _deck() => DeckSummary(
  deck: Deck(
    id: 'd1',
    folderId: 'home',
    name: 'Japanese',
    targetLanguage: TargetLanguage.korean,
    sortOrder: 0,
    createdAt: _t,
    updatedAt: _t,
  ),
  cardCount: 42,
  dueCount: 0,
);

const List<DeckMoveTarget> _targets = <DeckMoveTarget>[
  DeckMoveTarget(
    id: 'home',
    name: 'Home',
    breadcrumb: <String>['Home'],
    isCurrentParent: true,
    block: null,
  ),
  DeckMoveTarget(
    id: 'other',
    name: 'Other',
    breadcrumb: <String>['Other'],
    isCurrentParent: false,
    block: null,
  ),
  DeckMoveTarget(
    id: 'parent',
    name: 'Parent',
    breadcrumb: <String>['Parent'],
    isCurrentParent: false,
    block: DeckMoveBlock.lockedToSubfolders,
  ),
];

/// Pumps a button that opens [onPressed]'s sheet, captures the resolved value.
Future<void> _pumpTrigger(
  WidgetTester tester,
  Future<Object?> Function(BuildContext) open,
  void Function(Object?) onResult,
) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MxTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async => onResult(await open(context)),
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
  testWidgets('deck action sheet exposes Move and returns DeckAction.move', (
    tester,
  ) async {
    DeckAction? result;
    await _pumpTrigger(
      tester,
      (BuildContext c) => showDeckActionsSheet(c, summary: _deck()),
      (Object? r) => result = r as DeckAction?,
    );

    expect(find.text('Move to folder'), findsOneWidget); // the Move row
    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Delete deck'), findsOneWidget);

    await tester.tap(find.text('Move to folder'));
    await tester.pumpAndSettle();
    expect(result, DeckAction.move);
  });

  testWidgets('deck move picker: current parent + blocked rows are not '
      'selectable; a free folder moves', (tester) async {
    DeckMoveTarget? picked;
    await _pumpTrigger(
      tester,
      (BuildContext c) => showDeckMovePicker(c, targets: _targets),
      (Object? r) => picked = r as DeckMoveTarget?,
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Parent'), findsOneWidget);
    // The subfolders-locked block reason is shown.
    expect(find.text('This folder holds subfolders'), findsOneWidget);

    // Tapping the current parent does nothing (no-op, not selectable).
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(picked, isNull);

    // Tapping the blocked folder does nothing.
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    expect(picked, isNull);

    // Tapping a free decks-allowing folder resolves to it.
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    expect(picked?.id, 'other');
  });

  testWidgets('deck move picker renders an all-blocked list with no selectable '
      'row (dead-end is guarded by the caller)', (tester) async {
    DeckMoveTarget? picked;
    const List<DeckMoveTarget> allBlocked = <DeckMoveTarget>[
      DeckMoveTarget(
        id: 'home',
        name: 'Home',
        breadcrumb: <String>['Home'],
        isCurrentParent: true,
        block: null,
      ),
      DeckMoveTarget(
        id: 'parent',
        name: 'Parent',
        breadcrumb: <String>['Parent'],
        isCurrentParent: false,
        block: DeckMoveBlock.lockedToSubfolders,
      ),
    ];
    await _pumpTrigger(
      tester,
      (BuildContext c) => showDeckMovePicker(c, targets: allBlocked),
      (Object? r) => picked = r as DeckMoveTarget?,
    );

    // No selectable row: tapping either resolves nothing.
    await tester.tap(find.text('Home'));
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    expect(picked, isNull);
  });
}
