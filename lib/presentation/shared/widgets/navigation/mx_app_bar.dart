import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

/// App bar wrapper — feature code must not use raw `AppBar`
/// (`memox.design_system.no_raw_app_bar`).
///
/// Styling (flat, transparent tint, title style) comes from the themed
/// `AppBarTheme`. Pass [titleText] for the common case or [title] for a custom
/// title widget.
///
/// Purpose:
/// Provides a reusable MemoX navigation widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared navigation surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - titleText: public property.
/// - title: public content.
/// - actions: public property.
/// - leading: public property.
/// - bottom: public property.
/// Category:
/// navigation
class MxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MxAppBar({
    this.titleText,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    super.key,
  });

  final String? titleText;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(SizeTokens.appbar + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) => AppBar(
    title: title ?? (titleText == null ? null : Text(titleText!)),
    actions: actions,
    leading: leading,
    bottom: bottom,
  );
}
