import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/viewmodels/tag_management_viewmodel.dart';
import 'package:memox/presentation/features/settings/widgets/tag_management_body.dart';
import 'package:memox/presentation/features/settings/widgets/tag_search_dock.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Tag Management — the global tag list with rename / merge / delete (kit screen
/// 11). A top-level immersive route (`/settings/learning/tags`, shell hidden).
///
/// The shell watches [tagsWithCountProvider] only to decide whether to mount the
/// bottom search dock (hidden when there are no tags, per the empty mock); the
/// body owns the list/state rendering. WBS 8.3.2.
class SettingsTagManagementScreen extends ConsumerWidget {
  const SettingsTagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // guard:allow-screen-watch -- reason: the bottom search dock is mounted only
    // when at least one tag exists (per the empty mock), which the shell can only
    // decide from the loaded list; the body owns the list/state rendering.
    final AsyncValue<List<TagWithCount>> async = ref.watch(
      tagsWithCountProvider,
    );
    final bool hasTags = async.asData?.value.isNotEmpty ?? false;
    return MxScaffold(
      appBar: MxAppBar(title: l10n.tagManagementTitle),
      useShell: false,
      bottomNavigationBar: hasTags ? const TagSearchDock() : null,
      body: const TagManagementBody(),
    );
  }
}
