import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';

/// One destination in an [MxBottomNav].
@immutable
class MxBottomNavItem {
  const MxBottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

/// The MemoX bottom navigation bar for top-level destinations.
///
/// Purpose:
/// One bottom-nav primitive so the main destinations share the same density,
/// selected-pill tint, and label/icon colors from tokens — instead of a raw
/// `NavigationBar` re-themed per use.
///
/// Use when:
/// Switching between the top-level shell destinations (Home/Library/Search/
/// Progress/Settings).
///
/// Do not use when:
/// Navigating within a feature (use routes/tabs), not the app's primary tabs.
///
/// Category:
/// navigation
///
/// Public API:
/// - items: the destinations (icon + label, optional selected icon).
/// - selectedIndex: the active destination index.
/// - onSelected: called with the tapped destination index.
///
/// States:
/// - selected vs unselected per item, driven by [selectedIndex].
class MxBottomNav extends StatelessWidget {
  const MxBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<MxBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => theme.textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.accent
                : colors.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.accent
                : colors.textSecondary,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: <Widget>[
          for (final MxBottomNavItem item in items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon ?? item.icon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
