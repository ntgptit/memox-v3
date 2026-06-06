import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// First-load placeholder for the Flashcard List — skeleton card rows.
///
/// Used by `MxRetainedAsyncState.skeletonBuilder` so the first route frame does
/// not flash a high-contrast spinner (`docs/wireframes/06-flashcard-list.md`
/// §States Loading).
class FlashcardListSkeleton extends StatelessWidget {
  const FlashcardListSkeleton({this.rows = 6, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const ValueKey<String>('flashcard_list_skeleton'),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerLeft,
                child: MxSkeleton(height: 14),
              ),
              SizedBox(height: SpacingTokens.sm),
              FractionallySizedBox(
                widthFactor: 0.7,
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
