import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

/// Deck import route shell for `/library/deck/:deckId/import`.
///
/// V1 intentionally stops at the controlled route shell. Parsing, file picker,
/// preview, and commit are deferred to the next import slice.
class DeckImportScreen extends StatelessWidget {
  const DeckImportScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hasDeckId = StringUtils.trimmed(deckId).isNotEmpty;
    void onBack() => Navigator.of(context).pop();

    return MxScaffold(
      appBar: MxAppBar(
        leading: MxIconButton(
          icon: Icons.arrow_back,
          tooltip: l10n.commonBack,
          onPressed: onBack,
        ),
        titleText: l10n.flashcardsImportTitle,
      ),
      body: hasDeckId
          ? _DeckImportShell(l10n: l10n)
          : _DeckImportMissingDeckState(l10n: l10n, onBack: onBack),
    );
  }
}

class _DeckImportShell extends StatelessWidget {
  const _DeckImportShell({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => ListView(
    children: <Widget>[
      MxCallout(message: l10n.flashcardsImportRouteIntroMessage),
      const SizedBox(height: SpacingTokens.lg),
      MxSectionHeader(label: l10n.flashcardsImportFormatsSectionTitle),
      const SizedBox(height: SpacingTokens.sm),
      _DeckImportSourceCard(
        title: l10n.importCsvLabel,
        message: l10n.flashcardsImportSoonMessage,
      ),
      const SizedBox(height: SpacingTokens.sm),
      _DeckImportSourceCard(
        title: l10n.importExcelLabel,
        message: l10n.flashcardsImportSoonMessage,
      ),
      const SizedBox(height: SpacingTokens.sm),
      _DeckImportSourceCard(
        title: l10n.importTextContentLabel,
        message: l10n.flashcardsImportSoonMessage,
      ),
    ],
  );
}

class _DeckImportMissingDeckState extends StatelessWidget {
  const _DeckImportMissingDeckState({required this.l10n, required this.onBack});

  final AppLocalizations l10n;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => ListView(
    children: <Widget>[
      MxCallout(
        tone: MxCalloutTone.danger,
        message: l10n.flashcardsImportMissingDeckMessage,
      ),
      const SizedBox(height: SpacingTokens.lg),
      MxSecondaryButton(
        label: l10n.commonBack,
        variant: MxSecondaryVariant.outlined,
        size: MxButtonSize.medium,
        fullWidth: true,
        onPressed: onBack,
      ),
    ],
  );
}

class _DeckImportSourceCard extends StatelessWidget {
  const _DeckImportSourceCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.textTheme;
    final ColorScheme scheme = context.colorScheme;
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: text.titleMedium),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            message,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
