import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/app.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/di/app_providers.dart';
import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/app/logging/app_talker.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/usecases/folder/create_root_folder_usecase.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/screens/library_overview_screen.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_tile.dart';
import 'package:memox/presentation/features/folders/widgets/library_overview_body.dart';
import 'package:memox/presentation/features/folders/widgets/library_sections.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

Folder _folder(String name, {ContentMode mode = ContentMode.decks}) => Folder(
  id: name,
  parentId: null,
  name: name,
  contentMode: mode,
  sortOrder: 0,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

FolderWithCount _item(
  String name, {
  ContentMode mode = ContentMode.decks,
  int subfolderCount = 0,
  int deckCount = 3,
  int cardCount = 40,
  int dueCount = 0,
}) => FolderWithCount(
  folder: _folder(name, mode: mode),
  subfolderCount: subfolderCount,
  deckCount: deckCount,
  cardCount: cardCount,
  dueCount: dueCount,
);

LibraryOverviewReadModel _model({
  List<FolderWithCount> folders = const <FolderWithCount>[],
  int dueToday = 0,
  int totalFolderCount = 0,
}) => LibraryOverviewReadModel(
  folders: folders,
  dueToday: dueToday,
  totalFolderCount: totalFolderCount,
);

final class _UnusedFolderRepository implements FolderRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _PendingCreateRootFolderUseCase extends CreateRootFolderUseCase {
  _PendingCreateRootFolderUseCase() : super(_UnusedFolderRepository());

  final Completer<Result<Folder>> completer = Completer<Result<Folder>>();

  @override
  Future<Result<Folder>> call({required String name}) => completer.future;
}

Widget _wrapBody(
  LibraryOverviewReadModel model, {
  bool isSearching = false,
  void Function(FolderWithCount item)? onShowFolderActions,
}) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: LibraryOverviewBody(
      model: model,
      isSearching: isSearching,
      onCreateFolder: () {},
      onClearSearch: () {},
      onShowFolderActions: onShowFolderActions ?? (FolderWithCount _) {},
    ),
  ),
);

/// Wraps the full screen so the inline search field, body, and the
/// `MxRetainedAsyncState` (loading / error) wiring are exercised end-to-end.
/// The library-overview query stream is supplied per test via [stream].
Widget _wrapScreen(Stream<LibraryOverviewReadModel> stream) => ProviderScope(
  overrides: [libraryOverviewQueryProvider.overrideWith((Ref ref) => stream)],
  child: MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const LibraryOverviewScreen(),
  ),
);

