import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_editor_body.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

/// Card create / edit editor screen (mock `07` / `08`): an X / Save app bar, the
/// deck breadcrumb, and FRONT / BACK fields. Pushed over the flashcard list;
/// [cardId] `null` is **create**, otherwise **edit**. Reads the deck +
/// (for edit) the card from the existing `flashcardListStreamProvider`.
///
/// Loading shows a field-shaped skeleton (mock `07`/`08` Loading) and a fetch
/// failure shows the load-error surface with Retry (mock `07`/`08` Load error,
/// row C28). WBS 2.11.2 / 2.12.2.
class FlashcardEditorScreen extends ConsumerWidget {
  const FlashcardEditorScreen({required this.deckId, this.cardId, super.key});

  final String deckId;

  /// The edited card id, or `null` for a new card.
  final String? cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Result<FlashcardListDetail>> async = ref.watch(
      flashcardListStreamProvider(deckId),
    );

    // Retry re-runs the deck/card fetch by re-subscribing the watch stream.
    void retry() => ref.invalidate(flashcardListStreamProvider(deckId));

    return AppAsyncBuilder<Result<FlashcardListDetail>>(
      value: async,
      loading: (_) => _shell(context, l10n, const _EditorLoadingSkeleton()),
      error: (_, _) => _shell(context, l10n, _errorBody(context, l10n, retry)),
      data: (Result<FlashcardListDetail> result) {
        final FlashcardListDetail? detail = result.data;
        if (detail == null) {
          return _shell(context, l10n, _errorBody(context, l10n, retry));
        }
        final String? id = cardId;
        final Flashcard? card = id == null ? null : _findCard(detail.cards, id);
        // Edit target gone (deleted elsewhere) → the load-error surface.
        if (id != null && card == null) {
          return _shell(context, l10n, _errorBody(context, l10n, retry));
        }
        return FlashcardEditorForm(
          deckId: deckId,
          deck: detail.deck,
          breadcrumb: detail.breadcrumb,
          card: card,
        );
      },
    );
  }

  Flashcard? _findCard(List<Flashcard> cards, String id) {
    for (final Flashcard c in cards) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// A bare editor shell (X app bar only) for the transient loading / error
  /// states — there is no card to save yet.
  Widget _shell(BuildContext context, AppLocalizations l10n, Widget body) =>
      MxScaffold(
        appBar: MxAppBar(
          automaticallyImplyLeading: false,
          leading: MxIconButton(
            icon: cardId == null ? Icons.close : Icons.arrow_back,
            tooltip: l10n.commonCancel,
            onPressed: () => context.pop(),
          ),
          title: cardId == null ? l10n.cardCreateTitle : l10n.cardEditTitle,
        ),
        body: body,
      );

  /// The mock `07`/`08` Load-error surface: a centered card with a cloud-off
  /// tile, the editor-specific copy, and a **Retry** that re-fetches (the app
  /// bar's leading button is the escape back to the deck — row C28).
  Widget _errorBody(
    BuildContext context,
    AppLocalizations l10n,
    VoidCallback onRetry,
  ) => MxErrorState(
    title: l10n.cardLoadFailedTitle,
    message: l10n.cardLoadFailedMessage,
    icon: Icons.cloud_off_outlined,
    action: MxPrimaryButton(
      // Lucide `rotate-ccw` (mock) ≈ Material `replay` (counter-clockwise).
      label: l10n.commonRetryLabel,
      icon: Icons.replay,
      fullWidth: true,
      onPressed: onRetry,
    ),
  );
}

/// The card-editor loading state (mock `07`/`08` Loading): static placeholder
/// blocks shaped like the FRONT / BACK labels + fields, the divider, and the
/// Details chips, so the layout settles before the deck/card stream resolves
/// instead of flashing a bare shell. Static (no shimmer) to keep goldens
/// deterministic — mirrors `LibraryLoadingSkeleton`.
class _EditorLoadingSkeleton extends StatelessWidget {
  const _EditorLoadingSkeleton();

  // Measured from the kit spec (`08` Loading): breadcrumb ~220, label 77×12,
  // field 348×96, chips 64/52×24. Heights are token-sized; widths follow the
  // mock.
  static const double _crumbWidth = 220;
  static const double _labelWidth = 77;
  static const double _fieldHeight = 96;
  static const double _chipHeight = 24;

  // A short left-aligned bar — `_SkeletonBox(width:)` alone is stretched by the
  // horizontal (cross-axis) tight constraint of the ListView, so the `Spacer`
  // reserves the remaining width.
  static Widget _bar(double width) => Row(
    children: <Widget>[
      _SkeletonBox(width: width, height: MxSpacing.space3),
      const Spacer(),
    ],
  );

  @override
  Widget build(BuildContext context) => ListView(
    key: const ValueKey<String>('flashcard_editor_skeleton'),
    children: <Widget>[
      // The breadcrumb row stays visible during loading (spec keeps it); the
      // deck path is unknown until the stream resolves, so a skeleton bar
      // stands in for it.
      _bar(_crumbWidth),
      const SizedBox(height: MxSpacing.space4),
      _bar(_labelWidth),
      const SizedBox(height: MxSpacing.space2),
      const _SkeletonBox(height: _fieldHeight, radius: MxRadius.mdAll),
      const SizedBox(height: MxSpacing.space5),
      _bar(_labelWidth),
      const SizedBox(height: MxSpacing.space2),
      const _SkeletonBox(height: _fieldHeight, radius: MxRadius.mdAll),
      const SizedBox(height: MxSpacing.space5),
      const _SkeletonBox(height: MxStroke.hairline),
      const SizedBox(height: MxSpacing.space5),
      const Row(
        children: <Widget>[
          _SkeletonBox(
            width: 64,
            height: _chipHeight,
            radius: MxRadius.pillAll,
          ),
          SizedBox(width: MxSpacing.space2),
          _SkeletonBox(
            width: 52,
            height: _chipHeight,
            radius: MxRadius.pillAll,
          ),
        ],
      ),
    ],
  );
}

/// A single muted placeholder block. `width` null stretches to the row.
class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    this.width,
    this.radius = MxRadius.smAll,
  });

  final double height;
  final double? width;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: radius,
      ),
    );
  }
}
