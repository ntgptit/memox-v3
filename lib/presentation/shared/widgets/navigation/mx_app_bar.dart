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
/// - title: the screen title; pass already-localized copy. Optional when
///   [titleWidget] is supplied.
/// - titleWidget: a custom title slot (e.g. an inline search field) that
///   replaces the [title] text — for app-bar modes that aren't a plain title.
/// - actions: optional trailing widgets (typically `MxIconButton`s).
/// - leading: optional leading widget (defaults to the platform back button).
/// - automaticallyImplyLeading: show the back button when a route can pop.
/// - titleSpacing: horizontal gap before the title (defaults to the AppBar
///   default); set to the screen gutter for a full-bleed title widget.
class MxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MxAppBar({
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.toolbarHeight,
    super.key,
  }) : assert(
         title != null || titleWidget != null,
         'Provide a title or a titleWidget.',
       );

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? titleSpacing;

  /// Toolbar height below the status-bar inset; defaults to [kToolbarHeight].
  /// Give a boxed title widget (e.g. a search field) extra room so it does not
  /// crowd the status bar.
  final double? toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    final Widget? titleWidget = this.titleWidget;
    return AppBar(
      title: titleWidget ?? Text(title ?? ''),
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
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
