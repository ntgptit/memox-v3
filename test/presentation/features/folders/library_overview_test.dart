import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/app.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/di/app_providers.dart';
import 'package:memox/app/logging/app_talker.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/library_overview_body.dart';

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
  int deckCount = 3,
  int cardCount = 40,
  int dueCount = 0,
}) => FolderWithCount(
  folder: _folder(name),
  subfolderCount: 0,
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

Widget _wrapBody(LibraryOverviewReadModel model, {bool isSearching = false}) =>
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: LibraryOverviewBody(
          model: model,
          isSearching: isSearching,
          onCreateFolder: () {},
          onClearSearch: () {},
        ),
      ),
    );

void main() {
  group('LibraryOverviewBody', () {
    testWidgets('loaded state renders a folder row with a kebab and no chevron', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(_model(folders: <FolderWithCount>[_item('Korean')], totalFolderCount: 1)),
      );

      expect(find.text('Korean'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('folder row shows a due badge only when dueCount > 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(_model(folders: <FolderWithCount>[_item('Korean', dueCount: 12)], totalFolderCount: 1)),
      );
      expect(find.text('12 due'), findsOneWidget);

      await tester.pumpWidget(
        _wrapBody(_model(folders: <FolderWithCount>[_item('Korean')], totalFolderCount: 1)),
      );
      expect(find.textContaining('due'), findsNothing);
    });

    testWidgets('due summary card renders only when dueToday > 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBody(
          _model(folders: <FolderWithCount>[_item('Korean')], dueToday: 18, totalFolderCount: 1),
        ),
      );
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      expect(find.textContaining('due today'), findsOneWidget);

      await tester.pumpWidget(
        _wrapBody(_model(folders: <FolderWithCount>[_item('Korean')], totalFolderCount: 1)),
      );
      expect(find.byIcon(Icons.bolt_rounded), findsNothing);
    });

    testWidgets('true-empty library shows the create-folder CTA, not no-results', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapBody(_model()));

      expect(
        find.byKey(const ValueKey<String>('library_search_no_results')),
        findsNothing,
      );
      expect(find.text('New folder'), findsOneWidget);
    });

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
