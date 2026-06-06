import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/app.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/di/app_providers.dart';
import 'package:memox/app/logging/app_talker.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';

void main() {
  testWidgets('MxApplication boots into the library destination', (
    tester,
  ) async {
    const config = MxAppConfig.development();
    final talker = createAppTalker(config);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          talkerProvider.overrideWithValue(talker),
          // Stub the Library query so boot needs no native Drift database.
          libraryOverviewQueryProvider.overrideWith(
            (ref) => Stream<LibraryOverviewReadModel>.value(
              const LibraryOverviewReadModel(
                folders: <FolderWithCount>[],
                dueToday: 0,
                totalFolderCount: 0,
              ),
            ),
          ),
        ],
        child: const MxApplication(),
      ),
    );
    await tester.pumpAndSettle();

    // Bottom-nav shell renders all four top-level destinations.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Library'), findsWidgets);
  });
}
