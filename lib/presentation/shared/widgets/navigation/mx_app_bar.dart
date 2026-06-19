import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';

/// The MemoX top app bar: a flat, large-title bar with trailing actions.
///
/// Purpose:
/// One app-bar primitive so every screen shares the same flat (no elevation),
/// transparent, large-title treatment with token colors — instead of raw
/// `AppBar`s with ad-hoc styling.
///
/// Use when:
/// Providing a screen's top bar via `Scaffold.appBar` (it is a
/// [PreferredSizeWidget]).
///
/// Do not use when:
/// You need a collapsing/large sliver app bar (compose a sliver variant
/// separately).
///
/// Category:
/// navigation
///
/// Public API:
/// - title: the screen title; pass already-localized copy.
/// - actions: optional trailing widgets (typically `MxIconButton`s).
/// - leading: optional leading widget (defaults to the platform back button).
/// - automaticallyImplyLeading: show the back button when a route can pop.
class MxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MxAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.bg,
      surfaceTintColor: colors.bg,
      foregroundColor: colors.text,
      titleTextStyle: theme.textTheme.headlineMedium?.copyWith(
        color: colors.text,
      ),
    );
  }
}
