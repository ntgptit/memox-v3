import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_bottom_nav.dart';

/// Bottom-navigation shell hosting the five top-level destinations
/// (Home · Library · Search · Progress · Settings).
///
/// Backed by `StatefulShellRoute.indexedStack`, so each tab keeps its own
/// navigation stack. Tab switches use `goBranch` (reset semantics), matching
/// `docs/business/navigation/navigation-flow.md` §Top-level destinations.
/// Search is a primary destination (thumb-reachable) rather than a top-app-bar
/// icon, per the design redesign. WBS 1.2.6.
class MxAppShell extends StatelessWidget {
  const MxAppShell({required this.navigationShell, super.key});

  /// The shell route's navigation controller (current branch + `goBranch`).
  final StatefulNavigationShell navigationShell;

  void _onSelected(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab returns it to its branch root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: MxBottomNav(
        selectedIndex: navigationShell.currentIndex,
        onSelected: _onSelected,
        items: <MxBottomNavItem>[
          MxBottomNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: l10n.homeTitle,
          ),
          MxBottomNavItem(
            icon: Icons.folder_outlined,
            selectedIcon: Icons.folder,
            label: l10n.libraryTitle,
          ),
          MxBottomNavItem(
            icon: Icons.search_outlined,
            selectedIcon: Icons.search,
            label: l10n.searchTitle,
          ),
          MxBottomNavItem(
            icon: Icons.insights_outlined,
            selectedIcon: Icons.insights,
            label: l10n.progressTitle,
          ),
          MxBottomNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: l10n.settingsTitle,
          ),
        ],
      ),
    );
  }
}
