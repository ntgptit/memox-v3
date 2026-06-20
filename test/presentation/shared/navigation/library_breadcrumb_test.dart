import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/presentation/shared/navigation/library_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

Folder _folder(String id, String name) => Folder(
  id: id,
  parentId: null,
  name: name,
  contentMode: ContentMode.unlocked,
  sortOrder: 0,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

/// Pumps a [Builder] so the breadcrumb builder gets a real [BuildContext], then
/// hands the captured context to [body].
Future<void> _withContext(
  WidgetTester tester,
  void Function(BuildContext context) body,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          body(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

void main() {
  group('buildLibraryBreadcrumb', () {
    testWidgets(
      'folder detail: deepest folder is the non-tappable current leaf',
      (tester) async {
        late List<MxBreadcrumbItem> items;
        await _withContext(tester, (BuildContext context) {
          items = buildLibraryBreadcrumb(
            context,
            libraryLabel: 'Library',
            folders: <Folder>[
              _folder('a', 'Languages'),
              _folder('b', 'Korean'),
            ],
          );
        });

        expect(items.map((MxBreadcrumbItem i) => i.label).toList(), <String>[
          'Library',
          'Languages',
          'Korean',
        ]);
        // Library + each ancestor are tappable; the current folder (last) is not.
        expect(items[0].onTap, isNotNull);
        expect(items[1].onTap, isNotNull);
        expect(items.last.onTap, isNull);
      },
    );

    testWidgets(
      'flashcard list: deck leaf is current, every folder is tappable',
      (tester) async {
        late List<MxBreadcrumbItem> items;
        await _withContext(tester, (BuildContext context) {
          items = buildLibraryBreadcrumb(
            context,
            libraryLabel: 'Library',
            folders: <Folder>[_folder('a', 'Languages')],
            currentLeafLabel: 'N5 Vocab',
          );
        });

        expect(items.map((MxBreadcrumbItem i) => i.label).toList(), <String>[
          'Library',
          'Languages',
          'N5 Vocab',
        ]);
        // The deck leaf is the current (non-tappable) crumb; folders stay tappable.
        expect(items[0].onTap, isNotNull);
        expect(items[1].onTap, isNotNull);
        expect(items.last.label, 'N5 Vocab');
        expect(items.last.onTap, isNull);
      },
    );

    testWidgets('top-level folder: trail is Library › currentFolder', (
      tester,
    ) async {
      late List<MxBreadcrumbItem> items;
      await _withContext(tester, (BuildContext context) {
        items = buildLibraryBreadcrumb(
          context,
          libraryLabel: 'Library',
          folders: <Folder>[_folder('a', 'Inbox')],
        );
      });

      expect(items.length, 2);
      expect(items[0].onTap, isNotNull); // Library tappable
      expect(items[1].onTap, isNull); // current folder leaf
    });
  });
}
