import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

/// App bar wrapper — feature code must not use raw `AppBar`
/// (`memox.feature_raw_flutter_widget_usage`).
///
/// Styling (flat, transparent tint, title style) comes from the themed
/// `AppBarTheme`. Pass [titleText] for the common case or [title] for a custom
/// title widget.
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
