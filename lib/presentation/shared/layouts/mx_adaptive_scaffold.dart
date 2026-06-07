import 'package:flutter/material.dart';

import 'package:memox/core/theme/responsive/breakpoints.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';

/// A top-level navigation destination for [MxAdaptiveScaffold].
/// Category:
/// layout
class MxNavDestination {
  const MxNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Shell that switches navigation chrome by form factor.
///
/// `docs/ui-ux/ui-ux-contract.md` §Responsive: a bottom `NavigationBar` on
/// mobile, a `NavigationRail` on tablet/desktop (≥ 600dp). The four MemoX
/// destinations (Home / Library / Progress / Settings) are caller-supplied so
/// the labels stay localized.
///
///
/// Purpose:
/// Provides a reusable MemoX layout widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared layout surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - destinations: public content.
/// - selectedIndex: public property.
/// - onDestinationSelected: callback.
/// - body: public content.
/// - appBar: public property.
/// - floatingActionButton: public property.
/// Category:
/// layout
class MxAdaptiveScaffold extends StatelessWidget {
  const MxAdaptiveScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    super.key,
  });

  final List<MxNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final bool useRail = !context.isMobile;
    final Widget content = SafeArea(child: MxContentShell(child: body));

    if (!useRail) {
      return Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: <Widget>[
            for (final MxNavDestination d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: <NavigationRailDestination>[
              for (final MxNavDestination d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      ),
    );
  }
}
