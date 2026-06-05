import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// First-load placeholder for Library Overview — skeleton folder rows.
///
/// Used by `MxRetainedAsyncState.skeletonBuilder` so the first route frame does
/// not flash a high-contrast spinner (`docs/wireframes/02-library.md`).
class LibrarySkeleton extends StatelessWidget {
  const LibrarySkeleton({this.rows = 6, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const ValueKey<String>('library_skeleton'),
    padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
    itemCount: rows,
    separatorBuilder: (_, _) => const SizedBox(height: SpacingTokens.sm),
    itemBuilder: (_, _) => const _SkeletonRow(),
  );
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) => const MxCard(
    child: Row(
      children: <Widget>[
        MxSkeleton(width: 44, height: 44, borderRadius: RadiusTokens.brMd),
        SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.55,
                alignment: Alignment.centerLeft,
                child: MxSkeleton(height: 13),
              ),
              SizedBox(height: SpacingTokens.sm),
              FractionallySizedBox(
                widthFactor: 0.35,
                alignment: Alignment.centerLeft,
                child: MxSkeleton(height: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
