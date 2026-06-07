import 'package:flutter/material.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';

/// Base screen scaffold — themed `AppBar`, width-capped body, optional FAB and
/// bottom navigation.
///
/// The default screen shell. Wraps [body] in an [MxContentShell] unless
/// [useShell] is `false` (e.g. a screen that manages its own slivers/full-bleed
/// layout).
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
/// - appBar: public property.
/// - floatingActionButton: public property.
/// - bottomNavigationBar: public property.
/// - bottomSheet: public property.
/// - useShell: public property.
/// - resizeToAvoidBottomInset: public property.
/// Category:
/// layout
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

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool useShell;
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
