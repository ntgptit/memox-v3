import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_avatar.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

import '../../../support/golden_harness.dart';

void main() {
  final Map<String, Widget> cases = <String, Widget>{
    'confirm-destructive': const Center(
      child: MxConfirmDialog(
        title: 'Delete folder?',
        message:
            'Languages and its 4 decks will be removed from your '
            'library. This cannot be undone.',
        confirmLabel: 'Delete',
        cancelLabel: 'Cancel',
        destructive: true,
      ),
    ),
    'confirm-safe': const Center(
      child: MxConfirmDialog(
        title: 'Discard changes?',
        message: 'You have unsaved changes. Leave without saving?',
        confirmLabel: 'Discard',
        cancelLabel: 'Keep editing',
      ),
    ),
    'bottom-sheet': const Align(
      alignment: Alignment.bottomCenter,
      child: MxBottomSheet(
        title: 'Folder actions',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MxListTile(
              leading: MxAvatar(icon: Icons.edit_outlined),
              title: 'Rename',
            ),
            MxListTile(
              leading: MxAvatar(icon: Icons.drive_file_move_outlined),
              title: 'Move',
            ),
            MxListTile(
              leading: MxAvatar(icon: Icons.delete_outline),
              title: 'Delete',
            ),
          ],
        ),
      ),
    ),
  };

  group('dialog & sheet goldens', () {
    for (final MapEntry<String, Widget> c in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${c.key} — ${brightness.name}', (tester) async {
          await pumpForGolden(tester, c.value, brightness: brightness);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/mx_${c.key}__${brightness.name}.png'),
          );
        });
      }
    }
  });
}
