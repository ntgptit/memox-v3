import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/layouts/mx_list_scaffold.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

import '../../../support/golden_harness.dart';

Widget _scaffold() => MxScaffold(
  appBar: const MxAppBar(title: 'Library'),
  floatingActionButton: MxFab(
    icon: Icons.create_new_folder_outlined,
    tooltip: 'New folder',
    onPressed: () {},
  ),
  body: ListView(
    padding: const EdgeInsets.symmetric(vertical: MxSpacing.space4),
    children: const <Widget>[
      MxCard(
        child: MxListTile(
          leading: Icon(Icons.folder_outlined),
          title: 'Languages',
          subtitle: '4 decks · 412 cards',
        ),
      ),
      SizedBox(height: MxSpacing.space3),
      MxCard(
        child: MxListTile(
          leading: Icon(Icons.science_outlined),
          title: 'Sciences',
          subtitle: '3 decks · 286 cards',
        ),
      ),
    ],
  ),
);

Widget _listScaffold() => MxListScaffold(
  appBar: const MxAppBar(title: 'Decks'),
  itemCount: 3,
  itemBuilder: (context, index) => MxCard(
    child: MxListTile(
      leading: const Icon(Icons.style_outlined),
      title: 'Deck ${index + 1}',
      subtitle: '${(index + 1) * 12} cards',
    ),
  ),
);

void main() {
  final Map<String, Widget Function()> cases = <String, Widget Function()>{
    'scaffold': _scaffold,
    'list-scaffold': _listScaffold,
  };

  group('screen-shell goldens', () {
    for (final MapEntry<String, Widget Function()> c in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${c.key} — ${brightness.name}', (tester) async {
          await pumpHomeForGolden(tester, c.value(), brightness: brightness);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/mx_${c.key}__${brightness.name}.png'),
          );
        });
      }
    }
  });
}
