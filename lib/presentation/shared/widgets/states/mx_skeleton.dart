import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';

/// Loading placeholder block with a subtle pulse.
///
/// Section G of the handoff. Neutral `surfaceContainerHighest` block; the pulse
/// is disabled under reduced-motion. Compose these into row/list skeletons.
class MxSkeleton extends StatefulWidget {
  const MxSkeleton({
    this.width,
    this.height = 12,
    this.borderRadius = RadiusTokens.brMd,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  /// Convenience circular block (e.g. an avatar placeholder).
  const MxSkeleton.circle({required double size, Key? key})
    : this(width: size, height: size, shape: BoxShape.circle, key: key);

  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final BoxShape shape;

  @override
  State<MxSkeleton> createState() => _MxSkeletonState();
}

class _MxSkeletonState extends State<MxSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DurationTokens.slower,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0;
      return;
    }
    if (!_controller.isAnimating) {
      unawaited(_controller.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = context.colorScheme.surfaceContainerHighest;
    return FadeTransition(
      opacity: Tween<double>(
        begin: 1,
        end: 0.58,
      ).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base,
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.circle
              ? null
              : widget.borderRadius,
        ),
      ),
    );
  }
}
