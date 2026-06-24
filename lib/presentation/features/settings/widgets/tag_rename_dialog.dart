import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_opacity.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// The outcome of the rename dialog: the trimmed [name], and whether it collides
/// with another existing tag ([merge] → the caller runs a merge instead of a
/// rename, per `docs/contracts/usecase-contracts/tag.md` §RenameTag).
typedef TagRenameOutcome = ({String name, bool merge});

/// Shows the rename-tag dialog pre-filled with [currentName] (kit
/// `11--rename` / `11--rename-merge`). When the typed name matches another
/// existing tag (case-insensitive, from [existingNames]), the field turns to a
/// merge prompt and the CTA becomes "Merge tags". Resolves to a [TagRenameOutcome]
/// on confirm, or `null` on cancel.
Future<TagRenameOutcome?> showTagRenameDialog(
  BuildContext context, {
  required String currentName,
  required Set<String> existingNames,
}) => showMxDialog<TagRenameOutcome>(
  context,
  builder: (BuildContext context) => _TagRenameDialog(
    currentName: currentName,
    existingLower: <String>{
      for (final String n in existingNames) StringUtils.caseFold(n),
    }..remove(StringUtils.caseFold(currentName)),
  ),
);

class _TagRenameDialog extends HookWidget {
  const _TagRenameDialog({
    required this.currentName,
    required this.existingLower,
  });

  final String currentName;
  final Set<String> existingLower;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final MxTextSubmitState field = useMxTextSubmitState(
      initialText: currentName,
      // Require a non-empty name that differs from the current (a same-name
      // submit would no-op through a busy overlay — confusing).
      canSubmit: (String trimmed) =>
          trimmed.isNotEmpty &&
          StringUtils.caseFold(trimmed) != StringUtils.caseFold(currentName),
    );

    final String typed = StringUtils.caseFold(field.trimmedText);
    final bool isMerge = typed.isNotEmpty && existingLower.contains(typed);

    void submit() {
      if (!field.canSubmit) return;
      Navigator.of(context).pop((name: field.trimmedText, merge: isMerge));
    }

    return MxDialog(
      title: l10n.tagManagementRenameTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MxTextField(
            controller: field.controller,
            labelText: l10n.tagManagementRenameFieldLabel,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
          ),
          if (isMerge) ...<Widget>[
            const SizedBox(height: MxSpacing.space3),
            Container(
              padding: const EdgeInsets.all(MxSpacing.space3),
              decoration: BoxDecoration(
                color: colors.warn.withValues(alpha: MxOpacity.selected),
                borderRadius: MxRadius.mdAll,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.merge_outlined,
                    color: colors.warn,
                    size: MxIconSize.sm,
                  ),
                  const SizedBox(width: MxSpacing.space2),
                  Expanded(
                    child: MxText(
                      l10n.tagManagementMergePrompt(field.trimmedText),
                      role: MxTextRole.bodySmall,
                      color: colors.warn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        MxSecondaryButton(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MxPrimaryButton(
          label: isMerge
              ? l10n.tagManagementMergeConfirm
              : l10n.tagManagementRenameConfirm,
          icon: isMerge ? Icons.merge_outlined : Icons.check,
          onPressed: field.canSubmit ? submit : null,
        ),
      ],
    );
  }
}
