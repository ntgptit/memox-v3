import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';
import 'package:memox/presentation/features/settings/viewmodels/tag_management_viewmodel.dart';
import 'package:memox/presentation/features/settings/widgets/tag_row.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';

import '../../../support/golden_harness.dart';

const List<TagWithCount> _tags = <TagWithCount>[
  TagWithCount(name: 'kanji', cardCount: 142),
  TagWithCount(name: 'vocab', cardCount: 210),
  TagWithCount(name: 'verbs', cardCount: 88),
  TagWithCount(name: 'n5', cardCount: 64),
  TagWithCount(name: 'grammar', cardCount: 52),
  TagWithCount(name: 'particles', cardCount: 31),
];

Stream<List<TagWithCount>> _value(List<TagWithCount> tags) =>
    Stream<List<TagWithCount>>.value(tags);
Stream<List<TagWithCount>> _never() => Stream<List<TagWithCount>>.fromFuture(
  Completer<List<TagWithCount>>().future,
);

Future<void> _pump(
  WidgetTester tester, {
  required Stream<List<TagWithCount>> Function() tags,
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
      overrides: [tagsWithCountProvider.overrideWith((ref) => tags())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light ? MxTheme.light : MxTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsTagManagementScreen(),
      ),
    ),
  );
}

void main() {
  group('SettingsTagManagementScreen states', () {
    testWidgets('loaded shows the count overline + tag rows + dock', (
      tester,
    ) async {
      await _pump(tester, tags: () => _value(_tags));
      await tester.pumpAndSettle();

      expect(find.text('6 TAGS'), findsOneWidget);
      expect(find.byType(TagRow), findsNWidgets(6));
      expect(find.text('kanji'), findsOneWidget);
      expect(find.text('142 cards'), findsOneWidget);
      expect(find.text('Search tags'), findsOneWidget); // dock present
    });

    testWidgets('empty shows the empty state and hides the dock', (
      tester,
    ) async {
      await _pump(tester, tags: () => _value(const <TagWithCount>[]));
      await tester.pumpAndSettle();

      expect(find.byType(MxEmptyState), findsOneWidget);
      expect(find.text('No tags yet'), findsOneWidget);
      expect(find.text('Search tags'), findsNothing); // dock hidden when empty
    });

    testWidgets('loading shows the loading state', (tester) async {
      await _pump(tester, tags: _never);
      await tester.pump();
      expect(find.byType(MxLoadingState), findsOneWidget);
    });

    testWidgets('a non-matching search shows the no-results state', (
      tester,
    ) async {
      await _pump(tester, tags: () => _value(_tags));
      await tester.pumpAndSettle();
      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsTagManagementScreen)),
      );
      container.read(tagSearchQueryProvider.notifier).setTerm('zzzz');
      await tester.pumpAndSettle();

      expect(find.byType(MxNoResultsState), findsOneWidget);
      expect(find.text('No tags found'), findsOneWidget);
    });

    testWidgets('tapping a row overflow opens the action sheet', (
      tester,
    ) async {
      await _pump(tester, tags: () => _value(_tags));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Merge into…'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('SettingsTagManagementScreen goldens', () {
    final Map<String, Stream<List<TagWithCount>> Function()> cases =
        <String, Stream<List<TagWithCount>> Function()>{
          'loaded': () => _value(_tags),
          'empty': () => _value(const <TagWithCount>[]),
          'loading': _never,
        };
    for (final MapEntry<String, Stream<List<TagWithCount>> Function()> entry
        in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${entry.key} — ${brightness.name}', (tester) async {
          await _pump(
            tester,
            tags: entry.value,
            brightness: brightness,
            golden: true,
          );
          await tester.pump(const Duration(milliseconds: 50));
          await expectLater(
            find.byType(SettingsTagManagementScreen),
            matchesGoldenFile(
              'goldens/tag_management_${entry.key}__${brightness.name}.png',
            ),
          );
        });
      }
    }

    testWidgets('search-empty — light', (tester) async {
      await _pump(tester, tags: () => _value(_tags), golden: true);
      await tester.pumpAndSettle();
      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsTagManagementScreen)),
      );
      container.read(tagSearchQueryProvider.notifier).setTerm('zzzz');
      await tester.pump(const Duration(milliseconds: 50));
      await expectLater(
        find.byType(SettingsTagManagementScreen),
        matchesGoldenFile('goldens/tag_management_search-empty__light.png'),
      );
    });

    testWidgets('search-empty — dark', (tester) async {
      await _pump(
        tester,
        tags: () => _value(_tags),
        brightness: Brightness.dark,
        golden: true,
      );
      await tester.pumpAndSettle();
      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsTagManagementScreen)),
      );
      container.read(tagSearchQueryProvider.notifier).setTerm('zzzz');
      await tester.pump(const Duration(milliseconds: 50));
      await expectLater(
        find.byType(SettingsTagManagementScreen),
        matchesGoldenFile('goldens/tag_management_search-empty__dark.png'),
      );
    });
  });
}
