import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/controllers/flashcard_action_controller.dart';
import 'package:memox/presentation/features/decks/screens/flashcard_editor_screen.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';

import '../../../support/golden_harness.dart';
import '../../../support/structural_dump.dart';

/// Stubs the action controller so the editor's save in-flight / failure paths
/// are deterministic: [failure] makes save fail (drives the inline banner);
/// [autoGate] holds every call mid-flight (drives the Saving spinner) until the
/// gate is completed. The provider is autoDispose, so the override factory must
/// build a FRESH instance per call — gates are reported to [gateSink] (a shared
/// sink) rather than held on the instance, so retries stay inspectable.
class _StubActionController extends FlashcardActionController {
  _StubActionController({
    this.failure,
    this.autoGate = false,
    this.gateSink,
    this.tagsSink,
  });

  final Failure? failure;
  final bool autoGate;
  final void Function(Completer<void> gate)? gateSink;

  /// Reports the tag set passed to create / update (a shared sink, like
  /// [gateSink], so it survives the autoDispose fresh-instance-per-call rule).
  final void Function(List<String> tags)? tagsSink;

  Future<Result<Flashcard>> _result() async {
    if (autoGate) {
      final Completer<void> gate = Completer<void>();
      gateSink?.call(gate);
      await gate.future;
    }
    if (failure != null) return (failure: failure, data: null);
    return (failure: null, data: _card());
  }

