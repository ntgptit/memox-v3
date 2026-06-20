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
}
