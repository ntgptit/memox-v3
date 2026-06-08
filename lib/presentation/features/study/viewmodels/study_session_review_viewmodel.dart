import 'package:memox/domain/types/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_review_viewmodel.g.dart';

@riverpod
class StudySessionRevealAnswer extends _$StudySessionRevealAnswer {
  @override
  bool build(SessionId sessionId) => false;

  void toggle() => state = !state;
}
