import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

class DashboardLoadingState extends StatelessWidget {
  const DashboardLoadingState({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    children: const <Widget>[
      SizedBox(height: SpacingTokens.md),
      DashboardResumeCardSkeleton(),
      SizedBox(height: SpacingTokens.md),
      DashboardStatsSkeleton(),
      SizedBox(height: SpacingTokens.md),
      DashboardTodayCardSkeleton(),
      SizedBox(height: SpacingTokens.md),
      DashboardActionSkeleton(),
      SizedBox(height: SpacingTokens.md),
      DashboardRecentDecksSkeleton(),
      SizedBox(height: SpacingTokens.xl),
    ],
  );
}

class DashboardStatsSkeleton extends StatelessWidget {
  const DashboardStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: <Widget>[
      Expanded(child: MxCard(child: DashboardSkeletonBlock(lines: 2))),
      SizedBox(width: SpacingTokens.md),
      Expanded(child: MxCard(child: DashboardSkeletonBlock(lines: 2))),
    ],
  );
}

class DashboardResumeCardSkeleton extends StatelessWidget {
  const DashboardResumeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) =>
      const MxCard(child: DashboardSkeletonBlock(lines: 3, hasActions: true));
}

class DashboardSectionSkeleton extends StatelessWidget {
  const DashboardSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) =>
      const MxCard(child: DashboardSkeletonBlock(lines: 2, hasActions: true));
}

class DashboardTodayCardSkeleton extends StatelessWidget {
  const DashboardTodayCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) =>
      const MxCard(child: DashboardSkeletonBlock(lines: 3, hasActions: true));
}

class DashboardActionSkeleton extends StatelessWidget {
  const DashboardActionSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const MxCard(
    padding: EdgeInsets.symmetric(
      horizontal: SpacingTokens.form,
      vertical: SpacingTokens.sm,
    ),
    child: DashboardSkeletonBlock(lines: 1),
  );
}

class DashboardRecentDecksSkeleton extends StatelessWidget {
  const DashboardRecentDecksSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      MxCard(child: DashboardSkeletonBlock(lines: 2)),
      SizedBox(height: SpacingTokens.sm),
      MxCard(child: DashboardSkeletonBlock(lines: 2)),
      SizedBox(height: SpacingTokens.sm),
      MxCard(child: DashboardSkeletonBlock(lines: 2)),
    ],
  );
}

class DashboardSkeletonBlock extends StatelessWidget {
  const DashboardSkeletonBlock({
    required this.lines,
    this.hasActions = false,
    super.key,
  });

  final int lines;
  final bool hasActions;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const MxSkeleton(width: SizeTokens.avatar, height: SizeTokens.avatar),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int index = 0; index < lines; index++) ...<Widget>[
                  FractionallySizedBox(
                    widthFactor: index == 0 ? 0.8 : 0.55,
                    alignment: Alignment.centerLeft,
                    child: const MxSkeleton(height: 12),
                  ),
                  if (index != lines - 1)
                    const SizedBox(height: SpacingTokens.xs),
                ],
              ],
            ),
          ),
        ],
      ),
      if (hasActions) ...<Widget>[
        const SizedBox(height: SpacingTokens.lg),
        const Align(
          alignment: Alignment.centerRight,
          child: MxSkeleton(width: 168, height: 40),
        ),
      ],
    ],
  );
}