  @override
  Future<Result<Flashcard>> create({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) {
    tagsSink?.call(tags);
    return _result();
  }

  @override
  Future<Result<Flashcard>> update({
    required FlashcardId flashcardId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) {
    tagsSink?.call(tags);
    return _result();
  }
}

const String _deckId = 'deck1';
final DateTime _t = DateTime.utc(2026);

final Deck _deck = Deck(
  id: _deckId,
  folderId: 'f1',
  name: 'Japanese · N5',
  targetLanguage: TargetLanguage.korean,
  sortOrder: 0,
  createdAt: _t,
  updatedAt: _t,
);

Flashcard _card({
  String? exampleSentence,
  String? pronunciation,
  String? hint,
  List<String> tags = const <String>[],
}) => Flashcard(
  id: 'c1',
  deckId: _deckId,
  front: '日本',
  back: 'Japan',
  exampleSentence: exampleSentence,
  pronunciation: pronunciation,
  hint: hint,
  tags: tags,
  sortOrder: 0,
  createdAt: _t,
  updatedAt: _t,
);

FlashcardListDetail _detail({List<Flashcard> cards = const <Flashcard>[]}) =>
    FlashcardListDetail(
      deck: _deck,
      breadcrumb: <Folder>[
        Folder(
          id: 'f1',
          parentId: null,
          name: 'Languages',
          contentMode: ContentMode.decks,
          sortOrder: 0,
          createdAt: _t,
          updatedAt: _t,
        ),
      ],
      cards: cards,
      totalCount: cards.length,
    );

Future<void> _pump(
  WidgetTester tester, {
  String? cardId,
  List<Flashcard> cards = const <Flashcard>[],
  Brightness brightness = Brightness.light,
  bool golden = false,
  bool loading = false,
  bool loadError = false,
  FlashcardActionController Function()? controller,
}) async {
  if (golden) {
    tester.view.physicalSize = kGoldenSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  // A never-completing stream holds the editor in its loading state; a failure
  // record (`data == null`) drives the load-error surface.
  Stream<Result<FlashcardListDetail>> source() {
    if (loading) {
      return Stream<Result<FlashcardListDetail>>.fromFuture(
        Completer<Result<FlashcardListDetail>>().future,
      );
    }
    if (loadError) {
      return Stream<Result<FlashcardListDetail>>.value((
        failure: const Failure.storage(
          operation: StorageOp.read,
          cause: 'offline',
        ),
        data: null,
      ));
    }
    return Stream<Result<FlashcardListDetail>>.value((
      failure: null,
      data: _detail(cards: cards),
    ));
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        flashcardListStreamProvider(_deckId).overrideWith((ref) => source()),
        if (controller != null)
          flashcardActionControllerProvider.overrideWith(controller),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FlashcardEditorScreen(deckId: _deckId, cardId: cardId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

bool _saveEnabled(WidgetTester tester) =>
    tester.widget<MxPrimaryButton>(find.byType(MxPrimaryButton)).onPressed !=
    null;

void main() {
  group('FlashcardEditorScreen', () {
    testWidgets('create: empty fields, Add title, Save disabled until filled', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('Add card'), findsOneWidget); // app-bar title
      // Front + Back present; Details collapsed so the optional fields are not.
      expect(find.widgetWithText(MxTextField, 'Front'), findsOneWidget);
      expect(find.widgetWithText(MxTextField, 'Back'), findsOneWidget);
      expect(find.text('Example'), findsNothing);
      expect(_saveEnabled(tester), isFalse); // front+back empty

      // Front alone is not enough — back is also required.
      await tester.enterText(find.byType(MxTextField).first, 'neko');
      await tester.pump();
      expect(_saveEnabled(tester), isFalse);

      await tester.enterText(find.byType(MxTextField).last, 'cat');
      await tester.pump();
      expect(_saveEnabled(tester), isTrue);
    });

    testWidgets('edit: fields pre-filled from the card, Edit title', (
      tester,
    ) async {
      await _pump(tester, cardId: 'c1', cards: <Flashcard>[_card()]);
      expect(find.text('Edit card'), findsOneWidget);
      expect(find.text('日本'), findsOneWidget); // front prefilled
      expect(find.text('Japan'), findsOneWidget); // back prefilled
      expect(_saveEnabled(tester), isTrue); // prefilled → valid
    });

    testWidgets('create: a dirty draft shows the discard confirm on close', (
      tester,
    ) async {
      await _pump(tester);
      await tester.enterText(find.byType(MxTextField).first, 'neko');
      await tester.pump();
      // Tapping X with unsaved edits opens the discard-changes confirm (mock
      // `07`/`08` Rules), not an immediate pop.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
    });

    testWidgets(
      'create: Details collapsed by default; tap expands the fields',
      (tester) async {
        await _pump(tester);
        expect(find.text('Details'), findsOneWidget);
        // Collapsed: the optional fields are not built.
        expect(find.text('Example'), findsNothing);
        expect(find.text('Hint'), findsNothing);

        await tester.tap(find.text('Details'));
        await tester.pumpAndSettle();
        // Expanded: example / pronunciation / hint fields appear.
        expect(find.text('Example'), findsOneWidget);
        expect(find.text('Pronunciation'), findsOneWidget);
        expect(find.text('Hint'), findsOneWidget);
      },
    );

    testWidgets('edit: a card with details auto-opens the expander prefilled', (
      tester,
    ) async {
      await _pump(
        tester,
        cardId: 'c1',
        cards: <Flashcard>[_card(exampleSentence: '日本へ行く', hint: 'country')],
      );
      // Auto-opened (the card has details) with the values prefilled.
      expect(find.text('日本へ行く'), findsOneWidget);
      expect(find.text('country'), findsOneWidget);
    });

    testWidgets('edit: existing tags prefilled as chips + Details auto-opens', (
      tester,
    ) async {
      await _pump(
        tester,
        cardId: 'c1',
        cards: <Flashcard>[
          _card(tags: <String>['kanji', 'n5']),
        ],
      );
      // Tags alone auto-open Details; each renders as a chip.
      expect(find.text('kanji'), findsOneWidget);
      expect(find.text('n5'), findsOneWidget);
    });

    testWidgets('add a tag: open the field, type + submit → lowercased chip', (
      tester,
    ) async {
      await _pump(tester, cardId: 'c1', cards: <Flashcard>[_card()]);
      await tester.tap(find.text('Details')); // collapsed for a plain card
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add tag')); // open the inline field
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey<String>('card_tag_input')),
        'Kanji',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('kanji'), findsOneWidget); // normalized lowercased
    });

    testWidgets('add tag: a comma is rejected (no chip)', (tester) async {
      await _pump(tester, cardId: 'c1', cards: <Flashcard>[_card()]);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add tag'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey<String>('card_tag_input')),
        'a,b',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('a,b'), findsNothing); // validation rejected it
    });

    testWidgets('remove a tag: tapping ✕ drops the chip', (tester) async {
      await _pump(
        tester,
        cardId: 'c1',
        cards: <Flashcard>[
          _card(tags: <String>['verb']),
        ],
      );
      expect(find.text('verb'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close)); // the chip's remove ✕
      await tester.pumpAndSettle();
      expect(find.text('verb'), findsNothing);
    });

    testWidgets('edit: removing a tag dirties the form → discard confirm', (
      tester,
    ) async {
      await _pump(
        tester,
        cardId: 'c1',
        cards: <Flashcard>[
          _card(tags: <String>['verb']),
        ],
      );
      await tester.tap(find.byIcon(Icons.close)); // remove the only tag → dirty
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back)); // edit-mode leading
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
    });

    testWidgets('save passes the full tag set to the use case', (tester) async {
      final List<String> captured = <String>[];
      await _pump(
        tester,
        cardId: 'c1',
        cards: <Flashcard>[
          _card(tags: <String>['verb']),
        ],
        // A failing save captures the tags (the sink fires before the result)
        // without popping — the editor has no router in this harness.
        controller: () => _StubActionController(
          failure: const Failure.storage(
            operation: StorageOp.write,
            cause: 'disk full',
          ),
          tagsSink: (List<String> t) => captured
            ..clear()
            ..addAll(t),
        ),
      );
      // Add a second tag, then save → the use case gets both (tags replace).
      await tester.tap(find.text('Add tag'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey<String>('card_tag_input')),
        'grammar',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MxPrimaryButton).first); // Save
      await tester.pumpAndSettle();
      expect(captured, <String>['verb', 'grammar']);
    });

