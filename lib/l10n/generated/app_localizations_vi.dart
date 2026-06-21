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
  String get libraryRetryLabel => 'Thử lại';

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
}
