import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';

void main() {
  testWidgets('MxTextField uses the input radius and keeps validation', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MxTextField(
              controller: controller,
              validator: (String? value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
          ),
        ),
      ),
    );

    final Finder textField = find.descendant(
      of: find.byType(TextFormField),
      matching: find.byType(TextField),
    );
    expect(
      tester.widget<TextField>(textField).decoration!.border,
      isA<OutlineInputBorder>().having(
        (OutlineInputBorder border) => border.borderRadius,
        'borderRadius',
        RadiusTokens.brMd,
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });
}
