import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

/// Deck import route for `/library/deck/:deckId/import`.
///
/// V1 exposes CSV paste input + parse + validation preview only. Commit,
/// file picker, Excel, and structured text remain deferred.
class DeckImportScreen extends StatefulWidget {
  const DeckImportScreen({required this.deckId, super.key});

  final String deckId;

  @override
  State<DeckImportScreen> createState() => _DeckImportScreenState();
}

class _DeckImportScreenState extends State<DeckImportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _csvController = TextEditingController();
  final FocusNode _csvFocusNode = FocusNode();

  _DeckImportCsvPreview? _preview;

  @override
  void dispose() {
    _csvController.dispose();
    _csvFocusNode.dispose();
    super.dispose();
  }

  void _previewCsv() {
    final FormState? formState = _formKey.currentState;
    if (formState != null && !formState.validate()) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    final _DeckImportCsvPreview nextPreview = _parseCsvPreview(
      rawCsv: _csvController.text,
      l10n: l10n,
    );
    setState(() {
      _preview = nextPreview;
    });
  }

  void _clearPreviewOnEdit() {
    if (_preview == null) {
      return;
    }
    setState(() {
      _preview = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hasDeckId = StringUtils.trimmed(widget.deckId).isNotEmpty;
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
          ? _DeckImportBody(
              l10n: l10n,
              formKey: _formKey,
              csvController: _csvController,
              csvFocusNode: _csvFocusNode,
              preview: _preview,
              onPreview: _previewCsv,
              onCsvChanged: (_) => _clearPreviewOnEdit(),
            )
          : _DeckImportMissingDeckState(l10n: l10n, onBack: onBack),
    );
  }
}

class _DeckImportBody extends StatelessWidget {
  const _DeckImportBody({
    required this.l10n,
    required this.formKey,
    required this.csvController,
    required this.csvFocusNode,
    required this.preview,
    required this.onPreview,
    required this.onCsvChanged,
  });

  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final TextEditingController csvController;
  final FocusNode csvFocusNode;
  final _DeckImportCsvPreview? preview;
  final VoidCallback onPreview;
  final ValueChanged<String> onCsvChanged;

