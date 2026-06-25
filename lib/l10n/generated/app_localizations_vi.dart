// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'MemoX';

  @override
  String get appDescription => 'Ứng dụng thẻ ghi nhớ ưu tiên ngoại tuyến';

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String get libraryTitle => 'Thư viện';

  @override
  String get progressTitle => 'Tiến độ';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get librarySearchHint => 'Tìm thư mục';

  @override
  String libraryFolderCountHeader(int count) {
    return '$count thư mục';
  }

  @override
  String get libraryLoadingLabel => 'Đang tải thư mục';

  @override
  String get libraryEmptyTitle => 'Bắt đầu thư viện của bạn';

  @override
  String get libraryEmptyMessage =>
      'Thư mục giúp gom các bộ thẻ liên quan lại với nhau. Thêm một thư mục để sắp xếp các bộ thẻ.';

  @override
  String get libraryLoadFailedTitle => 'Không tải được thư viện';

  @override
  String get libraryLoadFailedMessage => 'Đã có lỗi khi tải thư mục của bạn.';

  @override
  String get commonRetryLabel => 'Thử lại';

  @override
  String get librarySearchNoResultsTitle => 'Không tìm thấy thư mục';

  @override
  String librarySearchNoResultsMessage(String term) {
    return 'Không có thư mục nào khớp \"$term\".';
  }

  @override
  String get librarySearchClearLabel => 'Xóa';

  @override
  String get libraryOverflowTooltip => 'Thao tác thư mục';

  @override
  String folderMetaDecks(int count) {
    return '$count bộ thẻ';
  }

  @override
  String folderMetaSubfolders(int count) {
    return '$count thư mục con';
  }

  @override
  String folderMetaCards(int count) {
    return '$count thẻ';
  }

  @override
  String folderDueBadge(int count) {
    return '$count đến hạn';
  }

  @override
  String get folderActionRename => 'Đổi tên';

  @override
  String get folderActionMove => 'Chuyển tới thư mục';

  @override
  String get folderActionDelete => 'Xóa thư mục';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get folderRenameTitle => 'Đổi tên thư mục';

  @override
  String get folderRenameFieldLabel => 'Tên thư mục';

  @override
  String get folderRenameConfirm => 'Đổi tên';

  @override
  String get folderRenamedSnack => 'Đã đổi tên thư mục';

  @override
  String get folderDeleteTitle => 'Xóa thư mục này?';

  @override
  String folderDeleteBlastRadius(int decks, int cards) {
    return 'Thao tác này xóa vĩnh viễn thư mục này, $decks bộ thẻ và $cards thẻ, cùng toàn bộ tiến độ học. Không thể hoàn tác.';
  }

  @override
  String get folderDeleteConfirm => 'Xóa';

  @override
  String get folderDeletedSnack => 'Đã xóa thư mục';

  @override
  String get folderMoveTitle => 'Chuyển thư mục';

  @override
  String get folderMoveRootLabel => 'Thư viện (gốc)';

  @override
  String get folderMoveBlockCycle =>
      'Không thể chuyển vào chính nó hoặc thư mục con';

  @override
  String get folderMoveBlockLockedDecks => 'Thư mục này đang chứa bộ thẻ';

  @override
  String get folderMovedSnack => 'Đã chuyển thư mục';

  @override
  String get folderErrorNameEmpty => 'Hãy nhập tên thư mục.';

  @override
  String get folderErrorNameDuplicate => 'Đã có thư mục trùng tên ở đây.';

  @override
  String get folderErrorNotFound => 'Thư mục này không còn tồn tại.';

  @override
  String get folderErrorMoveCycle =>
      'Bạn không thể chuyển một thư mục vào chính nó hoặc thư mục con của nó.';

  @override
  String get folderErrorMoveLockedDecks =>
      'Thư mục đó đang chứa bộ thẻ nên không thể nhận thư mục con.';

  @override
  String get folderActionGenericError => 'Đã có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get folderMetaEmpty => 'Trống';

  @override
  String get librarySearchTooltip => 'Tìm thư mục';

  @override
  String get libraryCreateFolderTooltip => 'Thư mục mới';

  @override
  String get libraryCreateFolderLabel => 'Tạo thư mục';

  @override
  String get folderCreateTitle => 'Thư mục mới';

  @override
  String get folderCreateNameLabel => 'Tên thư mục';

  @override
  String get folderCreateColorLabel => 'Màu sắc';

  @override
  String get folderCreateIconLabel => 'Biểu tượng';

  @override
  String get folderCreateConfirm => 'Tạo';

  @override
  String get folderCreatedSnack => 'Đã tạo thư mục';

  @override
  String get folderDetailSearchTooltip => 'Tìm trong thư mục này';

  @override
  String get folderDetailSearchHint => 'Tìm trong thư mục này';

  @override
  String get folderDetailLoadFailedTitle => 'Không tải được thư mục';

  @override
  String get folderDetailLoadFailedMessage =>
      'Không thể truy cập thư mục này. Kiểm tra kết nối và thử lại.';

  @override
  String get folderDetailEmptyTitle => 'Thư mục trống';

  @override
  String get folderDetailEmptyMessage =>
      'Thêm một bộ thẻ, hoặc tạo thư mục con để sắp xếp gọn gàng.';

  @override
  String get folderDetailCreateDeck => 'Tạo bộ thẻ';

  @override
  String get folderDetailCreateSubfolder => 'Tạo thư mục con';

  @override
  String folderDetailDecksHeader(int count) {
    return '$count bộ thẻ';
  }

  @override
  String folderDetailFoldersHeader(int count) {
    return '$count thư mục';
  }

  @override
  String get folderStatDecks => 'Bộ thẻ';

  @override
  String get folderStatCards => 'Thẻ';

  @override
  String get folderStatDue => 'Đến hạn';

  @override
  String get folderStatSubfolders => 'Thư mục con';

  @override
  String get deckCreateTitle => 'Bộ thẻ mới';

  @override
  String get deckCreateNameLabel => 'Tên bộ thẻ';

  @override
  String get deckCreateLanguageLabel => 'Ngôn ngữ';

  @override
  String get deckCreateConfirm => 'Tạo';

  @override
  String get deckLanguageKorean => 'Tiếng Hàn';

  @override
  String get deckLanguageEnglish => 'Tiếng Anh';

  @override
  String get deckActionRename => 'Đổi tên';

  @override
  String get deckActionDelete => 'Xóa bộ thẻ';

  @override
  String get deckOverflowTooltip => 'Tùy chọn bộ thẻ';

  @override
  String get deckCreatedSnack => 'Đã tạo bộ thẻ';

  @override
  String get deckRenamedSnack => 'Đã đổi tên bộ thẻ';

  @override
  String get deckDeletedSnack => 'Đã xóa bộ thẻ';

  @override
  String get deckDeleteTitle => 'Xóa bộ thẻ này?';

  @override
  String deckDeleteMessage(int count) {
    return 'Thao tác này xóa vĩnh viễn bộ thẻ này và $count thẻ, cùng toàn bộ tiến độ học. Không thể hoàn tác.';
  }

  @override
  String get deckDeleteConfirm => 'Xóa';

  @override
  String get flashcardSearchTooltip => 'Tìm thẻ';

  @override
  String get flashcardSearchHint => 'Tìm thẻ';

  @override
  String get flashcardLoadFailedTitle => 'Không tải được thẻ';

  @override
  String get flashcardLoadFailedMessage =>
      'Không thể truy cập bộ thẻ này. Kiểm tra kết nối và thử lại.';

  @override
  String get flashcardEmptyTitle => 'Chưa có thẻ nào';

  @override
  String get flashcardEmptyMessage => 'Thêm thẻ đầu tiên để bắt đầu học.';

  @override
  String get flashcardAddCardLabel => 'Thêm thẻ';

  @override
  String flashcardCountHeader(int count) {
    return '$count thẻ';
  }

  @override
  String get flashcardErrorEmpty => 'Mặt trước và mặt sau đều bắt buộc.';

  @override
  String get flashcardErrorDuplicate => 'Đã có thẻ trùng mặt trước và mặt sau.';

  @override
  String get flashcardErrorNotFound => 'Thẻ này không còn tồn tại.';

  @override
  String get flashcardActionGenericError =>
      'Đã có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get cardCreateTitle => 'Thêm thẻ';

  @override
  String get cardEditTitle => 'Sửa thẻ';

  @override
  String get cardFrontLabel => 'Mặt trước';

  @override
  String get cardBackLabel => 'Mặt sau';

  @override
  String get cardCreateConfirm => 'Thêm';

  @override
  String get cardEditConfirm => 'Lưu';

  @override
  String get cardCreatedSnack => 'Đã thêm thẻ';

  @override
  String get cardSavedSnack => 'Đã lưu thẻ';

  @override
  String get cardDeleteTitle => 'Xóa thẻ này?';

  @override
  String get cardDeleteMessage =>
      'Thao tác này xóa vĩnh viễn thẻ này và tiến độ học của nó. Không thể hoàn tác.';

  @override
  String get cardDeleteConfirm => 'Xóa';

  @override
  String get cardDeletedSnack => 'Đã xóa thẻ';

  @override
  String get searchTitle => 'Tìm kiếm';

  @override
  String get searchDockHint => 'Tìm mọi thứ';

  @override
  String get searchIdleTitle => 'Tìm trong thư viện';

  @override
  String get searchIdleMessage => 'Tìm thư mục, bộ thẻ và thẻ.';

  @override
  String get searchNoResultsTitle => 'Không có kết quả';

  @override
  String searchNoResultsMessage(String query) {
    return 'Không có gì khớp với “$query”. Hãy thử từ khác hoặc kiểm tra chính tả.';
  }

  @override
  String get searchFailedTitle => 'Tìm kiếm thất bại';

  @override
  String get searchFailedMessage => 'Hiện chưa thể chạy tìm kiếm.';

  @override
  String get searchRetry => 'Thử lại';

  @override
  String get searchSectionFolders => 'Thư mục';

  @override
  String get searchSectionDecks => 'Bộ thẻ';

  @override
  String get searchSectionFlashcards => 'Thẻ';

  @override
  String searchMoreCount(int count) {
    return '+$count nữa';
  }

  @override
  String dashboardCardsDue(int count) {
    return '$count thẻ đến hạn';
  }

  @override
  String dashboardDecksWithDue(int count) {
    return '$count bộ thẻ';
  }

  @override
  String get dashboardCaughtUpTitle => 'Đã xong hết';

  @override
  String get dashboardCaughtUpMessage => 'Hiện không có thẻ nào đến hạn.';

  @override
  String get dashboardProgressShortcutSub =>
      'Mục tiêu, chuỗi ngày & độ chính xác';

  @override
  String get dashboardLibraryShortcutSub => 'Duyệt thư mục & bộ thẻ';

  @override
  String get dashboardLoadFailedTitle => 'Không tải được trang chủ';

  @override
  String get dashboardLoadFailedMessage =>
      'Đã xảy ra lỗi khi tải tóm tắt hôm nay.';

  @override
  String get libraryRootLabel => 'Gốc';

  @override
  String get sortTooltip => 'Sắp xếp';

  @override
  String get sortSheetTitle => 'Sắp xếp theo';

  @override
  String get sortModeManual => 'Thủ công';

  @override
  String get sortModeName => 'Tên (A–Z)';

  @override
  String get sortModeNewest => 'Mới nhất';

  @override
  String get deckActionMove => 'Chuyển tới thư mục';

  @override
  String get deckMoveTitle => 'Chuyển tới thư mục';

  @override
  String get deckMoveBlockSubfolders => 'Thư mục này đang chứa thư mục con';

  @override
  String get deckMovedSnack => 'Đã chuyển bộ thẻ';

  @override
  String get deckMoveNoTargets =>
      'Chưa có thư mục nào khác có thể chứa bộ thẻ này.';

  @override
  String get deckLastStudiedJustNow => 'vừa xong';

  @override
  String deckLastStudiedMinutes(int count) {
    return '$count phút trước';
  }

  @override
  String deckLastStudiedHours(int count) {
    return '$count giờ trước';
  }

  @override
  String deckLastStudiedDays(int count) {
    return '$count ngày trước';
  }

  @override
  String deckLastStudiedWeeks(int count) {
    return '$count tuần trước';
  }

  @override
  String get commonDone => 'Xong';

  @override
  String get flashcardReorderCardsAction => 'Sắp xếp lại thẻ';

  @override
  String flashcardReorderTitle(String deck) {
    return 'Sắp xếp · $deck';
  }

  @override
  String get flashcardReorderHint => 'Kéo tay cầm để sắp xếp lại thẻ.';

  @override
  String flashcardReorderCountHeader(int count) {
    return '$count thẻ · kéo để sắp xếp';
  }

  @override
  String get flashcardStateNew => 'Thẻ mới · chưa học';

  @override
  String flashcardStateBoxDueIn(int box, int days) {
    return 'Hộp $box · đến hạn sau $days ngày';
  }

  @override
  String flashcardStateBoxDueToday(int box) {
    return 'Hộp $box · đến hạn hôm nay';
  }

  @override
  String get cardDiscardTitle => 'Bỏ thay đổi?';

  @override
  String get cardDiscardMessage => 'Các chỉnh sửa cho thẻ này chưa được lưu.';

  @override
  String get cardDiscardConfirm => 'Bỏ';

  @override
  String get cardDeleteTooltip => 'Xoá thẻ';

  @override
  String get cardDetailsLabel => 'Chi tiết';

  @override
  String get cardDetailsOptional => 'Tuỳ chọn';

  @override
  String get cardDetailsSummary => 'ví dụ · phát âm · gợi ý';

  @override
  String get cardExampleLabel => 'Ví dụ';

  @override
  String get cardPronunciationLabel => 'Phát âm';

  @override
  String get cardHintLabel => 'Gợi ý';

  @override
  String get cardTagsLabel => 'Nhãn';

  @override
  String get cardAddTagLabel => 'Thêm nhãn';

  @override
  String get cardSaveFailedMessage => 'Không thể lưu thay đổi.';

  @override
  String get cardLoadFailedTitle => 'Không tải được thẻ';

  @override
  String get cardLoadFailedMessage => 'Không thể tải thẻ này để chỉnh sửa.';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get studyEntryTitle => 'Học';

  @override
  String get studySessionTitle => 'Học';

  @override
  String get studySessionPlaceholder => 'Phiên ôn tập — sắp ra mắt.';

  @override
  String get studyPreparing => 'Đang chuẩn bị phiên học…';

  @override
  String get studyEntryErrorTitle => 'Không thể bắt đầu học';

  @override
  String get studyEntryErrorMessage =>
      'Không thể chuẩn bị phiên học này. Vui lòng thử lại.';

  @override
  String get studyEmptyCaughtUpTitle => 'Đã xong hết!';

  @override
  String get studyEmptyDeckNoCardsTitle => 'Bộ thẻ chưa có thẻ nào';

  @override
  String get studyEmptyDeckNoCardsMessage => 'Thêm thẻ để bắt đầu học.';

  @override
  String get studyEmptyDeckNoDueMessage =>
      'Hiện không có thẻ nào trong bộ thẻ này đến hạn.';

  @override
  String get studyEmptyFolderNoCardsTitle => 'Thư mục chưa có thẻ nào';

  @override
  String get studyEmptyFolderNoCardsMessage =>
      'Thêm một bộ thẻ và vài thẻ để bắt đầu học.';

  @override
  String get studyEmptyFolderNoDueMessage =>
      'Hiện không có thẻ nào trong thư mục này đến hạn.';

  @override
  String get studyEmptyTodayAllDoneTitle => 'Đã xong hôm nay!';

  @override
  String get studyEmptyTodayAllDoneMessage =>
      'Quay lại vào ngày mai để giữ chuỗi học.';

  @override
  String get studyEmptyTodayNoContentTitle => 'Chưa có thẻ nào';

  @override
  String get studyEmptyTodayNoContentMessage =>
      'Tạo một bộ thẻ và thêm thẻ để bắt đầu học.';

  @override
  String get studyEmptyAllBuriedTitle => 'Đã ẩn hết thẻ cho hôm nay';

  @override
  String get studyEmptyAllBuriedMessage => 'Chúng sẽ quay lại vào ngày mai.';

  @override
  String get studyEmptyAllSuspendedTitle => 'Tất cả thẻ đang tạm dừng';

  @override
  String get studyEmptyAllSuspendedMessage =>
      'Mở lại một số thẻ để bắt đầu học.';

  @override
  String get studyResumeTitle => 'Tiếp tục phiên học?';

  @override
  String get studyResumeMessage =>
      'Bạn có một phiên học chưa hoàn thành cho phạm vi này.';

  @override
  String get studyResumeAction => 'Tiếp tục';

  @override
  String get studyStartOverAction => 'Bắt đầu lại';

  @override
  String get studyStartOverTitle => 'Bắt đầu lại?';

  @override
  String get studyStartOverMessage =>
      'Thao tác này xoá tiến độ hiện tại của phiên này và bắt đầu lại từ đầu.';

  @override
  String get studyActionStudyNew => 'Học thẻ mới';

  @override
  String get studyReviewFrontLabel => 'MẶT TRƯỚC';

  @override
  String get studyReviewBackLabel => 'MẶT SAU';

  @override
  String get studyReviewEmptyTitle => 'Không có gì để ôn';

  @override
  String get studyReviewEmptyMessage => 'Phiên này không có thẻ nào.';

  @override
  String get studyReviewLoadFailedTitle => 'Không tải được phiên';

  @override
  String get studyReviewLoadFailedMessage => 'Không thể tải phiên học này.';

  @override
  String get studyReviewSwipeHint =>
      'Vuốt phải nếu bạn nhớ, vuốt trái nếu chưa';

  @override
  String get studyReviewFinishTitle => 'Đã ôn xong';

  @override
  String get studyReviewFinishMessage =>
      'Bạn đã xem qua tất cả thẻ trong phiên này.';

  @override
  String get studyReviewFinishAction => 'Kết thúc phiên';

  @override
  String get studyExitTitle => 'Thoát phiên học?';

  @override
  String get studyExitMessage =>
      'Tiến độ của bạn đã được lưu và có thể tiếp tục sau. Rời phiên này?';

  @override
  String get studyExitConfirm => 'Thoát';

  @override
  String get studyExitCancel => 'Tiếp tục học';

  @override
  String get studyActionBury => 'Ẩn đến ngày mai';

  @override
  String get studyActionSuspend => 'Tạm dừng thẻ';

  @override
  String get studyResultTitle => 'Hoàn thành phiên học';

  @override
  String get studyResultLoading => 'Đang lưu kết quả của bạn…';

  @override
  String get studyResultHeroTitle => 'Làm tốt lắm!';

  @override
  String studyResultCardsReviewed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã ôn $count thẻ',
    );
    return '$_temp0';
  }

  @override
  String get studyResultCorrect => 'Đúng';

  @override
  String get studyResultWrong => 'Sai';

  @override
  String get studyResultAnswered => 'Đã trả lời';

  @override
  String get studyResultDone => 'Xong';

  @override
  String get studyResultLoadFailedTitle => 'Không tải được kết quả';

  @override
  String get studyResultLoadFailedMessage =>
      'Đã xảy ra lỗi khi tải tóm tắt phiên học này.';

  @override
  String get studyResultSaveFailedBanner =>
      'Không lưu được kết quả. Tiến độ của bạn đã được giữ trên máy.';

  @override
  String get studyResultRetry => 'Thử lưu lại';

  @override
  String get studyResultDefensiveTitle => 'Chưa trả lời thẻ nào';

  @override
  String get studyResultDefensiveMessage =>
      'Phiên học này chưa có câu trả lời nào được ghi lại.';

  @override
  String get studyMatchTitle => 'Ghép các cặp';

  @override
  String get studyMatchSubtitle => 'Chạm vào một từ, rồi chạm nghĩa của nó.';

  @override
  String studyMatchProgress(int matched, int left) {
    return '$matched đã ghép · còn $left';
  }

  @override
  String get studyGuessPrompt => 'Nghĩa của từ này là gì?';

  @override
  String get studyGuessTapToContinue => 'Chạm để tiếp tục';

  @override
  String get studyRecallPrompt => 'Nhớ lại nghĩa';

  @override
  String get studyRecallHint => 'Nhẩm trong đầu, rồi xem đáp án.';

  @override
  String get studyRecallShowAnswer => 'Xem đáp án';

  @override
  String get studyRecallAnswerLabel => 'Đáp án';

  @override
  String get studyRecallGradePrompt => 'Bạn nhớ tốt đến đâu?';

  @override
  String get studyRecallMissed => 'Chưa nhớ';

  @override
  String get studyRecallGotIt => 'Nhớ rồi';

  @override
  String get studyFillPrompt => 'Nhập đáp án';

  @override
  String get studyFillAnswerLabel => 'Câu trả lời của bạn';

  @override
  String get studyFillCheck => 'Kiểm tra';

  @override
  String get studyFillWrongMessage => 'Chưa đúng — xem đáp án bên dưới.';

  @override
  String get studyFillCorrectLabel => 'Đáp án đúng';

  @override
  String get studyFillRetry => 'Thử lại';

  @override
  String get studyFillNext => 'Tiếp';

  @override
  String get studyFillMarkCorrect => 'Tôi đã đúng';

  @override
  String get studyFillHint => 'Gợi ý';

  @override
  String get statsTitle => 'Thống kê';

  @override
  String get statsCardsThisWeekLabel => 'THẺ TUẦN NÀY';

  @override
  String get statsPerDeckMasteryTitle => 'Mức thành thạo theo bộ thẻ';

  @override
  String statsMasteryPercent(int percent) {
    return '$percent%';
  }

  @override
  String statsCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
    );
    return '$_temp0';
  }

  @override
  String get statsNoDecksHint => 'Chưa có bộ thẻ nào để hiển thị';

  @override
  String get statsLoadFailedTitle => 'Không tải được thống kê';

  @override
  String get statsLoadFailedMessage =>
      'Đã xảy ra lỗi khi tải thống kê của bạn.';

  @override
  String get cardHistoryTitle => 'Lịch sử';

  @override
  String get cardHistoryActivityLabel => 'HOẠT ĐỘNG';

  @override
  String get cardHistoryReviewsLabel => 'Lượt ôn';

  @override
  String get cardHistoryRetentionLabel => 'Ghi nhớ';

  @override
  String get cardHistoryAvgTimeLabel => 'TG trung bình';

  @override
  String get cardHistoryStatEmpty => '—';

  @override
  String cardHistoryBoxChip(int box) {
    return 'Hộp $box';
  }

  @override
  String cardHistoryDurationSeconds(String value) {
    return '${value}s';
  }

  @override
  String cardHistoryRowMeta(String relative, String time) {
    return '$relative · $time';
  }

  @override
  String get cardHistoryToday => 'Hôm nay';

  @override
  String get cardHistoryYesterday => 'Hôm qua';

  @override
  String cardHistoryDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days ngày trước',
    );
    return '$_temp0';
  }

  @override
  String get cardHistoryAttemptCorrect => 'Đã ôn · Đúng';

  @override
  String get cardHistoryAttemptRecovered => 'Đã ôn · Gỡ lại';

  @override
  String get cardHistoryAttemptForgot => 'Đã ôn · Quên';

  @override
  String get cardHistoryEventCreated => 'Đã tạo thẻ';

  @override
  String get cardHistoryEventEdited => 'Đã sửa thẻ';

  @override
  String get cardHistoryEventReset => 'Đặt lại tiến độ';

  @override
  String get cardHistoryEventAudio => 'Đã thêm âm thanh';

  @override
  String get cardHistoryEmptyTitle => 'Chưa có lịch sử';

  @override
  String get cardHistoryEmptyMessage =>
      'Hãy học thẻ này, các lượt ôn sẽ xuất hiện ở đây.';

  @override
  String get cardHistoryLoadFailedTitle => 'Không tải được lịch sử';

  @override
  String get cardHistoryLoadFailedMessage =>
      'Không thể tải hoạt động của thẻ này.';

  @override
  String get commonTryAgain => 'Thử lại';

  @override
  String get commonDismiss => 'Bỏ qua';

  @override
  String get tagManagementTitle => 'Thẻ tag';

  @override
  String tagManagementCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count TAG',
    );
    return '$_temp0';
  }

  @override
  String tagManagementCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
    );
    return '$_temp0';
  }

  @override
  String get tagManagementActionsTooltip => 'Tác vụ tag';

  @override
  String tagManagementSheetHeader(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
    );
    return '$name · $_temp0';
  }

  @override
  String get tagManagementRenameAction => 'Đổi tên';

  @override
  String get tagManagementMergeAction => 'Gộp vào…';

  @override
  String get tagManagementDeleteAction => 'Xóa';

  @override
  String get tagManagementRenameTitle => 'Đổi tên tag';

  @override
  String get tagManagementRenameFieldLabel => 'Tên tag';

  @override
  String get tagManagementRenameConfirm => 'Lưu';

  @override
  String get tagManagementMergeConfirm => 'Gộp tag';

  @override
  String tagManagementMergePrompt(String name) {
    return 'Tag “$name” đã tồn tại. Gộp lại?';
  }

  @override
  String tagManagementMergeSheetTitle(String name) {
    return 'Gộp “$name” vào';
  }

  @override
  String get tagManagementSearchHint => 'Tìm tag';

  @override
  String get tagManagementEmptyTitle => 'Chưa có tag nào';

  @override
  String get tagManagementEmptyMessage =>
      'Thêm tag vào thẻ và chúng sẽ xuất hiện ở đây để quản lý.';

  @override
  String get tagManagementSearchEmptyTitle => 'Không tìm thấy tag';

  @override
  String get tagManagementSearchEmptyMessage =>
      'Không có tag nào khớp với tìm kiếm của bạn.';

  @override
  String get tagManagementLoadFailedTitle => 'Không tải được tag';

  @override
  String get tagManagementLoadFailedMessage =>
      'Đã xảy ra lỗi khi tải tag của bạn.';

  @override
  String tagManagementDeleteTitle(String name) {
    return 'Xóa tag “$name”?';
  }

  @override
  String tagManagementDeleteMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
    );
    return 'Tag sẽ bị gỡ khỏi $_temp0. Các thẻ vẫn được giữ lại. Không thể hoàn tác.';
  }

  @override
  String get tagManagementDeleteConfirm => 'Xóa';

  @override
  String get tagManagementBusyRenaming => 'Đang đổi tên…';

  @override
  String get tagManagementBusyMerging => 'Đang gộp tag…';

  @override
  String get tagManagementBusyDeleting => 'Đang xóa…';

  @override
  String get tagManagementRenameFailedTitle => 'Không đổi được tên tag';

  @override
  String get tagManagementRenameFailedMessage =>
      'Đã xảy ra lỗi khi cập nhật tag này. Tag của bạn không thay đổi.';

  @override
  String get tagManagementMergeFailedTitle => 'Không gộp được tag';

  @override
  String get tagManagementMergeFailedMessage =>
      'Đã xảy ra lỗi khi gộp các tag này. Tag của bạn không thay đổi.';

  @override
  String get tagManagementDeleteFailedTitle => 'Không xóa được tag';

  @override
  String get tagManagementDeleteFailedMessage =>
      'Đã xảy ra lỗi khi xóa tag này. Tag của bạn không thay đổi.';

  @override
  String get deckImportTitle => 'Nhập';

  @override
  String get deckImportEmptyTitle => 'Nhập thẻ từ tệp';

  @override
  String get deckImportEmptyMessage =>
      'Chọn tệp CSV hoặc TSV từ thiết bị để đưa thẻ vào MemoX.';

  @override
  String get deckImportChooseFile => 'Chọn tệp';

  @override
  String get deckImportSupportedFormats => 'Hỗ trợ tệp CSV và TSV.';

  @override
  String get deckImportReadyToParse => 'sẵn sàng phân tích';

  @override
  String deckImportFileMeta(String size, String type, String status) {
    return '$size · $type · $status';
  }

  @override
  String deckImportSizeBytes(int bytes) {
    return '$bytes B';
  }

  @override
  String deckImportSizeKb(String value) {
    return '$value KB';
  }

  @override
  String deckImportSizeMb(String value) {
    return '$value MB';
  }

  @override
  String get deckImportClearFile => 'Gỡ tệp';

  @override
  String get deckImportParseFile => 'Phân tích tệp';

  @override
  String get deckImportParseHint =>
      'Chúng tôi sẽ hiện bản xem trước trước khi nhập.';

  @override
  String get deckImportParsing => 'Đang phân tích…';

  @override
  String get deckImportImporting => 'Đang nhập…';

  @override
  String deckImportPreviewSummary(int found, int valid, int skip) {
    return '$found tìm thấy · $valid hợp lệ · $skip bỏ qua';
  }

  @override
  String deckImportSkipWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ có vấn đề và sẽ bị bỏ qua.',
    );
    return '$_temp0';
  }

  @override
  String deckImportAllValid(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tất cả $count thẻ đều hợp lệ.',
    );
    return '$_temp0';
  }

  @override
  String deckImportPreviewLabel(int count) {
    return 'XEM TRƯỚC $count';
  }

  @override
  String deckImportCardPair(String front, String back) {
    return '$front — $back';
  }

  @override
  String get deckImportSkippedRow => 'Dòng bị bỏ qua';

  @override
  String get deckImportDuplicateReason => 'Thẻ trùng';

  @override
  String get deckImportSkipBadge => 'Bỏ';

  @override
  String deckImportCommitButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nhập $count thẻ hợp lệ',
    );
    return '$_temp0';
  }

  @override
  String deckImportSuccessTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã nhập $count thẻ',
    );
    return '$_temp0';
  }

  @override
  String deckImportSuccessMessage(String deck) {
    return 'Chúng đã ở trong bộ thẻ $deck của bạn, sẵn sàng để học.';
  }

  @override
  String get deckImportThisDeck => 'hiện tại';

  @override
  String deckImportPartialTitle(int imported, int skipped) {
    return '$imported đã nhập · $skipped bỏ qua';
  }

  @override
  String get deckImportPartialMessage =>
      'Một số dòng không hợp lệ hoặc bị trùng và đã bị bỏ qua.';

  @override
  String get deckImportImportAnother => 'Nhập tệp khác';

  @override
  String get deckImportOpenDeck => 'Mở bộ thẻ';

  @override
  String get deckImportFailedTitle => 'Nhập thất bại';

  @override
  String get deckImportFailedMessage =>
      'Không có gì được nhập. Tệp có thể bị hỏng hoặc ở định dạng không hỗ trợ.';

  @override
  String get deckImportChooseAnother => 'Chọn tệp khác';

  @override
  String get learningSettingsTitle => 'Học tập';

  @override
  String get learningSettingsSaving => 'Đang lưu…';

  @override
  String get learningSettingsErrorTitle => 'Không tải được cài đặt';

  @override
  String get learningSettingsErrorMessage =>
      'Đã xảy ra lỗi khi tải cài đặt học tập của bạn.';

  @override
  String get learningGoalTitle => 'Mục tiêu mỗi ngày';

  @override
  String get learningGoalOnDesc => 'Số thẻ học mỗi ngày';

  @override
  String get learningGoalOffDesc => 'Đã tắt — học tự do';

  @override
  String get learningGoalUnit => 'thẻ / ngày';

  @override
  String get learningReminderTitle => 'Nhắc nhở hằng ngày';

  @override
  String get learningReminderOffDesc => 'Chưa đặt nhắc nhở';

  @override
  String get appearanceTitle => 'Giao diện';

  @override
  String get appearanceThemeLabel => 'Chủ đề';

  @override
  String get appearanceLight => 'Sáng';

  @override
  String get appearanceLightDesc => 'Luôn sáng';

  @override
  String get appearanceDark => 'Tối';

  @override
  String get appearanceDarkDesc => 'Luôn tối';

  @override
  String get appearanceSystem => 'Hệ thống';

  @override
  String get appearanceSystemDesc => 'Theo cài đặt thiết bị';

  @override
  String get appearanceSystemNote =>
      'Hệ thống theo lịch sáng/tối của thiết bị.';

  @override
  String get appearanceErrorTitle => 'Không tải được giao diện';

  @override
  String get appearanceErrorMessage =>
      'Đã xảy ra lỗi khi tải cài đặt chủ đề của bạn.';

  @override
  String get languageTitle => 'Ngôn ngữ';

  @override
  String get languageOverline => 'Ngôn ngữ ứng dụng';

  @override
  String get languageSystemTitle => 'Mặc định hệ thống';

  @override
  String get languageSystemDesc => 'Theo ngôn ngữ thiết bị';

  @override
  String get languageEnglishTitle => 'English';

  @override
  String get languageEnglishDesc => 'English';

  @override
  String get languageVietnameseTitle => 'Tiếng Việt';

  @override
  String get languageVietnameseDesc => 'Vietnamese';

  @override
  String get languageRestartNote =>
      'Thay đổi được áp dụng ngay trên toàn ứng dụng.';

  @override
  String get languageErrorTitle => 'Không tải được ngôn ngữ';

  @override
  String get languageErrorMessage =>
      'Đã xảy ra lỗi khi tải cài đặt ngôn ngữ của bạn.';

  @override
  String get accountTitle => 'Tài khoản';

  @override
  String get accountSignInTitle => 'Đăng nhập để đồng bộ';

  @override
  String get accountSignInMessage =>
      'Sao lưu bộ thẻ của bạn lên Google Drive và khôi phục trên mọi thiết bị.';

  @override
  String get accountContinueWithGoogle => 'Tiếp tục với Google';

  @override
  String get accountErrorTitle => 'Không tải được tài khoản';

  @override
  String get accountErrorMessage =>
      'Đã xảy ra lỗi khi tải trạng thái tài khoản của bạn.';

  @override
  String get settingsNotSignedIn => 'Chưa đăng nhập';

  @override
  String get settingsSignInPrompt => 'Đăng nhập để sao lưu bộ thẻ của bạn';

  @override
  String get settingsSignIn => 'Đăng nhập';

  @override
  String get settingsRowLearning => 'Học tập';

  @override
  String get settingsRowLearningMeta => 'Mục tiêu ngày, nhắc nhở';

  @override
  String get settingsRowAudio => 'Âm thanh & giọng nói';

  @override
  String get settingsRowAudioMeta => 'Giọng đọc văn bản';

  @override
  String get settingsRowAppearance => 'Giao diện';

  @override
  String get settingsRowAppearanceMeta => 'Chủ đề';

  @override
  String get settingsRowLanguage => 'Ngôn ngữ';

  @override
  String get settingsRowLanguageMeta => 'Ngôn ngữ ứng dụng';

  @override
  String get settingsRowAccount => 'Tài khoản & đồng bộ';

  @override
  String get settingsRowAccountMeta => 'Sao lưu và khôi phục';

  @override
  String get settingsRowAbout => 'Giới thiệu';

  @override
  String get settingsRowAboutMeta => 'Phiên bản, giấy phép';

  @override
  String settingsGoalValue(int count) {
    return '$count/ngày';
  }

  @override
  String get settingsValueOff => 'Tắt';

  @override
  String get settingsValueSoon => 'Sắp có';

  @override
  String get settingsErrorTitle => 'Không tải được cài đặt';

  @override
  String get settingsErrorMessage => 'Đã xảy ra lỗi khi tải cài đặt của bạn.';

  @override
  String get audioSpeechTitle => 'Âm thanh & giọng nói';

  @override
  String get audioLanguageOverline => 'Ngôn ngữ';

  @override
  String get audioVoiceLanguage => 'Ngôn ngữ giọng đọc';

  @override
  String get audioVoiceOverline => 'Giọng đọc';

  @override
  String get audioSystemDefaultVoice => 'Mặc định hệ thống';

  @override
  String get audioPreviewOverline => 'Nghe thử';

  @override
  String get audioPlaySample => 'Phát mẫu';

  @override
  String get audioStop => 'Dừng';

  @override
  String get audioSpeed => 'Tốc độ';

  @override
  String get audioPitch => 'Cao độ';

  @override
  String get audioNoVoicesTitle => 'Chưa cài giọng đọc';

  @override
  String get audioNoVoicesMessage =>
      'Thiết bị của bạn chưa có giọng đọc văn bản cho ngôn ngữ này.';

  @override
  String get audioEngineErrorTitle => 'Không dùng được engine giọng nói';

  @override
  String get audioEngineErrorMessage =>
      'MemoX không truy cập được engine chuyển văn bản thành giọng nói của thiết bị.';

  @override
  String get audioSaving => 'Đang lưu…';

  @override
  String get audioLangKorean => 'Tiếng Hàn';

  @override
  String get audioLangEnglish => 'Tiếng Anh';

  @override
  String get audioSampleKorean => '안녕하세요, 오늘도 공부해요.';

  @override
  String get audioSampleEnglish =>
      'The quick brown fox jumps over the lazy dog.';

  @override
  String get studySpeakPlay => 'Phát âm thanh';

  @override
  String get studySpeakStop => 'Dừng âm thanh';
}
