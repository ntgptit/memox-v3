import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/shadow_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

part 'mx_folder_form_dialog_parts.dart';

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

class _MxFolderFormDialog extends HookWidget {
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
  Widget build(BuildContext context) {
    final MxTextSubmitState submit = useMxTextSubmitState(
      initialText: initialValue,
    );
    final ValueNotifier<int> selectedSwatchIndex = useState<int>(0);
    final ValueNotifier<int> selectedIconIndex = useState<int>(0);
    useEffect(() {
      if (mode != _MxFolderFormMode.rename || initialValue.isEmpty) {
        return null;
      }
      submit.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: initialValue.length,
      );
      return null;
    }, <Object?>[mode, initialValue]);

    final ColorScheme scheme = context.colorScheme;
    final TextTheme text = context.textTheme;
    final Color previewColor = _swatches[selectedSwatchIndex.value];
    final IconData previewIcon = _iconChoices[selectedIconIndex.value];
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.all(SpacingTokens.lg),
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
                  blurRadius: ShadowTokens.blurModal,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (mode == _MxFolderFormMode.create)
                  _MxFolderFormCreateHeader(
                    icon: previewIcon,
                    color: previewColor,
                    title: title,
                    description: description,
                  ),
                if (mode == _MxFolderFormMode.rename)
                  _MxFolderFormRenameHeader(
                    title: title,
                    description: description,
                  ),
                _buildFieldSection(
                  context: context,
                  scheme: scheme,
                  text: text,
                  submit: submit,
                ),
                if (mode == _MxFolderFormMode.create) ...<Widget>[
                  _buildColorSection(
                    scheme: scheme,
                    selectedSwatchIndex: selectedSwatchIndex,
                  ),
                  _buildIconSection(
                    scheme: scheme,
                    selectedSwatchIndex: selectedSwatchIndex,
                    selectedIconIndex: selectedIconIndex,
                  ),
                ],
                _buildActions(context: context, scheme: scheme, submit: submit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldSection({
    required BuildContext context,
    required ColorScheme scheme,
    required TextTheme text,
    required MxTextSubmitState submit,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.lg,
      SpacingTokens.md,
      SpacingTokens.lg,
      SpacingTokens.xs,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _MxFolderFormSectionLabel(fieldLabel),
        const SizedBox(height: SpacingTokens.tight),
        _buildTextField(
          context: context,
          scheme: scheme,
          text: text,
          submit: submit,
        ),
        if (helperText != null) ...<Widget>[
          const SizedBox(height: SpacingTokens.tight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
            child: Text(
              helperText!,
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

  Widget _buildColorSection({
    required ColorScheme scheme,
    required ValueNotifier<int> selectedSwatchIndex,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.lg,
      SpacingTokens.md,
      SpacingTokens.lg,
      SpacingTokens.xs,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _MxFolderFormSectionLabel(colorLabel ?? ''),
        const SizedBox(height: SpacingTokens.sm),
        _buildSwatches(
          scheme: scheme,
          selectedSwatchIndex: selectedSwatchIndex,
        ),
      ],
    ),
  );

  Widget _buildIconSection({
    required ColorScheme scheme,
    required ValueNotifier<int> selectedSwatchIndex,
    required ValueNotifier<int> selectedIconIndex,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.lg,
      SpacingTokens.md,
      SpacingTokens.lg,
      SpacingTokens.sm,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _MxFolderFormSectionLabel(iconLabel ?? ''),
        const SizedBox(height: SpacingTokens.sm),
        _buildIconChoices(
          scheme: scheme,
          selectedSwatchIndex: selectedSwatchIndex,
          selectedIconIndex: selectedIconIndex,
        ),
      ],
    ),
  );

  Widget _buildTextField({
    required BuildContext context,
    required ColorScheme scheme,
    required TextTheme text,
    required MxTextSubmitState submit,
  }) => SizedBox(
    height: SizeTokens.avatar,
    width: double.infinity,
    child: TextField(
      controller: submit.controller,
      autofocus: true,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) {
        if (!submit.canSubmit) {
          return;
        }
        Navigator.of(context).pop(submit.trimmedText);
      },
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
          borderSide: BorderSide(
            color: scheme.primary,
            width: BorderTokens.width,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.brMd,
          borderSide: BorderSide(
            color: scheme.primary,
            width: BorderTokens.focusWidth,
          ),
        ),
      ),
    ),
  );

  Widget _buildSwatches({
    required ColorScheme scheme,
    required ValueNotifier<int> selectedSwatchIndex,
  }) => Row(
    children: <Widget>[
      for (int i = 0; i < _swatches.length; i++) ...<Widget>[
        _MxFolderFormColorSwatch(
          key: ValueKey<String>('folder_form_color_$i'),
          color: _swatches[i],
          selected: i == selectedSwatchIndex.value,
          onTap: () => selectedSwatchIndex.value = i,
          surfaceColor: scheme.surfaceContainerHigh,
        ),
        if (i != _swatches.length - 1) const SizedBox(width: SpacingTokens.sm),
      ],
    ],
  );

  Widget _buildIconChoices({
    required ColorScheme scheme,
    required ValueNotifier<int> selectedSwatchIndex,
    required ValueNotifier<int> selectedIconIndex,
  }) => Row(
    children: <Widget>[
      for (int i = 0; i < _iconChoices.length; i++) ...<Widget>[
        _MxFolderFormIconChoiceTile(
          key: ValueKey<String>('folder_form_icon_$i'),
          icon: _iconChoices[i],
          selected: i == selectedIconIndex.value,
          color: _swatches[selectedSwatchIndex.value],
          onTap: () => selectedIconIndex.value = i,
          scheme: scheme,
        ),
        if (i != _iconChoices.length - 1)
          const SizedBox(width: SpacingTokens.sm),
      ],
    ],
  );

  Widget _buildActions({
    required BuildContext context,
    required ColorScheme scheme,
    required MxTextSubmitState submit,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(
      SpacingTokens.lg,
      SpacingTokens.md,
      SpacingTokens.lg,
      SpacingTokens.lg,
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
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.form,
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
          width: _actionButtonWidth,
          height: _buttonHeight,
          child: mode == _MxFolderFormMode.create
              ? FilledButton.icon(
                  onPressed: submit.canSubmit
                      ? () => Navigator.of(context).pop(submit.trimmedText)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.form,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const RoundedRectangleBorder(
                      borderRadius: RadiusTokens.brMd,
                    ),
                  ),
                  icon: const Icon(
                    Icons.create_new_folder_outlined,
                    size: SizeTokens.iconXs,
                  ),
                  label: Text(confirmLabel),
                )
              : FilledButton(
                  onPressed: submit.canSubmit
                      ? () => Navigator.of(context).pop(submit.trimmedText)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.form,
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
  );

  static const double _dialogMaxWidth = 432;
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
}
