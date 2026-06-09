import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';

/// Contract tests for the action-hierarchy density table
/// (`docs/ui-ux/action-hierarchy-contract.md` §Enforcement).
void main() {
  group('MxActionSpec.of', () {
    test('cardPrimary is compact and never full-width', () {
      final MxActionSpec spec = MxActionSpec.of(MxActionIntent.cardPrimary);
      expect(spec.size, MxButtonSize.compact);
      expect(spec.fullWidthDefault, isFalse);
      expect(spec.allowFullWidthOverride, isFalse);
    });

    test('cardSecondary resolves compact and is a secondary intent', () {
      final MxActionSpec spec = MxActionSpec.of(MxActionIntent.cardSecondary);
      expect(spec.size, MxButtonSize.compact);
      expect(MxActionSpec.isSecondary(MxActionIntent.cardSecondary), isTrue);
    });

    test('studyPrimary resolves compact', () {
      expect(
        MxActionSpec.of(MxActionIntent.studyPrimary).size,
        MxButtonSize.compact,
      );
    });

    test('inline is smaller than cardPrimary', () {
      final double inline = MxActionSpec.of(MxActionIntent.inline).size.height;
      final double cardPrimary = MxActionSpec.of(
        MxActionIntent.cardPrimary,
      ).size.height;
      expect(inline, lessThan(cardPrimary));
    });

    test('bottomAction defaults to full-width and allows override', () {
      final MxActionSpec spec = MxActionSpec.of(MxActionIntent.bottomAction);
      expect(spec.size, MxButtonSize.medium);
      expect(spec.fullWidthDefault, isTrue);
      expect(spec.allowFullWidthOverride, isTrue);
    });

    test('onboardingHero is the only large, full-width intent', () {
      final MxActionSpec hero = MxActionSpec.of(MxActionIntent.onboardingHero);
      expect(hero.size, MxButtonSize.large);
      expect(hero.fullWidthDefault, isTrue);
      for (final MxActionIntent intent in MxActionIntent.values) {
        if (intent == MxActionIntent.onboardingHero) {
          continue;
        }
        expect(
          MxActionSpec.of(intent).size,
          isNot(MxButtonSize.large),
          reason: '$intent must not resolve to large',
        );
      }
    });

    test(
      'card / inline / toolbar / dialog intents forbid full-width override',
      () {
        for (final MxActionIntent intent in <MxActionIntent>[
          MxActionIntent.cardPrimary,
          MxActionIntent.cardSecondary,
          MxActionIntent.inline,
          MxActionIntent.toolbar,
          MxActionIntent.dialogPrimary,
        ]) {
          expect(
            MxActionSpec.of(intent).allowFullWidthOverride,
            isFalse,
            reason: '$intent must not allow full-width',
          );
        }
      },
    );

    test('every intent resolves a spec (exhaustive switch)', () {
      for (final MxActionIntent intent in MxActionIntent.values) {
        expect(MxActionSpec.of(intent), isA<MxActionSpec>());
      }
    });
  });
}
