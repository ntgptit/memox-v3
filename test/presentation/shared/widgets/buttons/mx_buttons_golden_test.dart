import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';

import '../../../../support/golden_harness.dart';

Widget _gallery() => Padding(
  padding: const EdgeInsets.all(MxSpacing.screen),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: MxSpacing.space4,
    children: <Widget>[
      MxPrimaryButton(
        label: 'Create folder',
        icon: Icons.create_new_folder_outlined,
        onPressed: () {},
      ),
      MxSecondaryButton(label: 'Discard', onPressed: () {}),
      MxSecondaryButton(
        label: 'Cancel',
        variant: MxSecondaryVariant.outlined,
        onPressed: () {},
      ),
      MxSecondaryButton(
        label: 'Start new learning',
        variant: MxSecondaryVariant.text,
        onPressed: () {},
      ),
      MxCardActions(
        secondary: MxActionButton(
          intent: MxActionIntent.cardSecondary,
          label: 'Discard',
          onPressed: () {},
        ),
        primary: MxActionButton(
          intent: MxActionIntent.cardPrimary,
          label: 'Resume',
          onPressed: () {},
        ),
      ),
    ],
  ),
);

void main() {
  group('button goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('gallery — ${brightness.name}', (tester) async {
        await pumpForGolden(tester, _gallery(), brightness: brightness);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/mx_buttons__${brightness.name}.png'),
        );
      });
    }
  });
}
