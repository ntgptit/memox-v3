import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';

/// Scaffold for form screens — scrollable body with a pinned bottom action bar.
///
/// The [bottomAction] (typically a `bottomAction`-intent `MxActionButton`)
/// sits in a safe-area-padded bar above the keyboard. The body scrolls.
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
/// - body: public content.
/// - bottomAction: public property.
/// - appBar: public property.
/// Category:
/// layout
class MxFormScaffold extends StatelessWidget {
  const MxFormScaffold({
    required this.body,
    required this.bottomAction,
    this.appBar,
    super.key,
  });

  final Widget body;
  final Widget bottomAction;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    body: SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              child: MxContentShell(child: body),
            ),
          ),
          _BottomBar(child: bottomAction),
        ],
      ),
    ),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderTokens.strongSide(scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.md,
        SpacingTokens.lg,
        SpacingTokens.md,
      ),
      child: SafeArea(top: false, child: MxContentShell(child: child)),
    );
  }
}
