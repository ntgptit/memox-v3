import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Opens the move-folder destination picker
/// (`docs/wireframes/25-shared-bottom-sheets.md` §folder-picker) over the
/// prepared [targets] and resolves to the chosen destination, or `null` when
/// cancelled.
///
/// Blocked destinations (the folder itself, its descendants, or `decks`-locked
/// folders) stay visible but disabled with their reason — disabling teaches the
/// rule. The default selection is the folder's current parent (a no-op, so Move
/// stays disabled until the user picks somewhere new).
Future<FolderMoveTarget?> showFolderMovePicker(
  BuildContext context, {
  required List<FolderMoveTarget> targets,
}) => showMxBottomSheet<FolderMoveTarget>(
  context,
  builder: (BuildContext context) => _FolderMovePicker(targets: targets),
);

class _FolderMovePicker extends StatefulWidget {
  const _FolderMovePicker({required this.targets});

  final List<FolderMoveTarget> targets;

  @override
  State<_FolderMovePicker> createState() => _FolderMovePickerState();
}

class _FolderMovePickerState extends State<_FolderMovePicker> {
  final TextEditingController _controller = TextEditingController();
  String _search = '';
  late FolderMoveTarget? _selected = widget.targets
      .where((FolderMoveTarget t) => t.isCurrentParent)
      .firstOrNull;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _titleOf(AppLocalizations l10n, FolderMoveTarget t) =>
      t.id == null ? l10n.foldersMoveRootTitle : t.breadcrumb.join(' / ');

  List<FolderMoveTarget> get _visible {
    final String normalized = StringUtils.normalize(_search);
    if (normalized.isEmpty) {
      return widget.targets;
    }
    return widget.targets
        .where(
          (FolderMoveTarget t) =>
              t.id == null ||
              StringUtils.normalize(t.breadcrumb.join(' / ')).contains(
                normalized,
              ),
        )
        .toList(growable: false);
  }

  bool get _canMove =>
      _selected != null &&
      _selected!.isSelectable &&
      !_selected!.isCurrentParent;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final List<FolderMoveTarget> visible = _visible;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.lg,
              SpacingTokens.xs,
              SpacingTokens.lg,
              SpacingTokens.sm,
            ),
            child: MxText(
              l10n.foldersMoveTitle,
              role: MxTextRole.titleMedium,
              fontWeight: TypographyTokens.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            child: MxSearchField(
              controller: _controller,
              hintText: l10n.folderMovePickerSearchHint,
              clearTooltip: l10n.librarySearchClearTooltip,
              onChanged: (String value) => setState(() => _search = value),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: SpacingTokens.xs,
              ),
              itemCount: visible.length,
              itemBuilder: (BuildContext context, int index) {
                final FolderMoveTarget target = visible[index];
                return _TargetRow(
                  title: _titleOf(l10n, target),
                  subtitle: _subtitleOf(l10n, target),
                  selected: identical(target, _selected),
                  enabled: target.isSelectable,
                  onTap: () => setState(() => _selected = target),
                );
              },
            ),
          ),
          ColoredBox(
            color: scheme.outlineVariant,
            child: const SizedBox(height: 1, width: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: MxActionButton(
                    intent: MxActionIntent.cardSecondary,
                    label: l10n.commonCancel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: MxActionButton(
                    intent: MxActionIntent.bottomAction,
                    label: l10n.commonMove,
                    onPressed: _canMove
                        ? () => Navigator.of(context).pop(_selected)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _subtitleOf(AppLocalizations l10n, FolderMoveTarget t) =>
      switch (t.block) {
        FolderMoveBlock.cycle => l10n.folderMovePickerCycleReason,
        FolderMoveBlock.lockedToDecks => l10n.folderMovePickerLockedReason,
        null => t.id == null ? l10n.foldersMoveRootSubtitle : null,
      };
}

/// A single radio destination row — greyed and inert when [enabled] is false.
class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color titleColor = enabled
        ? scheme.onSurface
        : scheme.onSurfaceVariant;
    return MxTappable(
      onTap: enabled ? onTap : null,
      borderRadius: RadiusTokens.brSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.sm + 2,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: SpacingTokens.xl,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MxText(
                    title,
                    role: MxTextRole.bodyLarge,
                    color: titleColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      subtitle!,
                      role: MxTextRole.labelMedium,
                      color: scheme.onSurfaceVariant,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
