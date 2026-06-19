import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';

import '../../../../support/golden_harness.dart';

void main() {
  const Map<String, Widget> cases = <String, Widget>{
    'empty': MxEmptyState(
      icon: Icons.folder_outlined,
      title: 'No folders yet',
      message:
          'Folders keep your decks tidy by subject.\n'
          'Create your first to get started.',
    ),
    'error': MxErrorState(
      title: "Couldn't load library",
      message:
          "We couldn't reach your folders. Check your connection and "
          'try again.',
    ),
    'no-results': MxNoResultsState(
      title: 'No matches',
      message: 'Nothing matched your search. Try a different term.',
    ),
    'loading': MxLoadingState(message: 'Loading your library...'),
  };

  group('state widget goldens', () {
    for (final MapEntry<String, Widget> c in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        final String theme = brightness.name;
        testWidgets('${c.key} — $theme', (tester) async {
          await pumpForGolden(tester, c.value, brightness: brightness);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/mx_${c.key}_state__$theme.png'),
          );
        });
      }
    }
  });
}
