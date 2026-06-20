import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_opacity.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/folder_visual_tokens.dart';
import 'package:memox/presentation/features/folders/widgets/folder_icon_tile.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// The user's create-folder choices: a required [name] plus optional opaque
/// color/icon tokens (`null` = theme default). WBS 2.1.2 / 2.22.1.
typedef FolderDraft = ({String name, String? color, String? icon});

/// Shows the create-folder dialog (name field + color + icon pickers) and
/// resolves to the chosen [FolderDraft] on confirm, or `null` on cancel /
/// dismiss. Name validation + duplicate rules live in the use case; failures
/// surface as a snackbar (`docs/design/screens/library-overview.visual-contract.md`
/// §`03g`). WBS 2.1.2.
Future<FolderDraft?> showFolderCreateDialog(BuildContext context) =>
    showMxDialog<FolderDraft>(
      context,
      builder: (BuildContext context) => const _FolderCreateDialog(),
    );

class _FolderCreateDialog extends HookWidget {
  const _FolderCreateDialog();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final MxTextSubmitState field = useMxTextSubmitState();
    final ValueNotifier<FolderColorToken?> color = useState<FolderColorToken?>(
      null,
    );
    final ValueNotifier<FolderIconToken?> icon = useState<FolderIconToken?>(
      null,
    );

    void submit() {
      if (!field.canSubmit) return;
      Navigator.of(context).pop((
        name: field.trimmedText,
        color: color.value?.token,
        icon: icon.value?.token,
      ));
    }

    final Color previewTint = color.value?.resolve(colors) ?? colors.accent;
    final IconData previewIcon = icon.value?.icon ?? Icons.folder_outlined;

    return MxDialog(
      title: l10n.folderCreateTitle,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                FolderIconTile(color: previewTint, icon: previewIcon),
                const SizedBox(width: MxSpacing.space3),
                Expanded(
                  child: MxTextField(
                    controller: field.controller,
                    labelText: l10n.folderCreateNameLabel,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MxSpacing.space5),
            MxText(
              l10n.folderCreateColorLabel,
              role: MxTextRole.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: MxSpacing.space3),
            _ColorPicker(
              selected: color.value,
              onSelected: (v) => color.value = v,
            ),
            const SizedBox(height: MxSpacing.space5),
            MxText(
              l10n.folderCreateIconLabel,
              role: MxTextRole.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: MxSpacing.space3),
            _IconPicker(
              tint: previewTint,
              selected: icon.value,
              onSelected: (v) => icon.value = v,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        MxSecondaryButton(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MxPrimaryButton(
          label: l10n.folderCreateConfirm,
          onPressed: field.canSubmit ? submit : null,
        ),
      ],
    );
  }
}

/// Horizontal row of the eight folder tint swatches; tapping a selected swatch
/// clears it (→ theme accent default).
class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final FolderColorToken? selected;
  final ValueChanged<FolderColorToken?> onSelected;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Wrap(
      spacing: MxSpacing.space3,
      runSpacing: MxSpacing.space3,
      children: <Widget>[
        for (final FolderColorToken token in FolderColorToken.values)
          _Swatch(
            color: token.resolve(colors),
            isSelected: token == selected,
            onTap: () => onSelected(token == selected ? null : token),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxTappable(
      onTap: onTap,
      borderRadius: MxRadius.pillAll,
      child: Container(
        width: MxSpacing.space8,
        height: MxSpacing.space8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: colors.text) : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: colors.accentContrast,
                size: MxIconSize.sm,
              )
            : null,
      ),
    );
  }
}

/// Wrap grid of the twelve folder icons, each in a tinted [FolderIconTile];
/// tapping a selected icon clears it (→ folder default).
class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.tint,
    required this.selected,
    required this.onSelected,
  });

  final Color tint;
  final FolderIconToken? selected;
  final ValueChanged<FolderIconToken?> onSelected;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Wrap(
      spacing: MxSpacing.space2,
      runSpacing: MxSpacing.space2,
      children: <Widget>[
        for (final FolderIconToken token in FolderIconToken.values)
          MxTappable(
            onTap: () => onSelected(token == selected ? null : token),
            borderRadius: MxRadius.mdAll,
            child: Container(
              width: MxSpacing.space12,
              height: MxSpacing.space12,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: token == selected
                    ? tint.withValues(alpha: MxOpacity.hover)
                    : null,
                borderRadius: MxRadius.mdAll,
                border: Border.all(
                  color: token == selected ? colors.accent : colors.border,
                ),
              ),
              child: Icon(
                token.icon,
                color: token == selected ? tint : colors.textSecondary,
                size: MxIconSize.md,
              ),
            ),
          ),
      ],
    );
  }
}
