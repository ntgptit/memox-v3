import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_controller.dart';
import 'package:memox/presentation/features/flashcards/controllers/deck_import_state.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';

import '../../../support/parity_contract.dart';

const String _deckId = 'd1';

class _FakeImportController extends DeckImportController {
  _FakeImportController(this._initial);
  final DeckImportState _initial;
  @override
  DeckImportState build(String deckId) => _initial;
}

Finder _node(String id) => find.byKey(ValueKey<String>('mx-node:$id'));

Future<void> _pump(WidgetTester tester, DeckImportState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deckImportControllerProvider(
          _deckId,
        ).overrideWith(() => _FakeImportController(state)),
        flashcardListStreamProvider(_deckId).overrideWith(
          (ref) => const Stream<Result<FlashcardListDetail>>.empty(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: MxTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DeckImportScreen(deckId: _deckId),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}

// The four required nodes live in different wizard states; each is asserted in
// the state where the design places it.
void main() {
  testWidgets('10-deck-import: empty-card node', (tester) async {
    await _pump(tester, const DeckImportState.empty());
    expectParityContract('10-deck-import', <String, Finder>{
      'empty card': _node('10-deck-import/empty-card'),
      'choose-file button': _node('10-deck-import/choose-file'),
    });
  });

  testWidgets('10-deck-import: file-chip node', (tester) async {
    await _pump(
      tester,
      const DeckImportState.fileSelected(
        fileName: 'a.csv',
        sizeBytes: 10,
        rawText: '',
      ),
    );
    expectParityContract('10-deck-import', <String, Finder>{
      'file chip': _node('10-deck-import/file-chip'),
    });
  });

  testWidgets('10-deck-import: preview-list node', (tester) async {
    await _pump(
      tester,
      const DeckImportState.preview(
        fileName: 'a.csv',
        foundCount: 1,
        preview: FlashcardImportPreview(
          rows: <FlashcardImportRow>[
            FlashcardImportRow(lineNumber: 1, front: 'f', back: 'b'),
          ],
        ),
        preparation: FlashcardImportPreparation(
          previewItems: <FlashcardImportRow>[
            FlashcardImportRow(lineNumber: 1, front: 'f', back: 'b'),
          ],
        ),
      ),
    );
    expectParityContract('10-deck-import', <String, Finder>{
      'preview list': _node('10-deck-import/preview-list'),
    });
  });

  testWidgets('10-deck-import: result-card node', (tester) async {
    await _pump(tester, const DeckImportState.success(count: 1));
    expectParityContract('10-deck-import', <String, Finder>{
      'result card': _node('10-deck-import/result-card'),
    });
  });

  testWidgets(
    '10-deck-import binding contract (keyed nodes realize kit components)',
    (tester) async {
      // The four concrete-component nodes live in different wizard states; pump each
      // and assert — the helper skips nodes absent in the pumped state. empty-card /
      // file-chip / result-card → MxCard, choose-file → MxPrimaryButton (preview-list
      // is a content container with no kit component → skipped).
      await _pump(tester, const DeckImportState.empty());
      expectGeneratedBindingContract('10-deck-import');
      await _pump(
        tester,
        const DeckImportState.fileSelected(
          fileName: 'a.csv',
          sizeBytes: 10,
          rawText: '',
        ),
      );
      expectGeneratedBindingContract('10-deck-import');
      await _pump(tester, const DeckImportState.success(count: 1));
      expectGeneratedBindingContract('10-deck-import');
    },
  );
}
