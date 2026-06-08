import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/shadow_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';

/// Single-field name dialog (create folder / rename / tag input), returning the
/// trimmed name or `null` on cancel.
///
/// `docs/wireframes/24-shared-dialogs.md` §rename / §folder-form. Confirm is
/// disabled while the trimmed input is blank, so blank names are rejected by
/// the dialog itself. All copy is caller-supplied (localized).
Future<String?> showMxNameDialog(
  BuildContext context, {
  required String title,
  required String fieldLabel,
  required String confirmLabel,
  required String cancelLabel,
  String initialValue = '',
}) async {
  final String? name = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _MxNameDialog(
      title: title,
      fieldLabel: fieldLabel,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialValue: initialValue,
    ),
  );
  return name;
}

class _MxNameDialog extends HookWidget {
  const _MxNameDialog({
    required this.title,
    required this.fieldLabel,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.initialValue,
  });

  final String title;
  final String fieldLabel;
  final String confirmLabel;
  final String cancelLabel;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    final MxTextSubmitState submit = useMxTextSubmitState(
      initialText: initialValue,
    );
    return PopScope(
      canPop: false,
      child: _MxNameDialogBody(
        title: title,
        fieldLabel: fieldLabel,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        submit: submit,
      ),
    );
  }
}

class _MxNameDialogBody extends StatelessWidget {
  const _MxNameDialogBody({
    required this.title,
    required this.fieldLabel,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.submit,
  });

  final String title;
  final String fieldLabel;
  final String confirmLabel;
  final String cancelLabel;
  final MxTextSubmitState submit;

  static const double _dialogMaxWidth = 432;
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final TextTheme text = context.textTheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(SpacingTokens.lg),
      backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0),
      surfaceTintColor: scheme.surfaceContainerHigh.withValues(alpha: 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: RadiusTokens.brXl,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.24),
                blurRadius: ShadowTokens.blurDialog,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  title,
                  style: text.titleLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: TypographyTokens.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                TextField(
                  controller: submit.controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(labelText: fieldLabel),
                  onSubmitted: (_) {
                    if (!submit.canSubmit) {
                      return;
                    }
                    Navigator.of(context).pop(submit.trimmedText);
                  },
                ),
                const SizedBox(height: SpacingTokens.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: SizeTokens.dialogActionWidth,
                        height: SizeTokens.controlMd,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.md,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const RoundedRectangleBorder(
                              borderRadius: RadiusTokens.brMd,
                            ),
                          ),
                          child: Text(cancelLabel),
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      SizedBox(
                        width: SizeTokens.dialogActionWidth,
                        height: SizeTokens.controlMd,
                        child: FilledButton(
                          onPressed: submit.canSubmit
                              ? () => Navigator.of(
                                  context,
                                ).pop(submit.trimmedText)
                              : null,
                          style: FilledButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.md,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const RoundedRectangleBorder(
                              borderRadius: RadiusTokens.brMd,
                            ),
                          ),
                          child: Text(confirmLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
