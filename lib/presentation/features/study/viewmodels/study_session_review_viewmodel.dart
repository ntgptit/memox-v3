import 'package:memox/domain/types/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_review_viewmodel.g.dart';

@riverpod
class StudySessionReviewController extends _$StudySessionReviewController {
  @override
  StudySessionReviewState build(SessionId sessionId) =>
      const StudySessionReviewState();

  void toggleAnswer() => state = state.copyWith(
    isAnswerVisible: !state.isAnswerVisible,
  );

  void next(int total) {
    if (state.currentIndex >= total - 1) {
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      isAnswerVisible: false,
    );
  }

  void previous() {
    if (state.currentIndex <= 0) {
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex - 1,
      isAnswerVisible: false,
    );
  }
}

class StudySessionReviewState {
  const StudySessionReviewState({
    this.currentIndex = 0,
    this.isAnswerVisible = false,
  });

  final int currentIndex;
  final bool isAnswerVisible;

  StudySessionReviewState copyWith({
    int? currentIndex,
    bool? isAnswerVisible,
  }) => StudySessionReviewState(
    currentIndex: currentIndex ?? this.currentIndex,
    isAnswerVisible: isAnswerVisible ?? this.isAnswerVisible,
  );
}
