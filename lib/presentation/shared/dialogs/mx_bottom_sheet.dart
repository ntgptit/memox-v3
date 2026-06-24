import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// The MemoX modal bottom-sheet content shell: drag handle, optional title,
/// content slot.
///
/// Purpose:
/// One sheet frame so every modal sheet shares the rounded top, drag handle,
/// safe-area insets, and title treatment; pair it with [showMxBottomSheet] for
/// the themed modal host. See `docs/wireframes/25-shared-bottom-sheets.md`.
///
/// Use when:
/// Presenting a list, multi-choice, action menu (> 3 items), or content longer
/// than a few lines.
///
/// Do not use when:
/// A binary confirmation or short form fits a dialog (use `MxConfirmDialog` /
/// `MxDialog`).
///
/// Category:
/// dialog
///
/// Public API:
/// - child: prepared sheet content (the caller owns data + callbacks).
/// - title: optional heading shown under the drag handle (already-localized).
/// - handleSemanticLabel: accessibility label for the drag handle.
class MxBottomSheet extends StatelessWidget {
  const MxBottomSheet({
    required this.child,
    this.title,
    this.handleSemanticLabel,
    super.key,
  });

  final Widget child;
  final String? title;
  final String? handleSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MxColors colors = context.mxColors;
    final String? title = this.title;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: MxSpacing.screen,
          right: MxSpacing.screen,
          bottom: MediaQuery.viewInsetsOf(context).bottom + MxSpacing.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: MxSpacing.space3),
            Center(
              child: Semantics(
                label: handleSemanticLabel,
                child: Container(
                  width: MxSpacing.space8,
                  height: MxSpacing.space1,
                  decoration: BoxDecoration(
                    color: colors.borderStrong,
                    borderRadius: MxRadius.smAll,
                  ),
                ),
              ),
            ),
            if (title != null) ...<Widget>[
              const SizedBox(height: MxSpacing.space4),
              Text(title, style: theme.textTheme.titleLarge),
            ],
            const SizedBox(height: MxSpacing.space4),
            child,
          ],
        ),
      ),
    );
  }
}

/// Presents [child] in a themed modal bottom sheet over the root navigator
/// (so it can cover the app shell). Capped at 90% of screen height.
Future<T?> showMxBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  String? handleSemanticLabel,
  bool isScrollControlled = true,
}) {
  final MxColors colors = context.mxColors;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: isScrollControlled,
    // The MemoX scrim token (kit `--memox-overlay`): bluish-navy 45% in light,
    // black 60% in dark. Without it, Flutter falls back to `black54` — a heavy
    // grey scrim that diverges from the mock in light mode.
    barrierColor: colors.overlay,
    backgroundColor: colors.surface,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    ),
    shape: const RoundedRectangleBorder(borderRadius: MxRadius.topSheet),
    builder: (BuildContext context) => MxBottomSheet(
      title: title,
      handleSemanticLabel: handleSemanticLabel,
      child: child,
    ),
  );
}
