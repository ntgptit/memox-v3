import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';
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

class _FolderMovePicker extends HookWidget {
  const _FolderMovePicker({required this.targets});

  final List<FolderMoveTarget> targets;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final MxSearchControllerState search = useMxSearchController();
    final ValueNotifier<FolderMoveTarget?> selectedTarget =
        useState<FolderMoveTarget?>(_currentParentTarget());
    final ValueNotifier<List<FolderMoveTarget>> visible =
        useState<List<FolderMoveTarget>>(targets);
    useEffect(() {
      visible.value = _visible(search.text);
      return null;
    }, <Object?>[search.text, targets]);
    final bool canMove =
        selectedTarget.value != null &&
        selectedTarget.value!.isSelectable &&
        !selectedTarget.value!.isCurrentParent;
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
              controller: search.controller,
              hintText: l10n.folderMovePickerSearchHint,
              clearTooltip: l10n.librarySearchClearTooltip,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
              itemCount: visible.value.length,
              itemBuilder: (BuildContext context, int index) {
                final FolderMoveTarget target = visible.value[index];
                return _TargetRow(
                  title: _titleOf(l10n, target),
                  subtitle: _subtitleOf(l10n, target),
                  selected: selectedTarget.value == target,
                  enabled: target.isSelectable,
                  onTap: () => selectedTarget.value = target,
                );
              },
            ),
          ),
          ColoredBox(
            color: scheme.outlineVariant,
            child: const SizedBox(
              height: SpacingTokens.xxs,
              width: double.infinity,
            ),
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
                    onPressed: canMove
                        ? () => Navigator.of(context).pop(selectedTarget.value)
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

  String _titleOf(AppLocalizations l10n, FolderMoveTarget t) =>
      t.id == null ? l10n.foldersMoveRootTitle : t.breadcrumb.join(' / ');

  List<FolderMoveTarget> _visible(String searchText) {
    final String normalized = StringUtils.normalize(searchText);
    if (normalized.isEmpty) {
      return targets;
    }
    final List<FolderMoveTarget> visibleTargets = <FolderMoveTarget>[];
    for (final FolderMoveTarget target in targets) {
      if (target.id == null) {
        visibleTargets.add(target);
        continue;
      }
      final String breadcrumb = StringUtils.normalize(
        target.breadcrumb.join(' / '),
      );
      if (breadcrumb.contains(normalized)) {
        visibleTargets.add(target);
      }
    }
    return visibleTargets;
  }

  String? _subtitleOf(AppLocalizations l10n, FolderMoveTarget t) =>
      switch (t.block) {
        FolderMoveBlock.cycle => l10n.folderMovePickerCycleReason,
        FolderMoveBlock.lockedToDecks => l10n.folderMovePickerLockedReason,
        null => t.id == null ? l10n.foldersMoveRootSubtitle : null,
      };

  FolderMoveTarget? _currentParentTarget() {
    for (final FolderMoveTarget target in targets) {
      if (target.isCurrentParent) {
        return target;
      }
    }
    return null;
  }
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      child: MxTappable(
        onTap: enabled ? onTap : null,
        borderRadius: RadiusTokens.brSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: SpacingTokens.inline,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: SizeTokens.iconMd,
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
      ),
    );
  }
}
