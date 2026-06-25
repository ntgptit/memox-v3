import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/presentation/features/study/widgets/study_speak_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_text_field.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Fill-screen feedback/area widgets, split out of `fill_session_screen.dart`
/// to keep the screen within the file-length limit. Feature-internal — only the
/// Fill screen builds these.

/// A discreet accent text link for the Fill secondary actions the redesign mock
/// dropped — **Hint** (typing, WP-FI2b) and **Mark correct** (wrong, WP-FI2a) —
/// kept off the primary button row so it never crowds Check / Retry / Next.
class FillActionLink extends StatelessWidget {
  const FillActionLink({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
    child: MxTappable(
      onTap: onTap,
      child: MxText(
        label,
        role: MxTextRole.labelMedium,
        color: context.mxColors.accent,
      ),
    ),
  );
}

/// The hint card: an overline + the back / definition (the prompt the learner
/// produces the front from).
class FillHintCard extends StatelessWidget {
  const FillHintCard({required this.prompt, required this.hint, super.key});

  final String prompt;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxCard(
      child: Padding(
        padding: const EdgeInsets.all(MxSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MxText(
              StringUtils.upperFold(prompt),
              role: MxTextRole.labelSmall,
              color: colors.textTertiary,
            ),
            const SizedBox(height: MxSpacing.space2),
            MxText(hint, role: MxTextRole.titleLarge),
          ],
        ),
      ),
    );
  }
}

/// The typing state: an overline label + the free-text answer field, plus the
/// `·`-masked Hint prefix once revealed (WP-FI2b).
class FillTypingArea extends StatelessWidget {
  const FillTypingArea({
    required this.label,
    required this.controller,
    this.revealedHint,
    super.key,
  });

  final String label;
  final TextEditingController controller;

  /// The Hint mask (revealed prefix + `·` per hidden char), or null when no hint
  /// has been revealed for the current card.
  final String? revealedHint;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final String? hint = revealedHint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MxText(
          StringUtils.upperFold(label),
          role: MxTextRole.labelSmall,
          color: colors.textTertiary,
        ),
        const SizedBox(height: MxSpacing.space2),
        MxTextField(controller: controller, autofocus: true),
        if (hint != null) ...<Widget>[
          const SizedBox(height: MxSpacing.space2),
          MxText(
            hint,
            role: MxTextRole.titleMedium,
            color: colors.textSecondary,
          ),
        ],
      ],
    );
  }
}

/// The correct-feedback state: the typed answer over a ✓ glyph (success family),
/// with a speaker button to hear the answer pronunciation (WBS 8.4.3 — Fill
/// speaks the front only once it is revealed, never while it is the hidden
/// answer the learner must produce).
class FillCorrectArea extends StatelessWidget {
  const FillCorrectArea({required this.answer, required this.item, super.key});

  final String answer;

  /// The current card — drives the speaker button's language gate + playback.
  final StudySessionReviewItem item;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.successSoft,
            borderRadius: MxRadius.mdAll,
            border: Border.all(color: colors.success, width: MxStroke.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(MxSpacing.space5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: MxText(answer, role: MxTextRole.titleLarge),
                    ),
                    StudySpeakButton(item: item),
                  ],
                ),
                const SizedBox(height: MxSpacing.space2),
                Icon(Icons.check, size: MxIconSize.lg, color: colors.success),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The wrong-feedback state: the typed answer in a red-bordered box, a "not
/// quite" message, and the correct answer in a green card.
class FillWrongArea extends StatelessWidget {
  const FillWrongArea({
    required this.submitted,
    required this.message,
    required this.correctLabel,
    required this.correct,
    required this.item,
    super.key,
  });

  final String submitted;
  final String message;
  final String correctLabel;
  final String correct;

  /// The current card — drives the speaker button on the revealed correct
  /// answer (WBS 8.4.3).
  final StudySessionReviewItem item;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.dangerSoft,
              borderRadius: MxRadius.mdAll,
              border: Border.all(
                color: colors.danger,
                width: MxStroke.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(MxSpacing.space4),
              child: MxText(
                submitted,
                role: MxTextRole.titleLarge,
                color: colors.danger,
              ),
            ),
          ),
          const SizedBox(height: MxSpacing.space2),
          Row(
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: MxIconSize.sm,
                color: colors.danger,
              ),
              const SizedBox(width: MxSpacing.space1),
              Flexible(
                child: MxText(
                  message,
                  role: MxTextRole.bodySmall,
                  color: colors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: MxSpacing.space4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.successSoft,
              borderRadius: MxRadius.mdAll,
              border: Border.all(
                color: colors.success,
                width: MxStroke.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(MxSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MxText(
                    StringUtils.upperFold(correctLabel),
                    role: MxTextRole.labelSmall,
                    color: colors.success,
                  ),
                  const SizedBox(height: MxSpacing.space1),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: MxText(correct, role: MxTextRole.titleLarge),
                      ),
                      StudySpeakButton(item: item),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
