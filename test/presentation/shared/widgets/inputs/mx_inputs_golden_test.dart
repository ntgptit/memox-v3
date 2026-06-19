import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';

import '../../../../support/golden_harness.dart';

Widget _gallery() => Padding(
  padding: const EdgeInsets.all(MxSpacing.screen),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: MxSpacing.space4,
    children: <Widget>[
      const MxTextField(hintText: 'Front'),
      const MxSearchField(hintText: 'Search your library'),
      MxSearchField(
        hintText: 'Search your library',
        controller: TextEditingController(text: 'languages'),
      ),
    ],
  ),
);

void main() {
  group('input goldens', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('gallery — ${brightness.name}', (tester) async {
        await pumpForGolden(tester, _gallery(), brightness: brightness);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/mx_inputs__${brightness.name}.png'),
        );
      });
    }
  });
}
