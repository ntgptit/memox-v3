import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// First-load placeholder for Library Overview — skeleton folder rows.
///
/// Used by `MxRetainedAsyncState.skeletonBuilder` so the first route frame does
/// not flash a high-contrast spinner (`docs/wireframes/02-library.md`).
class LibrarySkeleton extends StatelessWidget {
  const LibrarySkeleton({this.rows = 4, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) => ListView(
    key: const ValueKey<String>('library_skeleton'),
    padding: const EdgeInsets.fromLTRB(
      0,
      SpacingTokens.inline,
      0,
      SpacingTokens.md,
    ),
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
        child: MxText(
          AppLocalizations.of(context).libraryLoadingFoldersLabel,
          role: MxTextRole.labelMedium,
          fontWeight: TypographyTokens.bold,
        ),
      ),
      const SizedBox(height: SpacingTokens.sm),
      for (int index = 0; index < rows; index++) ...<Widget>[
        const _SkeletonRow(),
        if (index != rows - 1) const SizedBox(height: SpacingTokens.inline),
      ],
    ],
  );
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) => const MxCard(
    padding: EdgeInsets.symmetric(
      horizontal: SpacingTokens.form,
      vertical: SpacingTokens.md,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MxSkeleton(
          width: SizeTokens.avatar,
          height: SizeTokens.avatar,
          borderRadius: RadiusTokens.brMd,
        ),
        SizedBox(width: SpacingTokens.form),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.48,
                alignment: Alignment.centerLeft,
                child: MxSkeleton(height: 13),
              ),
              SizedBox(height: SpacingTokens.xs),
              FractionallySizedBox(
                widthFactor: 0.60,
                alignment: Alignment.centerLeft,
                child: MxSkeleton(height: 11),
              ),
              SizedBox(height: SpacingTokens.sm),
              Row(
                children: <Widget>[
                  Expanded(flex: 3, child: MxSkeleton(height: 11)),
                  SizedBox(width: SpacingTokens.sm),
                  Expanded(flex: 3, child: MxSkeleton(height: 11)),
                  SizedBox(width: SpacingTokens.sm),
                  Expanded(flex: 2, child: MxSkeleton(height: 11)),
                ],
              ),
              SizedBox(height: SpacingTokens.sm),
              Row(
                children: <Widget>[
                  Expanded(child: MxSkeleton(height: 5)),
                  SizedBox(width: SpacingTokens.sm),
                  MxSkeleton(
                    width: SizeTokens.iconMinor,
                    height: SizeTokens.iconMinor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
