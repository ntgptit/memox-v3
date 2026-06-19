import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_avatar.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

import '../../../../support/golden_harness.dart';

void main() {
  group('MxCard', () {
    testWidgets('renders child and fires onTap', (tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        MxCard(onTap: () => taps++, child: const Text('Body')),
      );

      expect(find.text('Body'), findsOneWidget);
      await tester.tap(find.text('Body'));
      expect(taps, 1);
    });
  });

  group('MxListTile', () {
    testWidgets('renders title, subtitle, leading, trailing and taps', (
      tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        MxListTile(
          leading: const MxAvatar(icon: Icons.folder_outlined),
          title: 'Languages',
          subtitle: '4 decks · 412 cards',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => taps++,
        ),
      );

      expect(find.text('Languages'), findsOneWidget);
      expect(find.text('4 decks · 412 cards'), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.text('Languages'));
      expect(taps, 1);
    });
  });

  group('MxAvatar', () {
    testWidgets('shows an icon when given one', (tester) async {
      await pumpThemed(tester, const MxAvatar(icon: Icons.book_outlined));
      expect(find.byIcon(Icons.book_outlined), findsOneWidget);
    });

    testWidgets('falls back to initials when no icon', (tester) async {
      await pumpThemed(tester, const MxAvatar(label: 'AN'));
      expect(find.text('AN'), findsOneWidget);
    });
  });

  group('MxContentShell', () {
    testWidgets('applies the horizontal screen gutter', (tester) async {
      await pumpThemed(tester, const MxContentShell(child: SizedBox.shrink()));

      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is Padding &&
              w.padding ==
                  const EdgeInsets.symmetric(horizontal: MxSpacing.screen),
        ),
        findsOneWidget,
      );
    });

    testWidgets('caps width when maxWidth is set', (tester) async {
      await pumpThemed(
        tester,
        const MxContentShell(maxWidth: 480, child: SizedBox.shrink()),
      );

      expect(
        find.byWidgetPredicate(
          (Widget w) => w is ConstrainedBox && w.constraints.maxWidth == 480,
        ),
        findsOneWidget,
      );
    });
  });
}
