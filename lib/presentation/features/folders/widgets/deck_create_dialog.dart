import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_dialog.dart';
import 'package:memox/presentation/shared/hooks/mx_text_controller_hooks.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// The user's create-deck choices: a required [name] and a [targetLanguage]
/// (front-field language; gates TTS). WBS 2.7.2.
typedef DeckDraft = ({String name, TargetLanguage targetLanguage});

/// User-selectable deck languages (the `unsupported` enum value is never
/// offered as a choice).
const List<TargetLanguage> _languageChoices = <TargetLanguage>[
  TargetLanguage.korean,
  TargetLanguage.english,
];

/// Shows the create-deck dialog (name + target-language choice) and resolves to
/// the chosen [DeckDraft] on confirm, or `null` on cancel. Name validation +
/// duplicate rules live in the use case. WBS 2.7.2.
Future<DeckDraft?> showDeckCreateDialog(BuildContext context) =>
    showMxDialog<DeckDraft>(
      context,
      builder: (BuildContext context) => const _DeckCreateDialog(),
    );

class _DeckCreateDialog extends HookWidget {
  const _DeckCreateDialog();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    final MxTextSubmitState field = useMxTextSubmitState();
    final ValueNotifier<TargetLanguage> language = useState<TargetLanguage>(
      TargetLanguage.korean,
    );

    void submit() {
      if (!field.canSubmit) return;
      Navigator.of(
        context,
      ).pop((name: field.trimmedText, targetLanguage: language.value));
    }

    return MxDialog(
      title: l10n.deckCreateTitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxTextField(
            controller: field.controller,
            labelText: l10n.deckCreateNameLabel,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
          ),
          const SizedBox(height: MxSpacing.space5),
          MxText(
            l10n.deckCreateLanguageLabel,
            role: MxTextRole.labelMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: MxSpacing.space2),
          Wrap(
            spacing: MxSpacing.space2,
            children: <Widget>[
              for (final TargetLanguage lang in _languageChoices)
                MxSecondaryButton(
                  label: _languageLabel(l10n, lang),
                  variant: language.value == lang
                      ? MxSecondaryVariant.tonal
                      : MxSecondaryVariant.outlined,
                  onPressed: () => language.value = lang,
                ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        MxSecondaryButton(
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MxPrimaryButton(
          label: l10n.deckCreateConfirm,
          onPressed: field.canSubmit ? submit : null,
        ),
      ],
    );
  }

  String _languageLabel(AppLocalizations l10n, TargetLanguage lang) =>
      switch (lang) {
        TargetLanguage.korean => l10n.deckLanguageKorean,
        TargetLanguage.english => l10n.deckLanguageEnglish,
        TargetLanguage.unsupported => l10n.deckLanguageKorean,
      };
}
