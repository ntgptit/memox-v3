import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';

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

class _MxNameDialog extends StatefulWidget {
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
  State<_MxNameDialog> createState() => _MxNameDialogState();
}

class _MxNameDialogState extends State<_MxNameDialog> {
  static const double _dialogMaxWidth = 432;
  static const double _actionButtonWidth = 128;
  static const double _actionButtonHeight = 40;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue)
      ..addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  bool get _canSubmit => StringUtils.trimmed(_controller.text).isNotEmpty;

  void _submit() {
    final String name = StringUtils.trimmed(_controller.text);
    if (name.isEmpty) {
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final TextTheme text = context.textTheme;
    return PopScope(
      canPop: false,
      child: Dialog(
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
                  blurRadius: 36,
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
                    widget.title,
                    style: text.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: widget.fieldLabel),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: _actionButtonWidth,
                          height: _actionButtonHeight,
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
                            child: Text(widget.cancelLabel),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        SizedBox(
                          width: _actionButtonWidth,
                          height: _actionButtonHeight,
                          child: FilledButton(
                            onPressed: _canSubmit ? _submit : null,
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
                            child: Text(widget.confirmLabel),
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
      ),
    );
  }
}
