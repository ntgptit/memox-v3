import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_avatar.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

import '../../../../support/golden_harness.dart';

const List<({IconData icon, String title, String subtitle})>
_rows = <({IconData icon, String title, String subtitle})>[
  (icon: Icons.translate, title: 'Languages', subtitle: '4 decks · 412 cards'),
  (
    icon: Icons.science_outlined,
    title: 'Sciences',
    subtitle: '3 decks · 286 cards',
  ),
  (icon: Icons.work_outline, title: 'Work', subtitle: '5 decks · 320 cards'),
];

Widget _libraryCard() => MxCard(
  padding: const EdgeInsets.symmetric(horizontal: MxSpacing.card),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      for (final ({IconData icon, String title, String subtitle}) r in _rows)
        MxListTile(
          leading: MxAvatar(icon: r.icon),
          title: r.title,
          subtitle: r.subtitle,
          trailing: const Icon(Icons.chevron_right),
        ),
    ],
  ),
);

Widget _avatarRow() => const Row(
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    MxAvatar(icon: Icons.folder_outlined),
    SizedBox(width: MxSpacing.space3),
    MxAvatar(label: 'AN', shape: MxAvatarShape.circle),
  ],
);

void main() {
  final Map<String, Widget> cases = <String, Widget>{
    'library-card': Padding(
      padding: const EdgeInsets.all(MxSpacing.screen),
      child: _libraryCard(),
    ),
    'avatars': Center(child: _avatarRow()),
  };

  group('surface widget goldens', () {
    for (final MapEntry<String, Widget> c in cases.entries) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('${c.key} — ${brightness.name}', (tester) async {
          await pumpForGolden(tester, c.value, brightness: brightness);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/mx_${c.key}__${brightness.name}.png'),
          );
        });
      }
    }
  });
}
