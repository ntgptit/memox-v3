import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/presentation/shared/dialogs/mx_folder_form_dialog_parts.dart';

enum _MxFolderFormMode { create, rename }

/// Mock-aligned folder create dialog.
///
/// Returns the trimmed folder name when the user confirms; the color/icon
/// pickers are visual preview state only until the folder data model stores
/// those attributes.
Future<String?> showMxFolderCreateDialog(
  BuildContext context, {
  required String title,
  required String description,
  required String fieldLabel,
  required String colorLabel,
  required String iconLabel,
  required String confirmLabel,
  required String cancelLabel,
  String initialValue = '',
}) async {
  final String? name = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _MxFolderFormDialog(
      mode: _MxFolderFormMode.create,
      title: title,
      description: description,
      fieldLabel: fieldLabel,
      colorLabel: colorLabel,
      iconLabel: iconLabel,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialValue: initialValue,
    ),
  );
  return name;
}

/// Mock-aligned folder rename dialog.
///
/// Returns the trimmed new name when confirmed.
Future<String?> showMxFolderRenameDialog(
  BuildContext context, {
  required String title,
  required String description,
  required String fieldLabel,
  required String helperText,
  required String confirmLabel,
  required String cancelLabel,
  required String initialValue,
}) async {
  final String? name = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _MxFolderFormDialog(
      mode: _MxFolderFormMode.rename,
      title: title,
      description: description,
      fieldLabel: fieldLabel,
      helperText: helperText,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      initialValue: initialValue,
    ),
  );
  return name;
}

class _MxFolderFormDialog extends StatefulWidget {
  const _MxFolderFormDialog({
    required this.mode,
    required this.title,
    required this.description,
    required this.fieldLabel,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.initialValue,
    this.colorLabel,
    this.iconLabel,
    this.helperText,
  });

  final _MxFolderFormMode mode;
  final String title;
  final String description;
  final String fieldLabel;
  final String confirmLabel;
  final String cancelLabel;
  final String initialValue;
  final String? colorLabel;
  final String? iconLabel;
  final String? helperText;

  @override
  State<_MxFolderFormDialog> createState() => _MxFolderFormDialogState();
}

class _MxFolderFormDialogState extends State<_MxFolderFormDialog> {
  static const double _dialogMaxWidth = 432;
  static const double _dialogHorizontalInset = SpacingTokens.lg;
  static const double _buttonHeight = 40;
  static const double _actionButtonWidth = 140;
  static const List<Color> _swatches = <Color>[
    ColorTokens.seedIndigo,
    ColorTokens.seedViolet,
    ColorTokens.seedTeal,
    ColorTokens.seedRose,
    ColorTokens.seedAmber,
    ColorTokens.seedSage,
  ];
  static const List<IconData> _iconChoices = <IconData>[
    Icons.flag_outlined,
    Icons.menu_book_outlined,
    Icons.auto_awesome_outlined,
    Icons.layers_rounded,
    Icons.copy_outlined,
  ];

  late final TextEditingController _controller =
      TextEditingController.fromValue(
        TextEditingValue(
          text: widget.initialValue,
          selection: TextSelection(
            baseOffset: 0,
            extentOffset: widget.initialValue.length,
          ),
        ),
      );
  int _selectedSwatchIndex = 0;
  int _selectedIconIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => StringUtils.trimmed(_controller.text).isNotEmpty;

