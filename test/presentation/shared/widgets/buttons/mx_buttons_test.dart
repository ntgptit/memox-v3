import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';

import '../../../../support/golden_harness.dart';

void main() {
  group('MxActionIntent density contract', () {
    test('resolves size/emphasis/full-width per the contract table', () {
      expect(MxActionIntent.screenPrimary.size, MxButtonSize.medium);
      expect(MxActionIntent.onboardingHero.size, MxButtonSize.large);
      expect(MxActionIntent.cardPrimary.size, MxButtonSize.compact);
      expect(MxActionIntent.studyPrimary.size, MxButtonSize.compact);
      expect(MxActionIntent.toolbar.size, MxButtonSize.xsmall);

      expect(MxActionIntent.cardPrimary.isPrimary, isTrue);
      expect(MxActionIntent.cardSecondary.isPrimary, isFalse);
      expect(MxActionIntent.inline.isPrimary, isFalse);

      // inline is strictly smaller than card primary.
      expect(
        MxActionIntent.inline.size.height,
        lessThan(MxActionIntent.cardPrimary.size.height),
      );

      expect(MxActionIntent.bottomAction.defaultFullWidth, isTrue);
      expect(MxActionIntent.cardPrimary.defaultFullWidth, isFalse);
      expect(MxActionIntent.cardPrimary.allowsFullWidthOverride, isFalse);
      expect(MxActionIntent.bottomAction.allowsFullWidthOverride, isTrue);
    });
  });

  group('MxPrimaryButton', () {
    testWidgets('renders label and fires onPressed', (tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        MxPrimaryButton(label: 'Create folder', onPressed: () => taps++),
      );
      expect(find.text('Create folder'), findsOneWidget);
      await tester.tap(find.text('Create folder'));
      expect(taps, 1);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await pumpThemed(tester, const MxPrimaryButton(label: 'Disabled'));
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });
  });

  group('MxSecondaryButton', () {
    testWidgets('tonal variant renders a tonal filled button', (tester) async {
      await pumpThemed(tester, const MxSecondaryButton(label: 'Discard'));
      expect(find.text('Discard'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('outlined variant renders an outlined button', (tester) async {
      await pumpThemed(
        tester,
        const MxSecondaryButton(
          label: 'Cancel',
          variant: MxSecondaryVariant.outlined,
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('MxActionButton', () {
    testWidgets('cardPrimary renders the primary button', (tester) async {
      await pumpThemed(
        tester,
        const MxActionButton(intent: MxActionIntent.cardPrimary, label: 'Open'),
      );
      expect(find.byType(MxPrimaryButton), findsOneWidget);
    });

    testWidgets('cardSecondary renders the secondary button', (tester) async {
      await pumpThemed(
        tester,
        const MxActionButton(
          intent: MxActionIntent.cardSecondary,
          label: 'Later',
        ),
      );
      expect(find.byType(MxSecondaryButton), findsOneWidget);
    });

    testWidgets('fullWidth:true on cardPrimary trips an assert', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        const MxActionButton(
          intent: MxActionIntent.cardPrimary,
          label: 'Bad',
          fullWidth: true,
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });
  });

  group('MxCardActions', () {
    testWidgets('renders primary and secondary', (tester) async {
      await pumpThemed(
        tester,
        const MxCardActions(
          secondary: MxActionButton(
            intent: MxActionIntent.cardSecondary,
            label: 'Discard',
          ),
          primary: MxActionButton(
            intent: MxActionIntent.cardPrimary,
            label: 'Resume',
          ),
        ),
      );
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
    });
  });
}
