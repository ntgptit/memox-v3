import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';

/// The user's card content: a required [front] and [back]. Optional notes/tags
/// land with the full editor (WBS 2.11.2). WBS 3.4.2.
typedef CardDraft = ({String front, String back});

/// Shows the add/edit-card dialog. When [existing] is supplied the fields are
/// pre-filled (edit); otherwise it is an add dialog. Resolves to the trimmed
/// [CardDraft] on confirm, or `null` on cancel. Front/back required-after-trim
/// validation also lives in the use case. WBS 3.4.2.
Future<CardDraft?> showCardDialog(
  BuildContext context, {
  Flashcard? existing,
}) => showMxDialog<CardDraft>(
  context,
  builder: (BuildContext context) => _CardDialog(existing: existing),
);

class _CardDialog extends HookWidget {
  const _CardDialog({this.existing});

  final Flashcard? existing;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxTextSubmitState front = useMxTextSubmitState(
      initialText: existing?.front ?? '',
    );
    final MxTextSubmitState back = useMxTextSubmitState(
      initialText: existing?.back ?? '',
    );
    final bool canSubmit = front.canSubmit && back.canSubmit;

    void submit() {
      if (!canSubmit) return;
      Navigator.of(
        context,
      ).pop((front: front.trimmedText, back: back.trimmedText));
    }

    return MxDialog(
      title: existing == null ? l10n.cardCreateTitle : l10n.cardEditTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxTextField(
            controller: front.controller,
            labelText: l10n.cardFrontLabel,
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: MxSpacing.space4),
          MxTextField(
            controller: back.controller,
            labelText: l10n.cardBackLabel,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
          ),
        ],
      ),
      actions: <Widget>[
        MxSecondaryButton(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MxPrimaryButton(
          label: existing == null
              ? l10n.cardCreateConfirm
              : l10n.cardEditConfirm,
          onPressed: canSubmit ? submit : null,
        ),
      ],
    );
  }
}
