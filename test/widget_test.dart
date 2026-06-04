import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/app.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/di/app_providers.dart';
import 'package:memox/app/logging/app_talker.dart';

void main() {
  testWidgets('MemoxApp boots into the library destination', (tester) async {
    const config = AppConfig.development();
    final talker = createAppTalker(config);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          talkerProvider.overrideWithValue(talker),
        ],
        child: const MemoxApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Bottom-nav shell renders all four top-level destinations.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Library'), findsWidgets);
  });
}