void main() {
  group('LibraryOverviewBody — Loaded', () {
    testWidgets('folder row renders title, metadata, kebab, and no chevron', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _model(
            folders: <FolderWithCount>[_item('Korean')],
            totalFolderCount: 1,
          ),
        ),
      );

      // Title.
      expect(find.text('Korean'), findsOneWidget);
      // Metadata row: "{n} decks" + "{n} cards".
      expect(find.text('3 decks'), findsOneWidget);
      expect(find.text('40 cards'), findsOneWidget);
      // Kebab present; chevron absent (rows open via tap, not a chevron).
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('subfolder-mode folder shows the subfolders metadata', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _model(
            folders: <FolderWithCount>[
              _item(
                'Languages',
                mode: ContentMode.subfolders,
                subfolderCount: 4,
              ),
            ],
            totalFolderCount: 1,
          ),
        ),
      );

      expect(find.text('4 subfolders'), findsOneWidget);
    });

    testWidgets('overflow kebab is enabled and invokes the action callback', (
      WidgetTester tester,
    ) async {
      FolderWithCount? tapped;
      await tester.pumpWidget(
        _wrapBody(
          _model(
            folders: <FolderWithCount>[_item('Korean')],
            totalFolderCount: 1,
          ),
          onShowFolderActions: (FolderWithCount item) => tapped = item,
        ),
      );

      final IconButton kebab = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.more_vert),
          matching: find.byType(IconButton),
        ),
      );
      expect(kebab.onPressed, isNotNull);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();
      expect(tapped?.folder.name, 'Korean');
    });

    testWidgets('folder row long-press invokes the action callback', (
      WidgetTester tester,
    ) async {
      FolderWithCount? tapped;
      await tester.pumpWidget(
        _wrapBody(
          _model(
            folders: <FolderWithCount>[_item('Korean')],
            totalFolderCount: 1,
          ),
          onShowFolderActions: (FolderWithCount item) => tapped = item,
        ),
      );

      // The long-press affordance routes to `onShowActions`, now wired to the
      // folder action sheet.
      final MxCard card = tester.widget<MxCard>(find.byType(MxCard));
      expect(card.onLongPress, isNotNull);

      await tester.longPress(find.byType(MxCard));
      await tester.pump();
      expect(tapped?.folder.name, 'Korean');
    });
  });

  group('LibraryOverviewBody — Due states', () {
    testWidgets('folder row shows a due badge only when dueCount > 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _model(
            folders: <FolderWithCount>[_item('Korean', dueCount: 12)],
            totalFolderCount: 1,
          ),
        ),
      );
      expect(find.text('12 due'), findsOneWidget);

      await tester.pumpWidget(
        _wrapBody(
          _model(
            folders: <FolderWithCount>[_item('Korean')],
            totalFolderCount: 1,
          ),
        ),
      );
      expect(find.textContaining('due'), findsNothing);
    });

    testWidgets('due summary card renders only when dueToday > 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _model(
            folders: <FolderWithCount>[_item('Korean')],
            dueToday: 18,
            totalFolderCount: 1,
          ),
        ),
      );
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      expect(find.textContaining('due today'), findsOneWidget);

      await tester.pumpWidget(
        _wrapBody(
          _model(
            folders: <FolderWithCount>[_item('Korean')],
            totalFolderCount: 1,
          ),
        ),
      );
      expect(find.byIcon(Icons.bolt_rounded), findsNothing);
    });
  });

  group('LibraryOverviewBody — Empty vs search no-results', () {
    testWidgets(
      'true-empty library shows the create-folder CTA, not no-results',
      (WidgetTester tester) async {
        await tester.pumpWidget(_wrapBody(_model()));

        expect(
          find.byKey(const ValueKey<String>('library_search_no_results')),
          findsNothing,
        );
        expect(find.text('New folder'), findsOneWidget);
      },
    );

    testWidgets('active search with no matches shows the no-results section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(_model(totalFolderCount: 3), isSearching: true),
      );

      expect(
        find.byKey(const ValueKey<String>('library_search_no_results')),
        findsOneWidget,
      );
    });
  });

  group('LibrarySections — Error/retry & clear callbacks', () {
    testWidgets('error section renders localized failure UI', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LibraryErrorSection(onRetry: () {})),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.text("Couldn't load your library"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button invokes the retry callback', (
      WidgetTester tester,
    ) async {
      int retries = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: LibraryErrorSection(onRetry: () => retries++)),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(retries, 1);
    });

    testWidgets('no-results clear button invokes the clear callback', (
      WidgetTester tester,
    ) async {
      int clears = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LibrarySearchNoResultsSection(onClear: () => clears++),
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(clears, 1);
    });
  });

  group('LibraryOverviewScreen — Loading & Error states', () {
    testWidgets('loading renders the skeleton and no tappable folder rows', (
      WidgetTester tester,
    ) async {
      final Completer<LibraryOverviewReadModel> pending =
          Completer<LibraryOverviewReadModel>();
      await tester.pumpWidget(
        _wrapScreen(
          Stream<LibraryOverviewReadModel>.fromFuture(pending.future),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('library_skeleton')),
        findsOneWidget,
      );
      // No folder rows are rendered while data is absent.
      expect(find.byType(LibraryFolderTile), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('error state renders the localized failure UI with retry', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(Stream<LibraryOverviewReadModel>.error(Exception('boom'))),
      );
      await tester.pump();

      expect(find.text("Couldn't load your library"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      // No raw exception text leaks into the UI.
      expect(find.textContaining('boom'), findsNothing);
    });
  });

  group('LibraryOverviewScreen — Search clear sync', () {
    testWidgets(
      'clearing from the no-results CTA clears provider state and the field',
      (WidgetTester tester) async {
        // Non-empty library, but the stream returns no folders so any active
        // search resolves to the no-results state.
        await tester.pumpWidget(
          _wrapScreen(
            Stream<LibraryOverviewReadModel>.value(_model(totalFolderCount: 3)),
          ),
        );
        await tester.pumpAndSettle();

        final ProviderContainer container = ProviderScope.containerOf(
          tester.element(find.byType(LibraryOverviewScreen)),
        );

        // Type a query → no-results section appears, field holds the text.
        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey<String>('library_search_no_results')),
          findsOneWidget,
        );
        expect(container.read(libraryToolbarProvider).searchTerm, 'zzz');

        // Tap the no-results "Clear" CTA.
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();

        // Provider state cleared AND the visible field text cleared in sync.
        expect(container.read(libraryToolbarProvider).searchTerm, '');
        final TextField field = tester.widget<TextField>(
          find.byType(TextField),
        );
        expect(field.controller?.text, '');
      },
    );
  });

  group('LibraryActionController — Lifecycle', () {
    test(
      'createFolder returns after auto-dispose without writing disposed state',
      () async {
        final useCase = _PendingCreateRootFolderUseCase();
        final ProviderContainer container = ProviderContainer(
          overrides: [
            createRootFolderUseCaseProvider.overrideWithValue(useCase),
          ],
        );

        final Future<Result<Folder>> pending = container
            .read(libraryActionControllerProvider.notifier)
            .createFolder('Korean');
        container.dispose();

        final Result<Folder> expected = Result<Folder>.ok(_folder('Korean'));
        useCase.completer.complete(expected);

        await expectLater(pending, completion(expected));
      },
    );
  });

  group('LibraryOverviewScreen — Overflow sheet', () {
    Future<void> pumpLoaded(
      WidgetTester tester, {
      ContentMode mode = ContentMode.decks,
    }) async {
      await tester.pumpWidget(
        _wrapScreen(
          Stream<LibraryOverviewReadModel>.value(
            _model(
              folders: <FolderWithCount>[_item('Korean', mode: mode)],
              totalFolderCount: 1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('tapping the kebab opens the folder action sheet', (
      WidgetTester tester,
    ) async {
      await pumpLoaded(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Mock-approved actions only.
      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Move to folder'), findsOneWidget);
      expect(find.text('Import flashcards'), findsOneWidget);
      expect(find.text('Delete folder'), findsOneWidget);
      // Unsupported mock actions are not exposed.
      expect(find.text('Study due cards'), findsNothing);
      expect(find.text('Archive folder'), findsNothing);
    });

    testWidgets('long-pressing the folder row opens the same sheet', (
      WidgetTester tester,
    ) async {
      await pumpLoaded(tester);

      await tester.longPress(find.byType(LibraryFolderTile));
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Delete folder'), findsOneWidget);
    });

    testWidgets('subfolder-mode folder hides Import flashcards', (
      WidgetTester tester,
    ) async {
      await pumpLoaded(tester, mode: ContentMode.subfolders);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Move to folder'), findsOneWidget);
      expect(find.text('Import flashcards'), findsNothing);
    });

    testWidgets('Delete opens the destructive confirm dialog', (
      WidgetTester tester,
    ) async {
      await pumpLoaded(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete folder'));
      await tester.pumpAndSettle();

      // The confirm dialog's unique subtree-warning copy is shown.
      expect(
        find.text(
          'This will delete the full subtree, including decks and flashcards.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('New folder FAB is visible in the loaded state', (
      WidgetTester tester,
    ) async {
      await pumpLoaded(tester);

      expect(
        find.widgetWithText(FloatingActionButton, 'New folder'),
        findsOneWidget,
      );
    });
  });

  testWidgets('bottom navigation switches tabs', (WidgetTester tester) async {
    const AppConfig config = AppConfig.development();
    final talker = createAppTalker(config);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          talkerProvider.overrideWithValue(talker),
          libraryOverviewQueryProvider.overrideWith(
            (ref) => Stream<LibraryOverviewReadModel>.value(_model()),
          ),
        ],
        child: const MemoxApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Boots into Library.
    expect(find.text('Library'), findsWidgets);

    // Switch to the Progress tab → its placeholder (route name) renders.
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('progress'), findsWidgets);
  });
}
