import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

import '../../../support/golden_harness.dart';

void main() {
  group('MxConfirmDialog.show', () {
    testWidgets('returns true when the confirm action is tapped', (
      tester,
    ) async {
      late bool result;
      await pumpThemed(
        tester,
        Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async {
              result = await MxConfirmDialog.show(
                context,
                title: 'Delete folder?',
                message: 'This cannot be undone.',
                confirmLabel: 'Delete',
                cancelLabel: 'Cancel',
                destructive: true,
              );
            },
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete folder?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('returns false when cancelled', (tester) async {
      late bool result;
      await pumpThemed(
        tester,
        Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async {
              result = await MxConfirmDialog.show(
                context,
                title: 'Discard changes?',
                message: 'Leave without saving?',
                confirmLabel: 'Discard',
                cancelLabel: 'Keep editing',
              );
            },
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });

  group('showMxBottomSheet', () {
    testWidgets('presents the title, drag handle, and child content', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => showMxBottomSheet<void>(
              context,
              title: 'Folder actions',
              handleSemanticLabel: 'Dismiss',
              child: const MxListTile(title: 'Rename'),
            ),
            child: const Text('open'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Folder actions'), findsOneWidget);
      expect(find.text('Rename'), findsOneWidget);
      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
    });
  });
}
