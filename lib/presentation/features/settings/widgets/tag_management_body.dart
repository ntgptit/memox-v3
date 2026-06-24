import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/viewmodels/tag_management_viewmodel.dart';
import 'package:memox/presentation/features/settings/widgets/tag_management_actions.dart';
import 'package:memox/presentation/features/settings/widgets/tag_row.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Tag-Management body (kit `11`): the "{n} TAGS" overline + a card list of
/// tags, with empty / search-empty / loading / error states. Each row's overflow
/// opens the per-tag action sheet (Rename / Merge / Delete). WBS 8.3.2.
class TagManagementBody extends ConsumerWidget {
  const TagManagementBody({super.key});

  static const double _rowDividerIndent = MxSpacing.space10 + MxSpacing.space3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<TagWithCount>> async = ref.watch(
      tagsWithCountProvider,
    );
    final String term = StringUtils.caseFold(
      StringUtils.trimmed(ref.watch(tagSearchQueryProvider)),
    );

    return AppAsyncBuilder<List<TagWithCount>>(
      value: async,
      loading: (_) => const MxLoadingState(),
      error: (Object error, StackTrace? _) => MxErrorState(
        icon: Icons.cloud_off_outlined,
        title: l10n.tagManagementLoadFailedTitle,
        message: l10n.tagManagementLoadFailedMessage,
      ),
      data: (List<TagWithCount> all) {
        if (all.isEmpty) {
          return MxEmptyState(
            icon: Icons.tag,
            title: l10n.tagManagementEmptyTitle,
            message: l10n.tagManagementEmptyMessage,
          );
        }
        final List<TagWithCount> filtered = term.isEmpty
            ? all
            : <TagWithCount>[
                for (final TagWithCount t in all)
                  if (StringUtils.caseFold(t.name).contains(term)) t,
              ];
        if (filtered.isEmpty) {
          return MxNoResultsState(
            title: l10n.tagManagementSearchEmptyTitle,
            message: l10n.tagManagementSearchEmptyMessage,
          );
        }
        return _list(context, ref, l10n, all: all, filtered: filtered);
      },
    );
  }

  Widget _list(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    required List<TagWithCount> all,
    required List<TagWithCount> filtered,
  }) {
    final MxColors colors = context.mxColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        MxSpacing.screen,
        MxSpacing.space4,
        MxSpacing.screen,
        MxSpacing.space6,
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: MxSpacing.space1,
            bottom: MxSpacing.space2,
          ),
          child: MxText(
            l10n.tagManagementCountLabel(all.length),
            role: MxTextRole.labelMedium,
            color: colors.textSecondary,
          ),
        ),
        MxCard(
          key: const ValueKey<String>('mx-node:11-tag-management/tag-list'),
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.space4,
            vertical: MxSpacing.space2,
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < filtered.length; i++) ...<Widget>[
                if (i > 0) const MxDivider(indent: _rowDividerIndent),
                TagRow(
                  tag: filtered[i],
                  onOverflow: () => runTagOverflow(
                    context,
                    ref,
                    tag: filtered[i],
                    allTags: all,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
