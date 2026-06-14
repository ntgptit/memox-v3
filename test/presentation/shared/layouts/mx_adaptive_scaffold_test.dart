import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/presentation/shared/layouts/mx_adaptive_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_bottom_navigation_bar.dart';

void main() {
  testWidgets('MxAdaptiveScaffold mobile path composes the shared bottom nav', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MediaQuery(
          data: MediaQueryData(size: Size(390, 844)),
          child: MxAdaptiveScaffold(
            selectedIndex: 1,
            onDestinationSelected: _noOp,
            destinations: <MxNavDestination>[
              MxNavDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              MxNavDestination(
                icon: Icons.folder_outlined,
                selectedIcon: Icons.folder,
                label: 'Library',
              ),
            ],
            body: Text('Body'),
          ),
        ),
      ),
    );

    expect(find.byType(MxBottomNavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });
}

void _noOp(int _) {}
