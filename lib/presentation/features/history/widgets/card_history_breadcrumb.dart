import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

/// The Card History ancestry trail (kit `09`): `Library › …folders › Deck ›
/// History`. Reuses the deck's flashcard-list read model for the folder ancestry
/// + deck name; the deck crumb is a tappable ancestor (pops back to the list) and
/// `History` is the non-tappable current leaf. Hidden until the deck stream loads.
class CardHistoryBreadcrumb extends ConsumerWidget {
  const CardHistoryBreadcrumb({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Result<FlashcardListDetail>> async = ref.watch(
      flashcardListStreamProvider(deckId),
    );
    final FlashcardListDetail? detail = async.value?.data;
    if (detail == null) {
      return const SizedBox.shrink();
    }

    final List<MxBreadcrumbItem> items = <MxBreadcrumbItem>[
      MxBreadcrumbItem(
        label: l10n.libraryRootLabel,
        icon: Icons.home_outlined,
        onTap: () => context.goNamed(RouteNames.library),
      ),
      for (final Folder folder in detail.breadcrumb)
        MxBreadcrumbItem(
          label: folder.name,
          onTap: () => context.pushNamed(
            RouteNames.folderDetail,
            pathParameters: <String, String>{RouteParams.id: folder.id},
          ),
        ),
      // The deck is a tappable ancestor — pop back to its flashcard list.
      MxBreadcrumbItem(
        label: detail.deck.name,
        onTap: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          }
        },
      ),
      // Current leaf (non-tappable).
      MxBreadcrumbItem(label: l10n.cardHistoryTitle),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: MxSpacing.space2),
      child: MxBreadcrumb(items: items),
    );
  }
}