  @override
  Widget build(BuildContext context) => ListView(
    children: <Widget>[
      MxCallout(message: l10n.flashcardsImportRouteIntroMessage),
      const SizedBox(height: SpacingTokens.lg),
      MxSectionHeader(label: l10n.importSourceTitle),
      const SizedBox(height: SpacingTokens.sm),
      MxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MxText(l10n.importCsvContentLabel, role: MxTextRole.titleSmall),
            const SizedBox(height: SpacingTokens.xs),
            MxText(
              l10n.importCsvRulesText,
              role: MxTextRole.bodyMedium,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: SpacingTokens.md),
            Form(
              key: formKey,
              child: MxTextField(
                controller: csvController,
                focusNode: csvFocusNode,
                hintText: l10n.importCsvHint,
                minLines: 10,
                maxLines: 12,
                validator: (String? value) {
                  final String trimmed = StringUtils.trimmed(value ?? '');
                  if (trimmed.isEmpty) {
                    return l10n.importCsvEmptyMessage;
                  }
                  return null;
                },
                onChanged: onCsvChanged,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            MxPrimaryButton(
              label: l10n.importPreviewAction,
              fullWidth: true,
              onPressed: onPreview,
            ),
            const SizedBox(height: SpacingTokens.sm),
            MxSecondaryButton(
              label: l10n.importCommitDeferredAction,
              variant: MxSecondaryVariant.outlined,
              fullWidth: true,
              onPressed: null,
            ),
            const SizedBox(height: SpacingTokens.sm),
            MxCallout(message: l10n.importCommitDeferredMessage),
          ],
        ),
      ),
      if (preview != null) ...<Widget>[
        const SizedBox(height: SpacingTokens.lg),
        MxSectionHeader(label: l10n.importPreviewTitle),
        const SizedBox(height: SpacingTokens.sm),
        MxCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MxText(
                l10n.importPreviewSubtitle(preview!.rows.length),
                role: MxTextRole.titleSmall,
              ),
              const SizedBox(height: SpacingTokens.xs),
              MxText(
                l10n.importPreviewSummary(
                  preview!.rows.length,
                  preview!.issues.length,
                ),
                role: MxTextRole.bodyMedium,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        if (preview!.issues.isNotEmpty) ...<Widget>[
          MxSectionHeader(label: l10n.importValidationIssuesTitle),
          const SizedBox(height: SpacingTokens.xs),
          MxCallout(
            tone: MxCalloutTone.warning,
            message: l10n.importValidationIssuesSubtitle,
          ),
          const SizedBox(height: SpacingTokens.sm),
          MxCard(
            child: Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < preview!.issues.length;
                  index++
                ) ...<Widget>[
                  if (index > 0) const SizedBox(height: SpacingTokens.sm),
                  _PreviewIssueTile(issue: preview!.issues[index]),
                ],
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
        if (preview!.rows.isNotEmpty) ...<Widget>[
          MxSectionHeader(label: l10n.importPreviewRowsTitle),
          const SizedBox(height: SpacingTokens.xs),
          MxCard(
            child: Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < preview!.rows.length;
                  index++
                ) ...<Widget>[
                  if (index > 0) const SizedBox(height: SpacingTokens.sm),
                  _PreviewRowTile(row: preview!.rows[index]),
                ],
              ],
            ),
          ),
        ],
        if (preview!.rows.isEmpty && preview!.issues.isEmpty)
          MxEmptyState(
            icon: Icons.inbox_outlined,
            title: l10n.importNothingTitle,
            message: l10n.importNothingMessage,
          ),
      ],
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

class _PreviewRowTile extends StatelessWidget {
  const _PreviewRowTile({required this.row});

  final _DeckImportCsvRow row;

  @override
  Widget build(BuildContext context) => MxListTile(
    leading: MxText(
      AppLocalizations.of(context).importValidationIssueLine(row.lineNumber),
      role: MxTextRole.labelMedium,
      color: context.colorScheme.onSurfaceVariant,
    ),
    title: row.front,
    subtitle: row.back,
  );
}

class _PreviewIssueTile extends StatelessWidget {
  const _PreviewIssueTile({required this.issue});

  final _DeckImportIssue issue;

  @override
  Widget build(BuildContext context) => MxListTile(
    leading: Icon(Icons.error_outline, color: context.colorScheme.error),
    title: issue.lineLabel(context),
    subtitle: issue.message,
  );
}

class _DeckImportCsvPreview {
  const _DeckImportCsvPreview({required this.rows, required this.issues});

  final List<_DeckImportCsvRow> rows;
  final List<_DeckImportIssue> issues;
}

class _DeckImportCsvRow {
  const _DeckImportCsvRow({
    required this.lineNumber,
    required this.front,
    required this.back,
  });

  final int lineNumber;
  final String front;
  final String back;
}

class _DeckImportIssue {
  const _DeckImportIssue({required this.lineNumber, required this.message});

  final int lineNumber;
  final String message;

  String lineLabel(BuildContext context) =>
      AppLocalizations.of(context).importValidationIssueLine(lineNumber);
}

class _CsvRecord {
  const _CsvRecord({required this.lineNumber, required this.cells});

