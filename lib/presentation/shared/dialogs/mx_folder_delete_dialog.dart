import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/theme/extensions/custom_colors.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// Strong folder-delete confirmation dialog.
///
/// This matches the design mock's stronger destructive folder flow: the user
/// must type the folder name to enable the destructive action.
Future<bool> showMxFolderDeleteDialog(
  BuildContext context, {
  required String folderName,
  required String summaryText,
  required String title,
  required String reassuranceText,
  required String confirmLabel,
  required String deleteButtonLabel,
  required String cancelLabel,
  required String confirmHint,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _MxFolderDeleteDialog(
      folderName: folderName,
      summaryText: summaryText,
      title: title,
      reassuranceText: reassuranceText,
      confirmLabel: confirmLabel,
      deleteButtonLabel: deleteButtonLabel,
      cancelLabel: cancelLabel,
      confirmHint: confirmHint,
    ),
  );
  return confirmed ?? false;
}

class _MxFolderDeleteDialog extends HookWidget {
  const _MxFolderDeleteDialog({
    required this.folderName,
    required this.summaryText,
    required this.title,
    required this.reassuranceText,
    required this.confirmLabel,
    required this.deleteButtonLabel,
    required this.cancelLabel,
    required this.confirmHint,
  });

  static const double _dialogMaxWidth = 432;

  final String folderName;
  final String summaryText;
  final String title;
  final String reassuranceText;
  final String confirmLabel;
  final String deleteButtonLabel;
  final String cancelLabel;
  final String confirmHint;

  @override
  Widget build(BuildContext context) {
    final MxTextSubmitState submit = useMxTextSubmitState(
      canSubmit: (String text) => text == folderName,
    );
    final ColorScheme scheme = context.colorScheme;
    final CustomColors colors = context.customColors;
    final TextTheme text = context.textTheme;
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.all(SpacingTokens.lg),
        backgroundColor: ColorTokens.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
          child: _buildDialogSurface(
            context: context,
            scheme: scheme,
            colors: colors,
            text: text,
            submit: submit,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogSurface({
    required BuildContext context,
    required ColorScheme scheme,
    required CustomColors colors,
    required TextTheme text,
    required MxTextSubmitState submit,
  }) => DecoratedBox(
    decoration: BoxDecoration(
      color: scheme.surfaceContainerHigh,
      borderRadius: RadiusTokens.brXl,
    ),
    child: Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildHeader(scheme),
          const SizedBox(height: SpacingTokens.lg),
          MxText(
            title,
            role: MxTextRole.titleLarge,
            textAlign: TextAlign.center,
            color: scheme.onSurface,
            fontWeight: TypographyTokens.bold,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildDescription(scheme, text),
          const SizedBox(height: SpacingTokens.lg),
          _buildReassurance(scheme, colors, text),
          const SizedBox(height: SpacingTokens.lg),
          _buildConfirmSection(context, scheme, text, submit),
          const SizedBox(height: SpacingTokens.lg),
          _buildActions(context, colors, submit),
        ],
      ),
    ),
  );

  Widget _buildHeader(ColorScheme scheme) => MxIconTile(
    icon: Icons.folder_delete_outlined,
    color: scheme.error,
    size: SizeTokens.button,
  );

  Widget _buildDescription(ColorScheme scheme, TextTheme text) => Text.rich(
    TextSpan(
      style: text.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
        height: 1.55,
      ),
      children: <InlineSpan>[
        TextSpan(
          text: folderName,
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: TypographyTokens.bold,
          ),
        ),
        TextSpan(
          text: ' and its $summaryText will be removed from your library.',
        ),
      ],
    ),
    textAlign: TextAlign.center,
  );

  Widget _buildReassurance(
    ColorScheme scheme,
    CustomColors colors,
    TextTheme text,
  ) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.md,
      vertical: SpacingTokens.sm,
    ),
    decoration: BoxDecoration(
      color: colors.success.withValues(alpha: OpacityTokens.focus),
      borderRadius: RadiusTokens.brMd,
      border: Border.all(color: colors.success.withValues(alpha: 0.20)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.shield_outlined,
          size: SizeTokens.iconSm,
          color: colors.success,
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Text(
            reassuranceText,
            style: text.bodySmall?.copyWith(
              color: scheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildConfirmSection(
    BuildContext context,
    ColorScheme scheme,
    TextTheme text,
    MxTextSubmitState submit,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: MxText(
          StringUtils.uppercased(confirmLabel),
          role: MxTextRole.labelMedium,
          color: scheme.onSurfaceVariant,
          fontWeight: TypographyTokens.bold,
        ),
      ),
      const SizedBox(height: SpacingTokens.xs),
      TextField(
        controller: submit.controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          if (!submit.canSubmit) {
            return;
          }
          Navigator.of(context).pop(true);
        },
        decoration: InputDecoration(
          // Keep `confirmHint` in the API for callers, but show the folder
          // name because the destructive confirmation requires an exact match.
          hintText: folderName,
          filled: true,
          fillColor: scheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: RadiusTokens.brMd,
            borderSide: BorderSide(color: scheme.error.withValues(alpha: 0.80)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: RadiusTokens.brMd,
            borderSide: BorderSide(
              color: scheme.error,
              width: BorderTokens.focusWidth,
            ),
          ),
          hintStyle: text.titleMedium?.copyWith(
            color: scheme.onSurfaceVariant.withValues(
              alpha: OpacityTokens.hint,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildActions(
    BuildContext context,
    CustomColors colors,
    MxTextSubmitState submit,
  ) => Row(
    children: <Widget>[
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(SizeTokens.button),
            shape: const RoundedRectangleBorder(
              borderRadius: RadiusTokens.brMd,
            ),
          ),
          child: Text(cancelLabel),
        ),
      ),
      const SizedBox(width: SpacingTokens.md),
      Expanded(
        flex: 2,
        child: FilledButton.icon(
          onPressed: submit.canSubmit
              ? () => Navigator.of(context).pop(true)
              : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(SizeTokens.button),
            backgroundColor: colors.destructiveFill,
            foregroundColor: colors.onDestructiveFill,
            shape: const RoundedRectangleBorder(
              borderRadius: RadiusTokens.brMd,
            ),
          ),
          icon: const Icon(Icons.delete_outline, size: SizeTokens.iconXs),
          label: Text(deleteButtonLabel),
        ),
      ),
    ],
  );
}
