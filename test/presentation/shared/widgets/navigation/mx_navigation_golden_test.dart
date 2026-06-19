import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_bottom_nav.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

import '../../../../support/golden_harness.dart';

const List<MxBottomNavItem> _navItems = <MxBottomNavItem>[
  MxBottomNavItem(icon: Icons.home_outlined, label: 'Home'),
  MxBottomNavItem(icon: Icons.collections_bookmark_outlined, label: 'Library'),
  MxBottomNavItem(icon: Icons.bar_chart_outlined, label: 'Stats'),
  MxBottomNavItem(icon: Icons.settings_outlined, label: 'Settings'),
];

void _noop(int _) {}

Widget _navScaffold() => Scaffold(
  appBar: MxAppBar(
    title: 'Library',
    automaticallyImplyLeading: false,
    actions: <Widget>[
      MxIconButton(icon: Icons.search, onPressed: () {}),
      MxIconButton(icon: Icons.swap_vert, onPressed: () {}),
    ],
  ),
  body: const Padding(
    padding: EdgeInsets.all(MxSpacing.screen),
    child: MxBreadcrumb(
      items: <MxBreadcrumbItem>[
        MxBreadcrumbItem(label: 'Library'),
        MxBreadcrumbItem(label: 'Languages'),
      ],
    ),
  ),
  bottomNavigationBar: const MxBottomNav(
    selectedIndex: 1,
    onSelected: _noop,
    items: _navItems,
  ),
);

void main() {
  group('navigation goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('shell — ${brightness.name}', (tester) async {
        tester.view.physicalSize = kGoldenSurface;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await pumpThemedHome(tester, _navScaffold(), brightness: brightness);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/mx_nav_shell__${brightness.name}.png'),
        );
      });
    }
  });
}