  void _submit() {
    if (!_canSubmit) {
      return;
    }
    Navigator.of(context).pop(StringUtils.trimmed(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final TextTheme text = context.textTheme;
    final Color previewColor = _swatches[_selectedSwatchIndex];
    final IconData previewIcon = _iconChoices[_selectedIconIndex];
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.all(_dialogHorizontalInset),
        backgroundColor: ColorTokens.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: RadiusTokens.brLg,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.32),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (widget.mode == _MxFolderFormMode.create)
                  MxFolderFormCreateHeader(
                    icon: previewIcon,
                    color: previewColor,
                    title: widget.title,
                    description: widget.description,
                  ),
                if (widget.mode == _MxFolderFormMode.rename)
                  MxFolderFormRenameHeader(
                    title: widget.title,
                    description: widget.description,
                  ),
                _buildFieldSection(scheme: scheme, text: text),
                if (widget.mode == _MxFolderFormMode.create) ...<Widget>[
                  _buildColorSection(scheme: scheme),
                  _buildIconSection(scheme: scheme),
                ],
                _buildActions(scheme: scheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldSection({
    required ColorScheme scheme,
    required TextTheme text,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(
      _dialogHorizontalInset,
      SpacingTokens.md,
      _dialogHorizontalInset,
      SpacingTokens.xxs * 2,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxFolderFormSectionLabel(widget.fieldLabel),
        const SizedBox(height: SpacingTokens.xs + SpacingTokens.xxs),
        _buildTextField(scheme: scheme, text: text),
        if (widget.helperText != null) ...<Widget>[
          const SizedBox(height: SpacingTokens.xs + SpacingTokens.xxs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
            child: Text(
              widget.helperText!,
              style: context.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _buildColorSection({required ColorScheme scheme}) => Padding(
    padding: const EdgeInsets.fromLTRB(
      _dialogHorizontalInset,
      SpacingTokens.md,
      _dialogHorizontalInset,
      SpacingTokens.xxs * 2,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxFolderFormSectionLabel(widget.colorLabel ?? ''),
        const SizedBox(height: SpacingTokens.sm),
        _buildSwatches(scheme: scheme),
      ],
    ),
  );

  Widget _buildIconSection({required ColorScheme scheme}) => Padding(
    padding: const EdgeInsets.fromLTRB(
      _dialogHorizontalInset,
      SpacingTokens.md,
      _dialogHorizontalInset,
      SpacingTokens.xxs * 3,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxFolderFormSectionLabel(widget.iconLabel ?? ''),
        const SizedBox(height: SpacingTokens.sm),
        _buildIconChoices(scheme: scheme),
      ],
    ),
  );

  Widget _buildTextField({
    required ColorScheme scheme,
    required TextTheme text,
  }) => SizedBox(
    height: 44,
    width: double.infinity,
    child: TextField(
      controller: _controller,
      autofocus: true,
      textInputAction: TextInputAction.done,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _submit(),
      style: text.titleSmall?.copyWith(
        color: scheme.onSurface,
        fontWeight: TypographyTokens.semiBold,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: 0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.brMd,
          borderSide: BorderSide(color: scheme.primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.brMd,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    ),
  );

  Widget _buildSwatches({required ColorScheme scheme}) => Row(
    children: <Widget>[
      for (int i = 0; i < _swatches.length; i++) ...<Widget>[
        MxFolderFormColorSwatch(
          key: ValueKey<String>('folder_form_color_$i'),
          color: _swatches[i],
          selected: i == _selectedSwatchIndex,
          onTap: () => setState(() => _selectedSwatchIndex = i),
          surfaceColor: scheme.surfaceContainerHigh,
        ),
        if (i != _swatches.length - 1) const SizedBox(width: SpacingTokens.sm),
      ],
    ],
  );

  Widget _buildIconChoices({required ColorScheme scheme}) => Row(
    children: <Widget>[
      for (int i = 0; i < _iconChoices.length; i++) ...<Widget>[
        MxFolderFormIconChoiceTile(
          key: ValueKey<String>('folder_form_icon_$i'),
          icon: _iconChoices[i],
          selected: i == _selectedIconIndex,
          color: _swatches[_selectedSwatchIndex],
          onTap: () => setState(() => _selectedIconIndex = i),
          scheme: scheme,
        ),
        if (i != _iconChoices.length - 1)
          const SizedBox(width: SpacingTokens.sm),
      ],
    ],
  );

  Widget _buildActions({required ColorScheme scheme}) => Padding(
    padding: const EdgeInsets.fromLTRB(
      _dialogHorizontalInset,
      SpacingTokens.md,
      _dialogHorizontalInset,
      _dialogHorizontalInset,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          width: _actionButtonWidth,
          height: _buttonHeight,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 14),
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
          height: _buttonHeight,
          child: widget.mode == _MxFolderFormMode.create
              ? FilledButton.icon(
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const RoundedRectangleBorder(
                      borderRadius: RadiusTokens.brMd,
                    ),
                  ),
                  icon: const Icon(Icons.create_new_folder_outlined, size: 14),
                  label: Text(widget.confirmLabel),
                )
              : FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
  );
}
