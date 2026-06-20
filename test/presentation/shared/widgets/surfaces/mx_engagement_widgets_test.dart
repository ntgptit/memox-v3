import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_due_summary.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_goal_ring.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_insight.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_shortcut_row.dart';

import '../../../../support/golden_harness.dart';

const Key _goldenKey = ValueKey<String>('golden-root');

Widget _padded(Widget child) => Padding(
  key: _goldenKey,
  padding: const EdgeInsets.all(MxSpacing.space4),
  child: child,
);

void main() {
  group('MxShortcutRow', () {
    testWidgets('renders label/subtitle and fires onTap', (tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        MxShortcutRow(
          icon: Icons.insights_outlined,
          label: 'Progress',
          subtitle: 'Goal, streak, accuracy',
          onTap: () => taps++,
        ),
      );
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Goal, streak, accuracy'), findsOneWidget);
      await tester.tap(find.text('Progress'));
      expect(taps, 1);
    });
  });

  group('MxDueSummary', () {
    testWidgets('shows the action when due', (tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        MxDueSummary(
          title: '12 cards due',
          subtitle: '3 decks · about 8 min',
          actionLabel: 'Review',
          onAction: () => taps++,
        ),
      );
      expect(find.text('12 cards due'), findsOneWidget);
      await tester.tap(find.text('Review'));
      expect(taps, 1);
    });

    testWidgets('caught-up hides the action', (tester) async {
      await pumpThemed(
        tester,
        const MxDueSummary(
          title: 'All caught up',
          subtitle: 'Nothing due right now.',
          actionLabel: 'Review',
          caughtUp: true,
        ),
      );
      expect(find.text('All caught up'), findsOneWidget);
      expect(find.text('Review'), findsNothing);
    });
  });

  group('MxInsight', () {
    testWidgets('renders title/description and fires the link', (tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        MxInsight(
          tone: MxInsightTone.good,
          icon: Icons.local_fire_department_outlined,
          title: "You're close to today's goal",
          description: '2 more cards to hit 20.',
          actionLabel: 'Study now',
          onAction: () => taps++,
        ),
      );
      expect(find.text("You're close to today's goal"), findsOneWidget);
      expect(find.text('2 more cards to hit 20.'), findsOneWidget);
      await tester.tap(find.text('Study now'));
      expect(taps, 1);
    });
  });

  group('MxGoalRing', () {
    testWidgets('shows value over total', (tester) async {
      await pumpThemed(
        tester,
        const MxGoalRing(value: 12, total: 20, label: '12/20'),
      );
      expect(find.text('12/20'), findsOneWidget);
    });
  });

  group('engagement widget goldens', () {
    final Map<String, Widget> cases = <String, Widget>{
      'shortcut_row': const MxShortcutRow(
        icon: Icons.insights_outlined,
        label: 'Progress',
        subtitle: 'Goal, streak, accuracy',
      ),
      'due_summary': const MxDueSummary(
        title: '12 cards due',
        subtitle: '3 decks · about 8 min',
        actionLabel: 'Review',
      ),
      'due_summary_caught_up': const MxDueSummary(
        title: 'All caught up',
        subtitle: 'Nothing due right now.',
        caughtUp: true,
      ),
      'insight': const MxInsight(
        tone: MxInsightTone.good,
        icon: Icons.local_fire_department_outlined,
        title: "You're close to today's goal",
        description: '2 more cards to hit 20.',
        actionLabel: 'Study now',
      ),
      'goal_ring': const MxGoalRing(value: 12, total: 20, label: '12/20'),
    };
    for (final MapEntry<String, Widget> c in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${c.key} — ${brightness.name}', (tester) async {
          await pumpForGolden(tester, _padded(c.value), brightness: brightness);
          await expectLater(
            find.byKey(_goldenKey),
            matchesGoldenFile(
              'goldens/engagement_${c.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
