import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

/// Study-session chrome: close, mode badge, thin progress track, n/total.
///
/// Section A of the handoff. The [accent] recolors per study mode (defaults to
/// `primary`). Implements `PreferredSizeWidget` so it can be an `AppBar`
/// replacement in `MxStudyScaffold`.
///
/// Purpose:
/// Provides a reusable MemoX navigation widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared navigation surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - modeLabel: public property.
/// - current: public property.
/// - total: public property.
/// - onClose: callback.
/// - accent: public property.
/// Category:
/// navigation
class MxStudyTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MxStudyTopBar({
    required this.modeLabel,
    required this.current,
    required this.total,
    required this.onClose,
    this.accent,
    super.key,
  });

  final String modeLabel;
  final int current;
  final int total;
  final VoidCallback onClose;
  final Color? accent;

  @override
  Size get preferredSize => const Size.fromHeight(SizeTokens.appbarLg);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color tone = accent ?? scheme.primary;
    final double progress = total <= 0 ? 0 : (current / total).clamp(0, 1);
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: SizeTokens.appbarLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    iconSize: SizeTokens.iconMd,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.xs,
                    ),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: OpacityTokens.focus),
                      borderRadius: RadiusTokens.brFull,
                    ),
                    child: Text(
                      modeLabel,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: tone,
                        fontWeight: TypographyTokens.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$current/$total',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: ClipRRect(
                borderRadius: RadiusTokens.brFull,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: SpacingTokens.xs,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: tone,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
