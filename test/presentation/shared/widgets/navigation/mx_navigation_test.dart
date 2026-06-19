import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_bottom_nav.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

import '../../../../support/golden_harness.dart';

void main() {
  group('MxIconButton', () {
    testWidgets('renders the glyph and fires onPressed', (tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        MxIconButton(
          icon: Icons.search,
          tooltip: 'Search',
          onPressed: () => taps++,
        ),
      );
      await tester.tap(find.byIcon(Icons.search));
      expect(taps, 1);
    });
  });

  group('MxAppBar', () {
    testWidgets('shows the title and trailing actions', (tester) async {
      await pumpThemedHome(
        tester,
        const Scaffold(
          appBar: MxAppBar(
            title: 'Library',
            actions: <Widget>[MxIconButton(icon: Icons.search)],
          ),
        ),
      );
      expect(find.text('Library'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('MxBottomNav', () {
    testWidgets('renders destinations and reports selection', (tester) async {
      int? selected;
      await pumpThemed(
        tester,
        MxBottomNav(
          selectedIndex: 1,
          onSelected: (int i) => selected = i,
          items: const <MxBottomNavItem>[
            MxBottomNavItem(icon: Icons.home_outlined, label: 'Home'),
            MxBottomNavItem(
              icon: Icons.collections_bookmark_outlined,
              label: 'Library',
            ),
            MxBottomNavItem(icon: Icons.bar_chart_outlined, label: 'Stats'),
            MxBottomNavItem(icon: Icons.settings_outlined, label: 'Settings'),
          ],
        ),
      );
      expect(find.text('Library'), findsOneWidget);
      await tester.tap(find.text('Settings'));
      expect(selected, 3);
    });
  });

  group('MxBreadcrumb', () {
    testWidgets('renders the trail and taps an ancestor', (tester) async {
      int taps = 0;
      await pumpThemed(
        tester,
        MxBreadcrumb(
          items: <MxBreadcrumbItem>[
            MxBreadcrumbItem(label: 'Library', onTap: () => taps++),
            const MxBreadcrumbItem(label: 'Languages'),
          ],
        ),
      );
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Languages'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      await tester.tap(find.text('Library'));
      expect(taps, 1);
    });
  });
}
