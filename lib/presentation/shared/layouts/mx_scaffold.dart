import 'package:flutter/material.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';

/// Base screen shell — themed app bar, width-capped body, optional FAB and
/// bottom navigation.
///
/// Purpose:
/// The default top-level surface for every feature screen. The guard
/// `memox.screen_shell.no_raw_scaffold` forbids a raw [Scaffold] in feature
/// code, so screens compose this instead. Wraps [body] in an [MxContentShell]
/// (the page gutter) unless [useShell] is `false`. WBS 1.2.6.
///
/// Use when:
/// A feature screen needs the shared scaffold surface (app bar + gutter + FAB /
/// bottom-nav slots).
///
/// Do not use when:
/// The screen is a scrollable list (prefer `MxListScaffold`) or needs a one-off
/// non-screen layout.
///
/// Category:
/// layout
///
/// Public API:
/// - body: the screen content; gutter-wrapped unless [useShell] is false.
/// - appBar: optional themed app bar (usually `MxAppBar`).
/// - floatingActionButton: optional FAB slot (compose `MxFab`).
/// - bottomNavigationBar: optional bottom-nav slot (usually app-shell owned).
/// - bottomSheet: optional persistent bottom sheet slot.
/// - useShell: whether to apply the [MxContentShell] page gutter (default true).
/// - resizeToAvoidBottomInset: forwarded to [Scaffold].
class MxScaffold extends StatelessWidget {
  const MxScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.useShell = true,
    this.resizeToAvoidBottomInset = true,
    super.key,
  });

  /// Main screen content. Wrapped in the page gutter unless [useShell] is off.
  final Widget body;

  /// Themed app bar (usually `MxAppBar`).
  final PreferredSizeWidget? appBar;

  /// Floating action button (compose `MxFab`, never a raw `FloatingActionButton`).
  final Widget? floatingActionButton;

  /// Bottom navigation slot — normally owned by the app shell, not the screen.
  final Widget? bottomNavigationBar;

  /// Persistent bottom sheet slot.
  final Widget? bottomSheet;

  /// Whether to wrap [body] in the [MxContentShell] page gutter. Turn off for
  /// scroll views that manage their own horizontal padding / full-bleed layout.
  final bool useShell;

  /// Forwarded to [Scaffold.resizeToAvoidBottomInset].
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    floatingActionButton: floatingActionButton,
    bottomNavigationBar: bottomNavigationBar,
    bottomSheet: bottomSheet,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    body: SafeArea(child: useShell ? MxContentShell(child: body) : body),
  );
}
