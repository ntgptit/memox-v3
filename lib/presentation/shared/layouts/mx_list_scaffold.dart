import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';

/// Screen shell for scrollable list screens (Library, deck / card lists).
///
/// Purpose:
/// Builds a width-capped, padded `ListView.separated` from [itemCount] /
/// [itemBuilder] on top of [MxScaffold], so list screens share one layout.
/// An optional [header] pins above the list. WBS 1.2.6.
///
/// Use when:
/// A feature screen's primary content is a vertically scrolling list of rows.
///
/// Do not use when:
/// The screen is form-like or free-form (use `MxScaffold` and lay out the body
/// directly). This shell intentionally omits the `bottomSheet` /
/// `resizeToAvoidBottomInset` slots; a list screen that needs them should
/// compose `MxScaffold` with its own `ListView` instead.
///
/// Category:
/// layout
///
/// Public API:
/// - itemCount: number of list rows.
/// - itemBuilder: row builder (`ListView.separated` itemBuilder).
/// - appBar: optional themed app bar.
/// - header: optional pinned header above the list.
/// - floatingActionButton: optional FAB slot (compose `MxFab`).
/// - bottomNavigationBar: optional bottom-nav slot (usually app-shell owned).
/// - separator: inter-row separator widget.
/// - padding: list content padding.
class MxListScaffold extends StatelessWidget {
  const MxListScaffold({
    required this.itemCount,
    required this.itemBuilder,
    this.appBar,
    this.header,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.separator = const SizedBox(height: MxSpacing.space2),
    this.padding = const EdgeInsets.symmetric(vertical: MxSpacing.space4),
    super.key,
  });

  /// Number of rows.
  final int itemCount;

  /// Row builder (`ListView.separated` itemBuilder).
  final IndexedWidgetBuilder itemBuilder;

  /// Themed app bar (usually `MxAppBar`).
  final PreferredSizeWidget? appBar;

  /// Optional pinned header above the list.
  final Widget? header;

  /// Floating action button (compose `MxFab`).
  final Widget? floatingActionButton;

  /// Bottom navigation slot — normally owned by the app shell.
  final Widget? bottomNavigationBar;

  /// Inter-row separator.
  final Widget separator;

  /// List content padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Widget list = ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, _) => separator,
      itemBuilder: itemBuilder,
    );
    final Widget? header = this.header;
    return MxScaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: header == null
          ? list
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: MxSpacing.space2),
                  child: header,
                ),
                Expanded(child: list),
              ],
            ),
    );
  }
}
