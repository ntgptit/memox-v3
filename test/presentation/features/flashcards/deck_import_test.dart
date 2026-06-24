import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/flashcard_import_duplicate.dart';
import 'package:memox/domain/types/import_row_issue_type.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_controller.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_state.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';

import '../../../support/golden_harness.dart';

const String _deckId = 'd1';

class _FakeImportController extends DeckImportController {
  _FakeImportController(this._initial);
  final DeckImportState _initial;
  @override
  DeckImportState build(String deckId) => _initial;
}

FlashcardImportRow _row(int line, String f, String b) =>
    FlashcardImportRow(lineNumber: line, front: f, back: b);

DeckImportState _previewAllValid() {
  final List<FlashcardImportRow> rows = <FlashcardImportRow>[
    _row(1, '日本', 'Japan'),
    _row(2, '日曜日', 'Sunday'),
    _row(3, '水', 'water'),
  ];
  return DeckImportState.preview(
    fileName: 'japanese-n5.csv',
    foundCount: rows.length,
    preview: FlashcardImportPreview(rows: rows),
    preparation: FlashcardImportPreparation(previewItems: rows),
  );
}

DeckImportState _previewMixed() {
  final FlashcardImportRow v1 = _row(1, '日本', 'Japan');
  final FlashcardImportRow v2 = _row(2, '日曜日', 'Sunday');
  final FlashcardImportRow v4 = _row(4, '水', 'water');
  final FlashcardImportRow dup = _row(5, '本', 'book');
  return DeckImportState.preview(
    fileName: 'japanese-n5.csv',
    foundCount: 5,
    preview: FlashcardImportPreview(
      rows: <FlashcardImportRow>[v1, v2, v4, dup],
      issues: const <ImportValidationIssue>[
        ImportValidationIssue(
          kind: ImportRowIssueType.missingFront,
          lineNumber: 3,
          message: 'Line 3: front is required.',
        ),
      ],
    ),
    preparation: FlashcardImportPreparation(
      previewItems: <FlashcardImportRow>[v1, v2, v4],
      skippedDuplicates: const <FlashcardImportSkippedDuplicate>[
        FlashcardImportSkippedDuplicate(
          lineNumber: 5,
          front: '本',
          back: 'book',
          source: FlashcardImportDuplicateSource.deck,
        ),
      ],
    ),
  );
}

FlashcardListDetail _deckDetail() {
  final DateTime t = DateTime(2026, 1, 1);
  return FlashcardListDetail(
    deck: Deck(
      id: _deckId,
      folderId: 'f1',
      name: 'Japanese · N5',
      targetLanguage: TargetLanguage.english,
      sortOrder: 0,
      createdAt: t,
      updatedAt: t,
    ),
    breadcrumb: const <Folder>[],
    cards: const <Flashcard>[],
    totalCount: 0,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required DeckImportState state,
  Brightness brightness = Brightness.light,
  bool golden = false,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deckImportControllerProvider(
          _deckId,
        ).overrideWith(() => _FakeImportController(state)),
        flashcardListStreamProvider(_deckId).overrideWith(
          (ref) => Stream<Result<FlashcardListDetail>>.value((
            failure: null,
            data: _deckDetail(),
          )),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DeckImportScreen(deckId: _deckId),
      ),
    ),
  );
}

void main() {
  group('DeckImportScreen states', () {
    testWidgets('empty shows the choose-file prompt', (tester) async {
      await _pump(tester, state: const DeckImportState.empty());
      await tester.pumpAndSettle();
      expect(find.text('Import cards from a file'), findsOneWidget);
      expect(find.text('Choose file'), findsOneWidget);
    });

    testWidgets('preview-mixed shows the summary + skip warning + commit', (
      tester,
    ) async {
      await _pump(tester, state: _previewMixed());
      await tester.pumpAndSettle();
      expect(find.text('5 found · 3 valid · 2 to skip'), findsOneWidget);
      expect(find.text('Import 3 valid cards'), findsOneWidget);
      expect(find.textContaining('will be skipped'), findsOneWidget);
    });

    testWidgets('success names the destination deck', (tester) async {
      await _pump(tester, state: const DeckImportState.success(count: 142));
      await tester.pumpAndSettle();
      expect(find.text('142 cards imported'), findsOneWidget);
      expect(find.textContaining('Japanese · N5'), findsOneWidget);
      expect(find.text('Open deck'), findsOneWidget);
    });

    testWidgets('failed shows the retry actions', (tester) async {
      await _pump(tester, state: const DeckImportState.failed());
      await tester.pumpAndSettle();
      expect(find.text('Import failed'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Choose another file'), findsOneWidget);
    });
  });

  group('DeckImportScreen goldens', () {
    final Map<String, DeckImportState> cases = <String, DeckImportState>{
      'empty': const DeckImportState.empty(),
      'file-selected': const DeckImportState.fileSelected(
        fileName: 'japanese-n5.csv',
        sizeBytes: 25190,
        rawText: '',
      ),
      'parsing': const DeckImportState.parsing(),
      'preview-all-valid': _previewAllValid(),
      'preview-mixed': _previewMixed(),
      'importing': const DeckImportState.importing(),
      'success': const DeckImportState.success(count: 142),
      'partial': const DeckImportState.partial(imported: 118, skipped: 24),
      'failed': const DeckImportState.failed(),
    };
    for (final MapEntry<String, DeckImportState> entry in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${entry.key} — ${brightness.name}', (tester) async {
          await _pump(
            tester,
            state: entry.value,
            brightness: brightness,
            golden: true,
          );
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(DeckImportScreen),
            matchesGoldenFile(
              'goldens/deck_import_${entry.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }
  });
}
