import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/widgets/study_entry_body.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Study entry gate for today and scoped study routes.
///
/// The screen validates route params, shows a preparing state while the
/// provider resolves the request, and redirects to a persisted session when
/// the scope contains eligible cards.
class StudyEntryScreen extends ConsumerWidget {
  const StudyEntryScreen.today({this.studyTypeQuery, this.modeQuery, super.key})
    : entryType = 'today',
      entryRefId = null;

  const StudyEntryScreen.scoped({
    required this.entryType,
    required this.entryRefId,
    this.studyTypeQuery,
    this.modeQuery,
    super.key,
  });

  final String entryType;
  final String? entryRefId;
  final String? studyTypeQuery;
  final String? modeQuery;

  ({
    String entryType,
    String? entryRefId,
    String? studyTypeQuery,
    String? modeQuery,
  })
  get _request => (
    entryType: entryType,
    entryRefId: entryRefId,
    studyTypeQuery: studyTypeQuery,
    modeQuery: modeQuery,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = studyEntryProvider(_request);
    ref.listen<AsyncValue<StudyEntryStartResult>>(provider, (
      AsyncValue<StudyEntryStartResult>? _,
      AsyncValue<StudyEntryStartResult> next,
    ) {
      if (next.asData?.value case StudyEntryStartStarted(:final sessionId)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          context.pushReplacementStudySession(sessionId);
        });
      }
    });

    return MxScaffold(
      appBar: MxAppBar(titleText: l10n.studyEntryTitle),
      body: StudyEntryBody(request: _request, value: ref.watch(provider)),
    );
  }
}
