import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';

/// Full-screen load placeholder — use only when no content exists yet
/// (`docs/ui-ux/ui-ux-contract.md` §Loading). Otherwise prefer retained
/// content + an inline indicator.
///
/// Renders a small column of list-row skeletons that approximates the screen
/// being loaded.
class MxLoadingState extends StatelessWidget {
  const MxLoadingState({this.rows = 5, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(SpacingTokens.lg),
    itemCount: rows,
    separatorBuilder: (_, _) => const SizedBox(height: SpacingTokens.md),
    itemBuilder: (BuildContext context, _) => const _SkeletonRow(),
  );
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      MxSkeleton.circle(size: 44),
      SizedBox(width: SpacingTokens.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FractionallySizedBox(
              widthFactor: 0.7,
              alignment: Alignment.centerLeft,
              child: MxSkeleton(height: 12),
            ),
            SizedBox(height: SpacingTokens.sm),
            FractionallySizedBox(
              widthFactor: 0.4,
              alignment: Alignment.centerLeft,
              child: MxSkeleton(height: 12),
            ),
          ],
        ),
      ),
    ],
  );
}
