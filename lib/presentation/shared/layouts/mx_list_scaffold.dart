import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';

/// Scaffold for scrollable list screens (Library, deck/card lists).
///
/// Builds a width-capped, padded `ListView.separated` from [itemCount] /
/// [itemBuilder]. An optional [header] (e.g. search field, segmented control)
/// pins above the list.
class MxListScaffold extends StatelessWidget {
  const MxListScaffold({
    required this.itemCount,
    required this.itemBuilder,
    this.appBar,
    this.header,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.separator = const SizedBox(height: SpacingTokens.sm),
    this.padding = const EdgeInsets.symmetric(vertical: SpacingTokens.md),
    super.key,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final PreferredSizeWidget? appBar;
  final Widget? header;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget separator;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final Widget list = ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, _) => separator,
      itemBuilder: itemBuilder,
    );
    return MxScaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: header == null
          ? list
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: SpacingTokens.sm),
                  child: header,
                ),
                Expanded(child: list),
              ],
            ),
    );
  }
}
