import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/deck_move_target.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/deck_move_picker_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/folder_move_picker_sheet.dart';

import '../../../support/golden_harness.dart';

// Move-sheet state (kit `04-folder-detail--move-sheet`): both move pickers are
// `showMxBottomSheet` lists of `MxListTile` rows — a selectable destination, a
// nested destination (path subtitle), the current parent (check, not
// selectable), and a blocked destination (disabled, reason subtitle). The kit's
// radio + "Move here" confirm restyle is a deferred refinement (WBS 2.19.2);
// these goldens lock the current tap-to-select design across light + dark.

const List<DeckMoveTarget> _deckTargets = <DeckMoveTarget>[
  DeckMoveTarget(
    id: 'l',
    name: 'Languages',
    breadcrumb: <String>['Languages'],
    isCurrentParent: true,
    block: null,
  ),
  DeckMoveTarget(
    id: 's',
    name: 'Sciences',
    breadcrumb: <String>['Sciences'],
    isCurrentParent: false,
    block: null,
  ),
  DeckMoveTarget(
    id: 'e',
    name: 'East Asian',
    breadcrumb: <String>['Languages', 'East Asian'],
    isCurrentParent: false,
    block: null,
  ),
  DeckMoveTarget(
    id: 'h',
    name: 'History',
    breadcrumb: <String>['History'],
    isCurrentParent: false,
    block: DeckMoveBlock.lockedToSubfolders,
  ),
];

const List<FolderMoveTarget> _folderTargets = <FolderMoveTarget>[
  FolderMoveTarget(
    id: null,
    name: '',
    breadcrumb: <String>[],
    isCurrentParent: false,
    block: null,
  ),
  FolderMoveTarget(
    id: 's',
    name: 'Sciences',
    breadcrumb: <String>['Sciences'],
    isCurrentParent: true,
    block: null,
  ),
  FolderMoveTarget(
    id: 'e',
    name: 'East Asian',
    breadcrumb: <String>['Languages', 'East Asian'],
    isCurrentParent: false,
    block: null,
  ),
  FolderMoveTarget(
    id: 'h',
    name: 'History',
    breadcrumb: <String>['History'],
    isCurrentParent: false,
    block: FolderMoveBlock.lockedToDecks,
  ),
];

/// Opens [open]'s sheet over a host scaffold on the golden surface and settles
/// the sheet animation before capture.
Future<void> _pumpPickerGolden(
  WidgetTester tester,
  Future<Object?> Function(BuildContext) open, {
  required Brightness brightness,
}) async {
  tester.view.physicalSize = kGoldenSurface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => open(context),
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
  group('move picker goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('deck move picker — ${brightness.name}', (tester) async {
        await _pumpPickerGolden(
          tester,
          (BuildContext c) => showDeckMovePicker(c, targets: _deckTargets),
          brightness: brightness,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/deck_move_picker__${brightness.name}.png'),
        );
      });

      testWidgets('folder move picker — ${brightness.name}', (tester) async {
        await _pumpPickerGolden(
          tester,
          (BuildContext c) => showFolderMovePicker(c, targets: _folderTargets),
          brightness: brightness,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/folder_move_picker__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
