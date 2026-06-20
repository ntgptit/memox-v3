import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';

/// Shows the rename-folder dialog pre-filled with [currentName] and resolves to
/// the trimmed new name on confirm, or `null` on cancel / dismiss. Empty /
/// duplicate / no-op rules live in the use case (failures surface as a
/// snackbar). WBS 2.2.2.
Future<String?> showFolderRenameDialog(
  BuildContext context, {
  required String currentName,
}) => showMxDialog<String>(
  context,
  builder: (BuildContext context) =>
      _FolderRenameDialog(currentName: currentName),
);

class _FolderRenameDialog extends HookWidget {
  const _FolderRenameDialog({required this.currentName});

  final String currentName;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxTextSubmitState field = useMxTextSubmitState(
      initialText: currentName,
    );
    void submit() {
      if (!field.canSubmit) return;
      Navigator.of(context).pop(field.trimmedText);
    }

    return MxDialog(
      title: l10n.folderRenameTitle,
      content: MxTextField(
        controller: field.controller,
        labelText: l10n.folderRenameFieldLabel,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => submit(),
      ),
      actions: <Widget>[
        MxSecondaryButton(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MxPrimaryButton(
          label: l10n.folderRenameConfirm,
          onPressed: field.canSubmit ? submit : null,
        ),
      ],
    );
  }
}
