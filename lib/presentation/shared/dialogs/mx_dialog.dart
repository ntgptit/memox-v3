import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';

/// The base MemoX modal dialog shell: title, body slot, right-aligned actions.
///
/// Purpose:
/// One dialog frame so every modal shares the same surface, radius, title
/// style, and trailing action row — features compose content/actions rather
/// than re-styling `AlertDialog`.
///
/// Use when:
/// Building a short modal (confirmation, small form) from a callback.
///
/// Do not use when:
/// The content is a list/multi-choice or longer than a few lines (use
/// `MxBottomSheet`), or there is nothing modal to ask.
///
/// Category:
/// dialog
///
/// Public API:
/// - title: dialog heading; pass already-localized copy.
/// - content: the body widget (e.g. a message or small form).
/// - actions: trailing action row widgets (safe action first, then primary).
class MxDialog extends StatelessWidget {
  const MxDialog({
    required this.title,
    required this.content,
    required this.actions,
    super.key,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    return AlertDialog(
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: MxRadius.lgAll),
      title: Text(title, style: theme.textTheme.titleLarge),
      content: DefaultTextStyle.merge(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
        ),
        child: content,
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: actions,
    );
  }
}

/// The sanctioned way to present a custom [MxDialog] from feature code, which
/// must not call `showDialog` directly (`memox.design_system.no_direct_show_dialog`).
/// Returns the value the dialog pops with, or `null` on barrier dismiss.
/// WBS 1.2.7.
Future<T?> showMxDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) => showDialog<T>(
  context: context,
  barrierDismissible: barrierDismissible,
  builder: builder,
);
