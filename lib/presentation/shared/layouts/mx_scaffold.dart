import 'package:flutter/material.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';

/// Base screen scaffold — themed `AppBar`, width-capped body, optional FAB and
/// bottom navigation.
///
/// The default screen shell. Wraps [body] in an [MxContentShell] unless
/// [useShell] is `false` (e.g. a screen that manages its own slivers/full-bleed
/// layout).
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
