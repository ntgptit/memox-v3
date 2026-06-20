import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Library loading state (mock `03b`): a grouped card of placeholder folder
/// rows — a tile block plus two text-line blocks — so the layout settles before
/// data arrives instead of flashing a spinner. Static (no shimmer) to keep the
/// golden deterministic. WBS 3.1.2.
class LibraryLoadingSkeleton extends StatelessWidget {
  const LibraryLoadingSkeleton({super.key});

  static const int _rows = 4;

  @override
  Widget build(BuildContext context) => MxCard(
    key: const ValueKey<String>('library_skeleton'),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < _rows; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: MxSpacing.space5),
          const _SkeletonRow(),
        ],
      ],
    ),
  );
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) => const Row(
    children: <Widget>[
      _Block(width: MxSpacing.space10, height: MxSpacing.space10),
      SizedBox(width: MxSpacing.space3),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Block(width: 140, height: MxSpacing.space3),
            SizedBox(height: MxSpacing.space2),
            _Block(width: 96, height: MxSpacing.space2),
          ],
        ),
      ),
    ],
  );
}

class _Block extends StatelessWidget {
  const _Block({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: MxRadius.smAll,
      ),
    );
  }
}
