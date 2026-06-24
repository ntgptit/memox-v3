import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

const int _kib = 1024;

/// Localized human file size ("512 B" / "24.6 KB" / "1.2 MB").
String formatImportFileSize(AppLocalizations l10n, int bytes) {
  if (bytes < _kib) {
    return l10n.deckImportSizeBytes(bytes);
  }
  if (bytes < _kib * _kib) {
    return l10n.deckImportSizeKb((bytes / _kib).toStringAsFixed(1));
  }
  return l10n.deckImportSizeMb((bytes / (_kib * _kib)).toStringAsFixed(1));
}

/// Upper-cased file type from a name's extension ("CSV"/"TSV"), or empty.
String importFileTypeLabel(String name) {
  final int dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) {
    return '';
  }
  return StringUtils.upperFold(name.substring(dot + 1));
}

/// The chosen-file chip (kit `10--file-selected` / preview header): a file tile +
/// the name over a [meta] line, with a trailing clear (×) when [onClear] is set.
class DeckImportFileChip extends StatelessWidget {
  const DeckImportFileChip({
    required this.fileName,
    required this.meta,
    this.onClear,
    super.key,
  });

  final String fileName;
  final String meta;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxCard(
      key: const ValueKey<String>('mx-node:10-deck-import/file-chip'),
      padding: const EdgeInsets.all(MxSpacing.space3),
      child: Row(
        children: <Widget>[
          MxIconTile(color: colors.info, icon: Icons.description_outlined),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  fileName,
                  role: MxTextRole.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: MxSpacing.space1),
                MxText(
                  meta,
                  role: MxTextRole.bodySmall,
                  color: colors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onClear != null)
            MxIconButton(
              icon: Icons.close,
              tooltip: l10n.deckImportClearFile,
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
