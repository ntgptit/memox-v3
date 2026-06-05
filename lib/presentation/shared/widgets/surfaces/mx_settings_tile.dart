import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// Backbone of every Settings screen: leading icon, title + optional subtitle,
/// and a trailing control (switch, value+chevron, or radio).
///
/// Section C of the handoff. Use a `Column` of these inside an `MxCard` and a
/// themed `Divider` between rows.
class MxSettingsTile extends StatelessWidget {
  const MxSettingsTile({
    required this.title,
    required this.trailing,
    this.subtitle,
    this.leadingIcon,
    this.onTap,
    super.key,
  });

  /// Switch trailing — wires the row tap to toggle the switch.
  factory MxSettingsTile.toggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
    IconData? leadingIcon,
    Key? key,
  }) => MxSettingsTile(
    key: key,
    title: title,
    subtitle: subtitle,
    leadingIcon: leadingIcon,
    onTap: () => onChanged(!value),
    trailing: Switch(value: value, onChanged: onChanged),
  );

  /// Value + chevron trailing — a navigable row.
  factory MxSettingsTile.navigation({
    required String title,
    required VoidCallback onTap,
    String? value,
    String? subtitle,
    IconData? leadingIcon,
    Key? key,
  }) => MxSettingsTile(
    key: key,
    title: title,
    subtitle: subtitle,
    leadingIcon: leadingIcon,
    onTap: onTap,
    trailing: _ValueChevron(value: value),
  );

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.textTheme;
    final ColorScheme scheme = context.colorScheme;
    return MxTappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: <Widget>[
            if (leadingIcon != null) ...<Widget>[
              Icon(
                leadingIcon,
                size: SizeTokens.iconSm,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: SpacingTokens.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title, style: text.titleSmall),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: SpacingTokens.xxs),
                    Text(
                      subtitle!,
                      style: text.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ValueChevron extends StatelessWidget {
  const _ValueChevron({this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (value != null)
          Text(
            value!,
            style: context.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(width: SpacingTokens.xs),
        Icon(
          Icons.chevron_right,
          size: SizeTokens.iconSm,
          color: scheme.onSurfaceVariant,
        ),
      ],
    );
  }
}
