import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/layouts/mx_adaptive_scaffold.dart'
    show MxNavDestination;
import 'package:memox/presentation/shared/widgets/navigation/mx_bottom_navigation_bar.dart';

/// Bottom-navigation shell hosting the four top-level destinations.
///
/// Backed by `StatefulShellRoute.indexedStack`, so each tab keeps its own
/// navigation stack. Tab switches use `goBranch` (reset semantics), matching
/// `docs/business/navigation/navigation-flow.md` §Push vs Go.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab returns it to its branch root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: MxBottomNavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: <MxNavDestination>[
          MxNavDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: l10n.homeTitle,
          ),
          MxNavDestination(
            icon: Icons.folder_outlined,
            selectedIcon: Icons.folder,
            label: l10n.libraryTitle,
          ),
          MxNavDestination(
            icon: Icons.insights_outlined,
            selectedIcon: Icons.insights,
            label: l10n.progressTitle,
          ),
          MxNavDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: l10n.settingsTitle,
          ),
        ],
      ),
    );
  }
}
