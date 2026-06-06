import 'package:flutter/material.dart';

/// The sanctioned modal bottom-sheet host
/// (`docs/wireframes/25-shared-bottom-sheets.md` §Common structure).
///
/// Feature code must route modal sheets through this helper instead of calling
/// `showModalBottomSheet` directly, so every sheet inherits the themed
/// `BottomSheetThemeData` (rounded top, `surfaceContainerLowest`, a visible
/// tappable drag handle) plus safe-area insets and the catalog's 90%-height cap
/// (longer content scrolls inside the sheet). [builder] supplies prepared view
/// content; the sheet owns no data loading.
Future<T?> showMxBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * 0.9,
  ),
  builder: builder,
);
