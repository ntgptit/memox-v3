import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/layouts/mx_adaptive_scaffold.dart'
    show MxNavDestination;

/// Bottom navigation styled per the mock: a floating, rounded surface card with
/// a ghost border (shadows are replaced by the ghost edge) holding the themed
/// M3 `NavigationBar` — so the active destination keeps its primary pill
/// indicator.
///
/// Pure presentation: it only forwards [selectedIndex] /
/// [onDestinationSelected], so it drops into `StatefulShellRoute` without
/// changing tab/route behavior.
class MxBottomNavigationBar extends StatelessWidget {
  const MxBottomNavigationBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<MxNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg,
          0,
          SpacingTokens.lg,
          SpacingTokens.sm,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: RadiusTokens.brXl,
            border: Border.fromBorderSide(
              BorderTokens.ghostSide(scheme.primary),
            ),
          ),
          child: ClipRRect(
            borderRadius: RadiusTokens.brXl,
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              backgroundColor: ColorTokens.transparent,
              elevation: 0,
              destinations: <Widget>[
                for (final MxNavDestination d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
