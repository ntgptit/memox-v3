import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/sort/content_sort_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

FolderSummary _summary(String id, String name, DateTime createdAt) =>
    FolderSummary(
      folder: Folder(
        id: id,
        parentId: null,
        name: name,
        contentMode: ContentMode.decks,
        sortOrder: 0,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      subfolderCount: 0,
      deckCount: 1,
      cardCount: 1,
      dueCount: 0,
    );

void main() {
  // Read-model order (DB sort_order): Banana(old), apple(new), Cherry(mid).
  final List<FolderSummary> seed = <FolderSummary>[
    _summary('a', 'Banana', DateTime.utc(2026, 1, 1)),
    _summary('b', 'apple', DateTime.utc(2026, 3, 1)),
    _summary('c', 'Cherry', DateTime.utc(2026, 2, 1)),
  ];

  List<String> names(List<FolderSummary> f) =>
      f.map((FolderSummary s) => s.folder.name).toList();

  group('sortLibraryFolders', () {
    test('manual keeps the read-model order', () {
      expect(names(sortLibraryFolders(seed, ContentSortMode.manual)), <String>[
        'Banana',
        'apple',
        'Cherry',
      ]);
    });

    test('name is case-folded A→Z', () {
      expect(names(sortLibraryFolders(seed, ContentSortMode.name)), <String>[
        'apple',
        'Banana',
        'Cherry',
      ]);
    });

    test('newest is most-recently-created first', () {
      expect(names(sortLibraryFolders(seed, ContentSortMode.newest)), <String>[
        'apple', // 2026-03
        'Cherry', // 2026-02
        'Banana', // 2026-01
      ]);
    });

    test('lastStudied (deferred) falls back to manual order', () {
      expect(
        names(sortLibraryFolders(seed, ContentSortMode.lastStudied)),
        names(seed),
      );
    });

    test('does not mutate the input list', () {
      sortLibraryFolders(seed, ContentSortMode.name);
      expect(names(seed), <String>['Banana', 'apple', 'Cherry']);
    });
  });

  group('contentSortModeFromToken', () {
    test('maps known tokens', () {
      expect(contentSortModeFromToken('name'), ContentSortMode.name);
      expect(contentSortModeFromToken('newest'), ContentSortMode.newest);
      expect(contentSortModeFromToken('manual'), ContentSortMode.manual);
    });

    test('null / unknown / deferred fall back to manual', () {
      expect(contentSortModeFromToken(null), ContentSortMode.manual);
      expect(contentSortModeFromToken('bogus'), ContentSortMode.manual);
      // lastStudied is not offered by the sheet → not a valid stored token.
      expect(contentSortModeFromToken('lastStudied'), ContentSortMode.manual);
    });
  });

  group('showContentSortSheet', () {
    testWidgets('lists the 3 modes, checks the active one, returns the tap', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      ContentSortMode? result;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: MxTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () async {
                    result = await showContentSortSheet(
                      context,
                      current: ContentSortMode.manual,
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // All three implemented modes are offered; lastStudied is not.
      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('Name (A–Z)'), findsOneWidget);
      expect(find.text('Newest'), findsOneWidget);
      // Each row has a leading mode glyph (no more bare text rows).
      expect(find.byIcon(Icons.format_list_numbered), findsOneWidget);
      expect(find.byIcon(Icons.sort_by_alpha), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      // The active mode (manual) carries the trailing check.
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Newest'));
      await tester.pumpAndSettle();
      expect(result, ContentSortMode.newest);
    });
  });
}