  final int lineNumber;
  final List<String> cells;
}

_DeckImportCsvPreview _parseCsvPreview({
  required String rawCsv,
  required AppLocalizations l10n,
}) {
  final List<_CsvRecord> records = _parseCsvRecords(rawCsv);
  if (records.isEmpty) {
    return const _DeckImportCsvPreview(
      rows: <_DeckImportCsvRow>[],
      issues: <_DeckImportIssue>[],
    );
  }

  int startIndex = 0;
  if (_looksLikeHeader(records.first.cells)) {
    startIndex = 1;
  }

  final List<_DeckImportCsvRow> rows = <_DeckImportCsvRow>[];
  final List<_DeckImportIssue> issues = <_DeckImportIssue>[];
  for (int index = startIndex; index < records.length; index++) {
    final _CsvRecord record = records[index];
    final List<String> trimmedCells = record.cells
        .map(StringUtils.trimmed)
        .toList(growable: false);
    final bool isBlankRow = trimmedCells.every((String cell) => cell.isEmpty);
    if (isBlankRow) {
      continue;
    }

    final String front = trimmedCells.isNotEmpty ? trimmedCells.first : '';
    final String back = trimmedCells.length > 1 ? trimmedCells[1] : '';

    if (front.isEmpty && back.isEmpty) {
      issues.add(
        _DeckImportIssue(
          lineNumber: record.lineNumber,
          message: l10n.importCsvFrontAndBackRequiredMessage,
        ),
      );
      continue;
    }
    if (front.isEmpty) {
      issues.add(
        _DeckImportIssue(
          lineNumber: record.lineNumber,
          message: l10n.flashcardEditorFrontError,
        ),
      );
      continue;
    }
    if (back.isEmpty) {
      issues.add(
        _DeckImportIssue(
          lineNumber: record.lineNumber,
          message: l10n.flashcardEditorBackError,
        ),
      );
      continue;
    }

    rows.add(
      _DeckImportCsvRow(
        lineNumber: record.lineNumber,
        front: front,
        back: back,
      ),
    );
  }

  return _DeckImportCsvPreview(rows: rows, issues: issues);
}

List<_CsvRecord> _parseCsvRecords(String rawCsv) {
  final String normalized = rawCsv
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  final List<_CsvRecord> records = <_CsvRecord>[];
  List<String> currentRow = <String>[];
  StringBuffer currentField = StringBuffer();
  bool inQuotes = false;
  bool hasRecordContent = false;
  int lineNumber = 1;
  int recordStartLine = 1;

  void finishField() {
    currentRow = <String>[...currentRow, currentField.toString()];
    currentField = StringBuffer();
  }

  void finishRecord() {
    records.add(
      _CsvRecord(
        lineNumber: recordStartLine,
        cells: List<String>.unmodifiable(currentRow),
      ),
    );
    currentRow = <String>[];
    currentField = StringBuffer();
    hasRecordContent = false;
  }

  for (int index = 0; index < normalized.length; index++) {
    final String char = normalized[index];

    if (!hasRecordContent) {
      recordStartLine = lineNumber;
      if (char != '\n') {
        hasRecordContent = true;
      }
    }

    if (inQuotes) {
      if (char == '"') {
        final bool isEscapedQuote =
            index + 1 < normalized.length && normalized[index + 1] == '"';
        if (isEscapedQuote) {
          currentField.write('"');
          index++;
          continue;
        }
        inQuotes = false;
        continue;
      }

      currentField.write(char);
      if (char == '\n') {
        lineNumber++;
      }
      continue;
    }

    if (char == '"') {
      if (currentField.isEmpty) {
        inQuotes = true;
        continue;
      }
      currentField.write(char);
      continue;
    }
    if (char == ',') {
      finishField();
      continue;
    }
    if (char == '\n') {
      finishField();
      finishRecord();
      lineNumber++;
      continue;
    }

    currentField.write(char);
  }

  if (normalized.isNotEmpty &&
      (hasRecordContent || currentField.isNotEmpty || currentRow.isNotEmpty)) {
    finishField();
    finishRecord();
  }

  return records;
}

bool _looksLikeHeader(List<String> cells) {
  if (cells.length < 2) {
    return false;
  }
  return StringUtils.equalsIgnoreCase(StringUtils.trimmed(cells[0]), 'front') &&
      StringUtils.equalsIgnoreCase(StringUtils.trimmed(cells[1]), 'back');
}