    testWidgets('create mode has no trash/delete action (mock `07`)', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('edit: trash action opens the delete confirm (mock `08`)', (
      tester,
    ) async {
      await _pump(tester, cardId: 'c1', cards: <Flashcard>[_card()]);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      // Tapping the trash opens the destructive delete confirm, reusing the
      // shared card-delete copy.
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Delete this card?'), findsOneWidget);
    });

    testWidgets('edit: a missing card id shows the load-error surface', (
      tester,
    ) async {
      await _pump(tester, cardId: 'gone'); // not in (empty) cards
      expect(find.byType(MxTextField), findsNothing);
      expect(find.text('Edit card'), findsOneWidget); // shell app bar title
      // The mock `08` load-error copy + a Retry action (C28).
      expect(find.text("Couldn't load card"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('loading: a field-shaped skeleton, no fields yet', (
      tester,
    ) async {
      await _pump(tester, cardId: 'c1', loading: true);
      // The deck/card stream has not resolved: the skeleton stands in for the
      // fields (mock `07`/`08` Loading), and no real inputs are built.
      expect(
        find.byKey(const ValueKey<String>('flashcard_editor_skeleton')),
        findsOneWidget,
      );
      expect(find.byType(MxTextField), findsNothing);
      expect(find.text('Edit card'), findsOneWidget); // shell app bar title
    });

    testWidgets('load error: Retry re-subscribes the stream', (tester) async {
      await _pump(tester, cardId: 'c1', loadError: true);
      expect(find.text("Couldn't load card"), findsOneWidget);
      expect(find.byType(MxTextField), findsNothing);
      // Retry re-runs the fetch (ref.invalidate); tapping must not throw.
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
    });

    testWidgets('save in-flight: Save shows a spinner and is disabled', (
      tester,
    ) async {
      await _pump(
        tester,
        cardId: 'c1',
        cards: <Flashcard>[_card()],
        controller: () => _StubActionController(autoGate: true),
      );
      // Tapping Save kicks off the gated save; it stays in-flight while the
      // completer is unresolved (mock `07`/`08` Saving).
      await tester.tap(find.byType(MxPrimaryButton));
      await tester.pump();
      final MxPrimaryButton save = tester.widget<MxPrimaryButton>(
        find.byType(MxPrimaryButton),
      );
      expect(save.loading, isTrue); // spinner shown, taps ignored mid-flight
    });

    testWidgets('save failed: an inline banner appears and the draft is kept', (
      tester,
    ) async {
      await _pump(
        tester,
        cardId: 'c1',
        cards: <Flashcard>[_card()],
        controller: () => _StubActionController(
          failure: const Failure.storage(
            operation: StorageOp.write,
            cause: 'disk full',
          ),
        ),
      );
      await tester.tap(find.byType(MxPrimaryButton).first);
      await tester.pumpAndSettle();
      // The failure surfaces as an inline danger banner (mock `07`/`08`
      // Save-failed), replacing the snackbar, with a Retry action.
      expect(find.text("Changes couldn't be saved."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      // The draft is preserved so the user can resubmit.
      expect(find.text('日本'), findsOneWidget);
      expect(find.text('Japan'), findsOneWidget);
    });

    testWidgets('save failed then Retry: the banner clears and save re-runs', (
      tester,
    ) async {
      final List<Completer<void>> gates = <Completer<void>>[];
      await _pump(
        tester,
        cardId: 'c1',
        cards: <Flashcard>[_card()],
        controller: () => _StubActionController(
          failure: const Failure.storage(
            operation: StorageOp.write,
            cause: 'disk full',
          ),
          autoGate: true, // a fresh gate per call so the retry is inspectable
          gateSink: gates.add,
        ),
      );
      // First save: in-flight while gated (C45), then resolves to a failure →
      // the inline banner with Retry appears.
      await tester.tap(find.byType(MxPrimaryButton).first);
      await tester.pump();
      gates.last.complete();
      await tester.pumpAndSettle();
      expect(find.text("Changes couldn't be saved."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Tapping Retry re-enters save(): the banner clears immediately
      // (`saveFailed` reset) and the next call is in-flight (still gated), so
      // the banner stays gone until that call resolves.
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.text("Changes couldn't be saved."), findsNothing);
      expect(
        tester
            .widget<MxPrimaryButton>(find.byType(MxPrimaryButton).first)
            .loading,
        isTrue,
      );
      // Let the retry resolve (still failing) → the banner returns.
      gates.last.complete();
      await tester.pumpAndSettle();
      expect(find.text("Changes couldn't be saved."), findsOneWidget);
    });
  });

  group('FlashcardEditorScreen goldens', () {
    testWidgets('create-empty — light', (tester) async {
      await _pump(tester, golden: true);
      await expectLater(
        find.byType(FlashcardEditorScreen),
        matchesGoldenFile('goldens/flashcard_editor_create-empty__light.png'),
      );
      await dumpStructure(tester, 'flashcard_editor_create-empty__light');
    });

    testWidgets('create-empty — dark', (tester) async {
      await _pump(tester, brightness: Brightness.dark, golden: true);
      await expectLater(
        find.byType(FlashcardEditorScreen),
        matchesGoldenFile('goldens/flashcard_editor_create-empty__dark.png'),
      );
      await dumpStructure(tester, 'flashcard_editor_create-empty__dark');
    });

    // 07 valid: a create form with both fields filled → Save enabled (solid).
    // Distinct from create-empty (which has Save disabled / soft).
    for (final Brightness brightness in Brightness.values) {
      testWidgets('create-valid — ${brightness.name}', (tester) async {
        await _pump(tester, brightness: brightness, golden: true);
        await tester.enterText(find.byType(MxTextField).first, '日本');
        await tester.enterText(find.byType(MxTextField).last, 'Japan');
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(FlashcardEditorScreen),
          matchesGoldenFile(
            'goldens/flashcard_editor_create-valid__${brightness.name}.png',
          ),
        );
      });
    }

    for (final Brightness brightness in Brightness.values) {
      testWidgets('edit-loaded — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          cardId: 'c1',
          cards: <Flashcard>[_card()],
          brightness: brightness,
          golden: true,
        );
        await expectLater(
          find.byType(FlashcardEditorScreen),
          matchesGoldenFile(
            'goldens/flashcard_editor_edit-loaded__${brightness.name}.png',
          ),
        );
        await dumpStructure(
          tester,
          'flashcard_editor_edit-loaded__${brightness.name}',
        );
      });

      testWidgets('details-open — ${brightness.name}', (tester) async {
        await _pump(tester, brightness: brightness, golden: true);
        await tester.tap(find.text('Details'));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(FlashcardEditorScreen),
          matchesGoldenFile(
            'goldens/flashcard_editor_details-open__${brightness.name}.png',
          ),
        );
      });

      testWidgets('saving — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          cardId: 'c1',
          cards: <Flashcard>[_card()],
          brightness: brightness,
          golden: true,
          controller: () => _StubActionController(autoGate: true),
        );
        await tester.tap(find.byType(MxPrimaryButton));
        await tester.pump();
        await expectLater(
          find.byType(FlashcardEditorScreen),
          matchesGoldenFile(
            'goldens/flashcard_editor_saving__${brightness.name}.png',
          ),
        );
      });

      testWidgets('save-failed — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          cardId: 'c1',
          cards: <Flashcard>[_card()],
          brightness: brightness,
          golden: true,
          controller: () => _StubActionController(
            failure: const Failure.storage(
              operation: StorageOp.write,
              cause: 'disk full',
            ),
          ),
        );
        await tester.tap(find.byType(MxPrimaryButton).first);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(FlashcardEditorScreen),
          matchesGoldenFile(
            'goldens/flashcard_editor_save-failed__${brightness.name}.png',
          ),
        );
      });

      testWidgets('loading — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          cardId: 'c1',
          brightness: brightness,
          golden: true,
          loading: true,
        );
        await expectLater(
          find.byType(FlashcardEditorScreen),
          matchesGoldenFile(
            'goldens/flashcard_editor_loading__${brightness.name}.png',
          ),
        );
      });

      testWidgets('load-error — ${brightness.name}', (tester) async {
        await _pump(
          tester,
          cardId: 'c1',
          brightness: brightness,
          golden: true,
          loadError: true,
        );
        await expectLater(
          find.byType(FlashcardEditorScreen),
          matchesGoldenFile(
            'goldens/flashcard_editor_load-error__${brightness.name}.png',
          ),
        );
      });
    }
  });
}
