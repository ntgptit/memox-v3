import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_state_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

import '../../../../support/golden_harness.dart';

void main() {
  group('MxEmptyState', () {
    testWidgets('renders title, message, and the action slot', (tester) async {
      await pumpThemed(
        tester,
        const MxEmptyState(
          icon: Icons.folder_outlined,
          title: 'No folders yet',
          message: 'Create your first to get started.',
          action: Text('Create folder'),
        ),
      );

      expect(find.text('No folders yet'), findsOneWidget);
      expect(find.text('Create your first to get started.'), findsOneWidget);
      expect(find.text('Create folder'), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });

    testWidgets('omits the action slot when none is given', (tester) async {
      await pumpThemed(
        tester,
        const MxEmptyState(
          icon: Icons.folder_outlined,
          title: 'No folders yet',
          message: 'Create your first to get started.',
        ),
      );

      expect(find.byType(TextButton), findsNothing);
      expect(find.text('No folders yet'), findsOneWidget);
    });
  });

  group('MxErrorState', () {
    testWidgets('renders failure copy and a retry action slot', (tester) async {
      await pumpThemed(
        tester,
        const MxErrorState(
          title: "Couldn't load library",
          message: 'Check your connection and try again.',
          action: Text('Retry'),
        ),
      );

      expect(find.text("Couldn't load library"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('MxNoResultsState', () {
    testWidgets('renders no-results copy with the default glyph', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        const MxNoResultsState(
          title: 'No matches',
          message: 'Try a different search.',
        ),
      );

      expect(find.text('No matches'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });

  group('MxStateCard', () {
    testWidgets('hosts its panel inside an MxCard in a scroll body', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        const MxStateCard(
          child: MxEmptyState(
            icon: Icons.folder_outlined,
            title: 'No folders yet',
            message: 'Create your first to get started.',
          ),
        ),
      );

      // The panel is wrapped in exactly one MxCard, hosted in a scroll body
      // (top-anchored, not full-height-centered), and its content still renders.
      expect(find.byType(MxCard), findsOneWidget);
      expect(find.byType(Scrollable), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MxCard),
          matching: find.text('No folders yet'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('centered variant hosts the panel in a card without overflow', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        const MxStateCard(
          centered: true,
          child: MxEmptyState(
            icon: Icons.folder_outlined,
            title: 'No cards yet',
            message: 'Add your first flashcard.',
          ),
        ),
      );

      expect(find.byType(MxCard), findsOneWidget);
      expect(find.byType(Scrollable), findsOneWidget);
      // The centering tree must be present (regression guard against silently
      // reverting to the top-anchored ListView path). MxEmptyState also has its
      // own Center, so allow one-or-more here.
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(ConstrainedBox), findsWidgets);
      expect(find.text('No cards yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MxLoadingState', () {
    testWidgets('shows a spinner and optional caption', (tester) async {
      await pumpThemed(tester, const MxLoadingState(message: 'Loading...'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('shows a bare spinner when no caption is given', (
      tester,
    ) async {
      await pumpThemed(tester, const MxLoadingState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });
  });
}
