import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/sort/library_sort_provider.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Localized label for a sort [mode] (the deferred `lastStudied` has no UI
/// label — see [kSortSheetModes]).
String contentSortModeLabel(AppLocalizations l10n, ContentSortMode mode) =>
    switch (mode) {
      ContentSortMode.manual => l10n.sortModeManual,
      ContentSortMode.name => l10n.sortModeName,
      ContentSortMode.newest => l10n.sortModeNewest,
      ContentSortMode.lastStudied => l10n.sortModeNewest,
    };

/// Shows the shared content-sort bottom sheet — one row per [kSortSheetModes]
/// entry with a check on [current] — and resolves to the chosen
/// [ContentSortMode] (or `null` when dismissed). Used by Library, Folder detail,
/// Deck, and Flashcard screens.
Future<ContentSortMode?> showContentSortSheet(
  BuildContext context, {
  required ContentSortMode current,
}) => showMxBottomSheet<ContentSortMode>(
  context,
  title: AppLocalizations.of(context).sortSheetTitle,
  child: _ContentSortSheet(current: current),
);

class _ContentSortSheet extends StatelessWidget {
  const _ContentSortSheet({required this.current});

  final ContentSortMode current;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final ContentSortMode mode in kSortSheetModes)
          MxTappable(
            onTap: () => Navigator.of(context).pop(mode),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: MxSpacing.space3,
                horizontal: MxSpacing.space1,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: MxText(
                      contentSortModeLabel(l10n, mode),
                      role: MxTextRole.bodyLarge,
                      color: mode == current ? colors.accent : colors.text,
                    ),
                  ),
                  if (mode == current)
                    Icon(
                      Icons.check,
                      size: MxIconSize.md,
                      color: colors.accent,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
