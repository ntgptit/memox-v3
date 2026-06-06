import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/flashcard_list_screen.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_detail_card_row.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_empty_state_section.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_list_body.dart';

Flashcard _card(String id, String front, String back, int order) => Flashcard(
  id: id,
  deckId: 'd1',
  front: front,
  back: back,
  sortOrder: order,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

FlashcardListDetail _detail({
  List<Flashcard> cards = const <Flashcard>[],
  int? totalCount,
}) => FlashcardListDetail(
  deck: Deck(
    id: 'd1',
    folderId: 'f1',
    name: 'N5',
    targetLanguage: TargetLanguage.korean,
    sortOrder: 0,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  ),
  breadcrumb: const <FolderBreadcrumbSegment>[
    FolderBreadcrumbSegment(id: 'f1', name: 'Korean'),
  ],
  cards: cards,
  totalCount: totalCount ?? cards.length,
);

Widget _wrapBody(
  FlashcardListDetail detail, {
  bool isSearching = false,
  bool isReordering = false,
}) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: FlashcardListBody(
      detail: detail,
      isSearching: isSearching,
      isReordering: isReordering,
      onAddCard: () {},
      onImport: () {},
      onClearSearch: () {},
      onCardTap: (_) {},
      onCardActions: (_) {},
      onReorder: (_) {},
    ),
  ),
);

Widget _wrapScreen(Stream<FlashcardListDetail> stream) => ProviderScope(
  overrides: [
    flashcardListQueryProvider('d1').overrideWith((Ref ref) => stream),
  ],
  child: MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const FlashcardListScreen(deckId: 'd1'),
  ),
);

void main() {
  group('FlashcardListBody — Loaded (1/8)', () {
    testWidgets('renders one row per card with front and back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _detail(
            cards: <Flashcard>[
              _card('c1', '안녕하세요', 'Hello', 0),
              _card('c2', '감사합니다', 'Thank you', 1),
            ],
          ),
        ),
      );

      expect(find.byType(FlashcardDetailCardRow), findsNWidgets(2));
      expect(find.text('안녕하세요'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });
  });

  group('FlashcardListBody — Empty (2/8)', () {
    testWidgets('zero cards shows the empty-deck state with Add CTA', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapBody(_detail()));

      expect(find.byType(FlashcardEmptyStateSection), findsOneWidget);
      expect(find.text('Add flashcard'), findsOneWidget);
      expect(find.text('Import from CSV / Excel'), findsOneWidget);
    });

    testWidgets('empty wins over an active search term', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapBody(_detail(), isSearching: true));

      expect(find.byType(FlashcardEmptyStateSection), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('flashcard_no_results')),
        findsNothing,
      );
    });
  });

  group('FlashcardListBody — Search empty (3/8)', () {
    testWidgets('cards filtered to none with a term shows no-results', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _detail(cards: const <Flashcard>[], totalCount: 5),
          isSearching: true,
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('flashcard_no_results')),
        findsOneWidget,
      );
      expect(find.byType(FlashcardEmptyStateSection), findsNothing);
    });
  });

  group('FlashcardListBody — Reorder (8/8)', () {
    testWidgets('reorder mode shows the reorder list with drag handles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _detail(
            cards: <Flashcard>[
              _card('c1', 'A', 'a', 0),
              _card('c2', 'B', 'b', 1),
            ],
          ),
          isReordering: true,
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('flashcard_reorder_list')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    });
  });

  group('FlashcardListScreen — Loading (4/8) & Error (5/8)', () {
    testWidgets('loading renders the skeleton and no content rows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(const Stream<FlashcardListDetail>.empty()),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('flashcard_list_skeleton')),
        findsOneWidget,
      );
      expect(find.byType(FlashcardDetailCardRow), findsNothing);
    });

    testWidgets('error renders the localized failure UI with retry', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(Stream<FlashcardListDetail>.error(Exception('boom'))),
      );
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);
    });
  });

  group('FlashcardListScreen — Delete card (6/8)', () {
    testWidgets('row action sheet → Delete opens the single-card confirm', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(
          Stream<FlashcardListDetail>.value(
            _detail(cards: <Flashcard>[_card('c1', '안녕', 'Hi', 0)]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(FlashcardDetailCardRow),
          matching: find.byIcon(Icons.more_vert),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete flashcard'), findsOneWidget);
      expect(
        find.text('This will permanently delete this flashcard.'),
        findsOneWidget,
      );
    });
  });

  group('FlashcardListScreen — Delete deck (7/8)', () {
    testWidgets('app-bar overflow → Delete deck opens the deck confirm', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(
          Stream<FlashcardListDetail>.value(
            _detail(cards: <Flashcard>[_card('c1', '안녕', 'Hi', 0)]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.more_vert),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reorder cards'), findsOneWidget);
      await tester.tap(find.text('Delete deck'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'This will delete the entire deck and all flashcards inside it.',
        ),
        findsOneWidget,
      );
    });
  });
}
