import 'package:flutter/material.dart';

import 'package:memox/core/utils/string_utils.dart';

/// Single-field name dialog (create folder / rename), returning the trimmed
/// name or `null` on cancel.
///
/// `docs/wireframes/24-shared-dialogs.md` §folder-create. Confirm is disabled
/// while the trimmed input is blank, so blank names are rejected by the dialog
/// itself. All copy is caller-supplied (localized).
Future<String?> showMxNameDialog(
  BuildContext context, {
  required String title,
  required String fieldLabel,
  required String confirmLabel,
  required String cancelLabel,
  String initialValue = '',
}) => showDialog<String>(
    context: context,
    builder: (BuildContext context) => _MxNameDialog(
      title: title,
      fieldLabel: fieldLabel,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialValue: initialValue,
    ),
  );

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
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = StringUtils.trimmed(_controller.text);
    if (name.isEmpty) {
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: widget.fieldLabel),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (BuildContext context, TextEditingValue value, _) {
            final bool canSubmit =
                StringUtils.trimmed(value.text).isNotEmpty;
            return FilledButton(
              onPressed: canSubmit ? _submit : null,
              child: Text(widget.confirmLabel),
            );
          },
        ),
      ],
    );
}
