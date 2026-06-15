// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'MemoX';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonCreate => 'Tạo';

  @override
  String get commonEdit => 'Chỉnh sửa';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonRename => 'Đổi tên';

  @override
  String get commonImport => 'Nhập';

  @override
  String get commonMove => 'Di chuyển';

  @override
  String get commonClear => 'Xóa chọn';

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String get libraryTitle => 'Thư viện';

  @override
  String get progressTitle => 'Tiến độ';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get dashboardGreetingTitle => 'Chào buổi tối, learner';

  @override
  String get dashboardGreetingSubtitle => 'Sẵn sàng học hôm nay chưa?';

  @override
  String get dashboardTodayReviewTitle => 'Ôn hôm nay';

  @override
  String get dashboardWelcomeTitle => 'Chào mừng đến với MemoX';

  @override
  String get dashboardWelcomeSubtitle => 'Cùng tạo bộ thẻ đầu tiên nhé';

  @override
  String get dashboardOnboardingHeroTitle => 'Sẵn sàng ghi nhớ nhiều hơn?';

  @override
  String get dashboardOnboardingHeroMessage =>
      'Tạo bộ thẻ đầu tiên và thêm vài thẻ. MemoX sẽ tự đưa ra những thẻ phù hợp để ôn mỗi ngày - nhẹ nhàng, theo nhịp của bạn.';

  @override
  String get dashboardCreateFirstDeckAction => 'Tạo bộ thẻ đầu tiên';

  @override
  String get dashboardImportDeckAction => 'Import bộ thẻ';

  @override
  String get dashboardOnboardingLocalFirstTitle => 'Ưu tiên lưu cục bộ';

  @override
  String get dashboardOnboardingLocalFirstMessage =>
      'Thẻ của bạn nằm trên thiết bị này. Đồng bộ là tùy chọn.';

  @override
  String get dashboardOnboardingRhythmTitle => 'Nhịp học hằng ngày';

  @override
  String get dashboardOnboardingRhythmMessage =>
      'Phiên học ngắn; MemoX chọn những thẻ đến hạn mỗi ngày.';

  @override
  String get dashboardOnboardingPressureTitle => 'Không áp lực streak';

  @override
  String get dashboardOnboardingPressureMessage =>
      'Bỏ một ngày thì tiến độ của bạn vẫn an toàn.';

  @override
  String get dashboardOfflineTitle => 'Bạn đang ngoại tuyến.';

  @override
  String get dashboardOfflineMessage =>
      'Thẻ của bạn đã được lưu trên thiết bị này. Đồng bộ Drive sẽ tiếp tục khi bạn kết nối lại.';

  @override
  String dashboardStreakBrokenTitle(int count) {
    return 'Streak tạm dừng ở $count ngày.';
  }

  @override
  String get dashboardStreakBrokenMessage =>
      'Không sao cả - cứ tiếp tục khi bạn sẵn sàng. Thẻ của bạn vẫn ở đây chờ bạn.';

  @override
  String dashboardMorePausedSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phiên tạm dừng khác',
      one: '1 phiên tạm dừng khác',
    );
    return '$_temp0';
  }

  @override
  String get dashboardContinueSessionAction => 'Tiếp tục';

  @override
  String get dashboardResumeSectionTitle => 'Tiếp tục học';

  @override
  String dashboardStreakDays(int count) {
    return '$count ngày';
  }

  @override
  String get dashboardDueTodayTitle => 'Đến hạn hôm nay';

  @override
  String dashboardDueTodayMessage(int count) {
    return '$count thẻ sẵn sàng để ôn';
  }

  @override
  String get dashboardNoDueTitle => 'Đã xong cho hôm nay';

  @override
  String get dashboardNoDueMessage =>
      'Hiện chưa có thẻ nào đến hạn. Bạn vẫn có thể học trước một chút nếu muốn.';

  @override
  String get dashboardStudyTodayAction => 'Học';

  @override
  String get dashboardStartReviewAction => 'Bắt đầu ôn hôm nay';

  @override
  String get dashboardSearchTooltip => 'Tìm kiếm';

  @override
  String get dashboardTodayReviewOverline => 'Ôn hôm nay';

  @override
  String dashboardDueCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ đến hạn',
    );
    return '$_temp0';
  }

  @override
  String dashboardReviewScopeMeta(int deckCount, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      deckCount,
      locale: localeName,
      other: '$deckCount bộ thẻ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes phút',
    );
    return 'Trong $_temp0 · khoảng $_temp1';
  }

  @override
  String dashboardResumeMeta(int answered, int total, String time) {
    return '$answered/$total thẻ · tạm dừng $time';
  }

  @override
  String get dashboardDiscardAction => 'Hủy bỏ';

  @override
  String get dashboardDiscardConfirmTitle => 'Hủy phiên đang tạm dừng?';

  @override
  String get dashboardDiscardConfirmMessage =>
      'Tiến trình trong phiên này sẽ không được lưu.';

  @override
  String get dashboardTodayGoalLabel => 'Mục tiêu hôm nay';

  @override
  String dashboardGoalProgress(int done, int target) {
    return '$done/$target';
  }

  @override
  String get dashboardStartNewLearningAction => 'Bắt đầu học mới';

  @override
  String dashboardNewCardsBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mới',
    );
    return '$_temp0';
  }

  @override
  String get dashboardRecentDecksTitle => 'Bộ thẻ gần đây';

  @override
  String dashboardDeckCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
    );
    return '$_temp0';
  }

  @override
  String dashboardDeckLastStudied(String time) {
    return 'lần cuối $time';
  }

  @override
  String dashboardDeckDueBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đến hạn',
    );
    return '$_temp0';
  }

  @override
  String get progressEntryDeck => 'Bộ thẻ';

  @override
  String get progressEntryFolder => 'Thư mục';

  @override
  String get settingsAppearanceTitle => 'Giao diện';

  @override
  String get settingsStudySectionTitle => 'Học';

  @override
  String get settingsAppSectionTitle => 'Ứng dụng';

  @override
  String get settingsAboutSectionTitle => 'Thông tin';

  @override
  String get settingsOverviewFooter => 'Tạo cho việc học bình tĩnh · MemoX';

  @override
  String get settingsAccountTitle => 'Tài khoản';

  @override
  String get accountSettingsTitle => 'Tài khoản & Đồng bộ Drive';

  @override
  String get accountSignedOutHeading => 'Sao lưu lên Google Drive của bạn';

  @override
  String get accountSignedOutBody =>
      'MemoX hoạt động hoàn toàn offline. Liên kết Drive để bạn tự tải lên và khôi phục bộ thẻ khi muốn — không bao giờ tự động.';

  @override
  String get accountSignInWithGoogle => 'Đăng nhập với Google';

  @override
  String get accountWhatStaysLocalTitle => 'Những gì vẫn ở máy';

  @override
  String get accountStaysLocalDecksTitle => 'Mọi bộ thẻ nằm trên thiết bị này';

  @override
  String get accountStaysLocalDecksBody =>
      'Học, sửa và ôn tập đều chạy offline.';

  @override
  String get accountStaysLocalNoAccountTitle =>
      'Không cần tài khoản để dùng MemoX';

  @override
  String get accountStaysLocalNoAccountBody =>
      'Chỉ đăng nhập khi bạn muốn sao lưu.';

  @override
  String get accountStaysLocalManualTitle => 'Bạn quyết định khi nào tải lên';

  @override
  String get accountStaysLocalManualBody => 'Sao lưu Drive luôn là thủ công.';

  @override
  String get accountUnconfiguredBody =>
      'Bản dựng này chưa hỗ trợ đăng nhập tài khoản.';

  @override
  String get accountUnsupportedBody =>
      'Thiết bị này không hỗ trợ đăng nhập tài khoản.';

  @override
  String get accountSectionLabel => 'Tài khoản';

  @override
  String get accountSignedInProviderLabel => 'Đã đăng nhập · Google';

  @override
  String get accountDriveBackupSectionLabel => 'Sao lưu Drive';

  @override
  String get accountDriveBackupComingSoon =>
      'Tải lên và khôi phục thủ công sắp ra mắt.';

  @override
  String get accountAuthorizeDriveComingSoon =>
      'Cấp quyền Google Drive sắp ra mắt.';

  @override
  String get accountErrorBody => 'Không tải được tài khoản. Vui lòng thử lại.';

  @override
  String get settingsAccountLinkedOverviewTitle => 'Tài khoản & đồng bộ';

  @override
  String get settingsAccountSignInSyncTitle => 'Đăng nhập & đồng bộ';

  @override
  String get settingsAccountSignInSyncSubtitle =>
      'Lưu tiến độ học trên nhiều thiết bị';

  @override
  String get settingsAccountSigningIn => 'Đang đăng nhập...';

  @override
  String settingsAccountOverviewSyncedMockSubtitle(Object email) {
    return '$email · đã đồng bộ 2 phút trước';
  }

  @override
  String settingsAccountOverviewSyncErrorSubtitle(Object email) {
    return '$email · đồng bộ lần cuối 2 ngày trước';
  }

  @override
  String get settingsOverviewSyncRetry => 'Thử lại';

  @override
  String get settingsAppearanceOverviewSubtitle => 'Sáng, tối, hệ thống';

  @override
  String get settingsSoonChip => 'SẮP CÓ';

  @override
  String get settingsLanguageTitle => 'Ngôn ngữ';

  @override
  String get settingsLanguageOverviewSubtitle => 'Tiếng Anh';

  @override
  String get settingsLearningOverviewTitle => 'Học';

  @override
  String get settingsLearningDailyGoalSectionTitle => 'Mục tiêu hằng ngày';

  @override
  String get settingsLearningGoalToggleTitle => 'Bật mục tiêu hằng ngày';

  @override
  String get settingsLearningGoalToggleSubtitleOn =>
      'Theo dõi số thẻ bạn hoàn thành mỗi ngày.';

  @override
  String get settingsLearningGoalToggleSubtitleOff =>
      'Tạm dừng theo dõi mục tiêu mà không mất chuỗi ngày.';

  @override
  String get settingsLearningGoalOffHint =>
      'Mục tiêu đang tắt. Chuỗi ngày của bạn được tạm dừng — nó sẽ không bị đặt lại khi đang tạm dừng.';

  @override
  String get settingsLearningCardsPerDayLabel => 'Thẻ mỗi ngày';

  @override
  String get settingsLearningDragHint => 'Kéo để điều chỉnh theo bước 5';

  @override
  String get settingsLearningStreakToggleTitle => 'Hiển thị bộ đếm chuỗi ngày';

  @override
  String get settingsLearningStreakToggleSubtitle =>
      'Hiển thị chuỗi hiện tại trên Home và Stats.';

  @override
  String get settingsLearningReminderSectionTitle => 'Nhắc nhở';

  @override
  String get settingsLearningReminderHint =>
      'Một lời nhắc nhẹ mỗi ngày. Mặc định tắt.';

  @override
  String get settingsLearningReminderToggleTitle => 'Nhắc nhở hằng ngày';

  @override
  String get settingsLearningReminderToggleSubtitleOn =>
      'Nhắc tôi học mỗi ngày.';

  @override
  String get settingsLearningReminderToggleSubtitleOff =>
      'Bạn tự quyết định khi nào quay lại.';

  @override
  String get settingsLearningReminderTimeLabel => 'Giờ nhắc';

  @override
  String get settingsLearningReminderTimeValue => '20:00';

  @override
  String get settingsLearningNotificationsBlockedTitle =>
      'Thông báo đang bị chặn';

  @override
  String get settingsLearningNotificationsBlockedBody =>
      'Hãy cho phép MemoX trong cài đặt thông báo của điện thoại để nhận lời nhắc.';

  @override
  String get settingsLearningOpenSystemSettings => 'Mở cài đặt hệ thống';

  @override
  String get settingsLearningTagsSectionTitle => 'Nhãn';

  @override
  String settingsLearningTagsSubtitle(int count) {
    return '$count thẻ trong tất cả bộ thẻ';
  }

  @override
  String get settingsLearningFutureStudyDefaultsTitle => 'Mặc định học';

  @override
  String get settingsLearningFutureStudyDefaultsHint =>
      'Có trong bản cập nhật sau.';

  @override
  String get settingsLearningFutureDefaultShuffleTitle => 'Xáo trộn mặc định';

  @override
  String get settingsLearningFutureDefaultShuffleSubtitle =>
      'Trộn ngẫu nhiên thứ tự thẻ trong mọi phiên';

  @override
  String get settingsLearningFutureDefaultStudyModeTitle =>
      'Chế độ học mặc định';

  @override
  String get settingsLearningFutureDefaultStudyModeSubtitle =>
      'Ôn tập, Ghép, Đoán, Gợi nhớ hoặc Điền';

  @override
  String get settingsLearningFutureExampleSentenceTitle => 'Hiển thị câu ví dụ';

  @override
  String get settingsLearningFutureExampleSentenceSubtitle =>
      'Hiện câu ví dụ cùng với nghĩa';

  @override
  String get settingsLearningSavedChip => 'Đã lưu';

  @override
  String get settingsLearningOverviewSummary => '20 thẻ / ngày · 5 chế độ học';

  @override
  String settingsCardsCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
      one: '1 thẻ',
    );
    return '$_temp0';
  }

  @override
  String get settingsManageTagsTitle => 'Quản lý tag';

  @override
  String get settingsManageTagsOverviewSubtitle => '14 tag';

  @override
  String tagHashLabel(String tag) {
    return '#$tag';
  }

  @override
  String get settingsTagsSearchHint => 'Tìm tag';

  @override
  String settingsTagsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tag',
    );
    return '$_temp0';
  }

  @override
  String settingsTagsCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
    );
    return '$_temp0';
  }

  @override
  String get settingsTagsSortMostCards => 'Nhiều thẻ nhất';

  @override
  String get settingsTagsEmptyTitle => 'Chưa có tag nào';

  @override
  String get settingsTagsEmptyMessage =>
      'Tag được thêm khi bạn tạo hoặc sửa thẻ. Mở một thẻ để thêm tag đầu tiên.';

  @override
  String get settingsTagsEmptyAction => 'Tới thư viện';

  @override
  String get settingsTagsSearchEmptyTitle => 'Không có tag phù hợp';

  @override
  String get settingsTagsSearchEmptyMessage =>
      'Không có tag nào khớp với tìm kiếm.';

  @override
  String get settingsTagsActionRename => 'Đổi tên';

  @override
  String get settingsTagsActionMerge => 'Gộp vào tag khác';

  @override
  String get settingsTagsActionDelete => 'Xóa tag (giữ thẻ)';

  @override
  String get settingsTagsContextSheetTitle => 'Hành động với tag';

  @override
  String get settingsTagsMostUsedBadge => 'Dùng nhiều nhất';

  @override
  String get settingsTagsRenameTitle => 'Đổi tên tag';

  @override
  String get settingsTagsRenameHint => 'Nhập tên mới';

  @override
  String get settingsTagsRenameConfirm => 'Đổi tên';

  @override
  String settingsTagsRenameHelper(String tag) {
    return 'Đổi tên sẽ cập nhật mọi thẻ đang dùng $tag.';
  }

  @override
  String settingsTagsRenameConflictMessage(String tag) {
    return 'Tag $tag đã tồn tại. Tiếp tục sẽ gộp hai tag này.';
  }

  @override
  String settingsTagsMergeSheetTitle(String source) {
    return 'Gộp \"$source\" vào…';
  }

  @override
  String get settingsTagsMergeSheetHint => 'Chọn tag đích.';

  @override
  String settingsTagsMergeSheetSummary(int count, String source) {
    return 'Tất cả $count thẻ gắn $source sẽ được gắn lại bằng tag đích. Tag $source sẽ bị xóa.';
  }

  @override
  String get settingsTagsMergeSuggestedSectionTitle => 'Gợi ý';

  @override
  String get settingsTagsMergeAllTagsSectionTitle => 'Tất cả tag';

  @override
  String get settingsTagsMergeConfirmAction => 'Gộp';

  @override
  String get settingsTagsDeleteTitle => 'Xóa tag?';

  @override
  String settingsTagsDeleteMessage(String tag, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
    );
    return 'Xóa \"$tag\"? Thao tác này gỡ tag khỏi $_temp0. Các thẻ không bị xóa.';
  }

  @override
  String get settingsTagsDeleteConfirm => 'Xóa';

  @override
  String get settingsTagsOpErrorTitle => 'Không thể đổi tên tag';

  @override
  String get settingsTagsOpErrorBody =>
      'Không có gì thay đổi. Vui lòng thử lại sau.';

  @override
  String get settingsTagsRetry => 'Thử lại';

  @override
  String get flashcardsTagErrorEmpty => 'Cần nhập tên tag.';

  @override
  String get flashcardsTagErrorComma => 'Tag không được chứa dấu phẩy.';

  @override
  String get flashcardsTagErrorTooLong => 'Tag quá dài (tối đa 50 ký tự).';

  @override
  String get settingsAudioSpeechTitle => 'Âm thanh & giọng nói';

  @override
  String get settingsAudioSpeechOverviewSummary => 'Giọng Hàn · tốc độ 0.9×';

  @override
  String get settingsAudioSpeechSaved => 'Đã lưu';

  @override
  String get settingsAudioSpeechGeneralSectionTitle => 'Chung';

  @override
  String get settingsAudioSpeechAutoPlayTitle => 'Tự phát khi lật thẻ';

  @override
  String get settingsAudioSpeechAutoPlaySubtitle =>
      'Phát mặt trước khi một thẻ mới xuất hiện.';

  @override
  String get settingsAudioSpeechPlayAfterGradingTitle => 'Phát sau khi chấm';

  @override
  String get settingsAudioSpeechPlayAfterGradingSubtitle =>
      'Phát lại thuật ngữ sau khi bạn chấm thẻ.';

  @override
  String get settingsAudioSpeechLanguageSectionTitle => 'Ngôn ngữ';

  @override
  String get settingsAudioSpeechKoreanTabFlag => '한';

  @override
  String get settingsAudioSpeechKoreanTabLabel => 'Tiếng Hàn';

  @override
  String get settingsAudioSpeechEnglishTabFlag => 'EN';

  @override
  String get settingsAudioSpeechEnglishTabLabel => 'Tiếng Anh';

  @override
  String settingsAudioSpeechVoiceSectionTitle(Object language) {
    return 'Giọng · $language';
  }

  @override
  String get settingsAudioSpeechKoreanLanguageLabel => 'Tiếng Hàn';

  @override
  String get settingsAudioSpeechEnglishLanguageLabel => 'Tiếng Anh';

  @override
  String get settingsAudioSpeechKoreanSampleText => '오늘도 한 단어 더 외워봐요.';

  @override
  String get settingsAudioSpeechKoreanSampleHint =>
      'Hôm nay, hãy nhớ thêm một từ nữa.';

  @override
  String get settingsAudioSpeechEnglishSampleText =>
      'One word a day keeps forgetting away.';

  @override
  String get settingsAudioSpeechKoreanSystemVoiceName => 'Mặc định hệ thống';

  @override
  String get settingsAudioSpeechKoreanSystemVoiceMeta =>
      'Dùng giọng tiếng Hàn mặc định của điện thoại';

  @override
  String get settingsAudioSpeechKoreanSujiVoiceName => 'Suji';

  @override
  String get settingsAudioSpeechKoreanSujiVoiceMeta =>
      'Nữ · neural · ngoại tuyến';

  @override
  String get settingsAudioSpeechKoreanMinhoVoiceName => 'Minho';

  @override
  String get settingsAudioSpeechKoreanMinhoVoiceMeta =>
      'Nam · neural · ngoại tuyến';

  @override
  String get settingsAudioSpeechKoreanEunhaVoiceName => 'Eunha';

  @override
  String get settingsAudioSpeechKoreanEunhaVoiceMeta => 'Nữ · tiêu chuẩn';

  @override
  String get settingsAudioSpeechEnglishSystemVoiceName => 'Mặc định hệ thống';

  @override
  String get settingsAudioSpeechEnglishSystemVoiceMeta =>
      'Dùng giọng tiếng Anh mặc định của điện thoại';

  @override
  String get settingsAudioSpeechEnglishEmmaVoiceName => 'Emma';

  @override
  String get settingsAudioSpeechEnglishEmmaVoiceMeta =>
      'Nữ · neural · ngoại tuyến';

  @override
  String get settingsAudioSpeechEnglishRyanVoiceName => 'Ryan';

  @override
  String get settingsAudioSpeechEnglishRyanVoiceMeta =>
      'Nam · neural · ngoại tuyến';

  @override
  String get settingsAudioSpeechDefaultVoiceBadge => 'Mặc định';

  @override
  String settingsAudioSpeechNoVoicesTitle(Object language) {
    return 'Chưa cài giọng $language';
  }

  @override
  String settingsAudioSpeechNoVoicesBody(Object language) {
    return 'Hãy tải một giọng $language trong cài đặt giọng nói của điện thoại để bật phát âm.';
  }

  @override
  String get settingsAudioSpeechOpenSystemSpeech => 'Mở cài đặt giọng nói';

  @override
  String get settingsAudioSpeechSpeechRateLabel => 'Tốc độ phát âm';

  @override
  String get settingsAudioSpeechSpeechRateMinLabel => '0.3×';

  @override
  String get settingsAudioSpeechSpeechRateDefaultLabel => 'Mặc định';

  @override
  String get settingsAudioSpeechSpeechRateMaxLabel => '0.7×';

  @override
  String get settingsAudioSpeechPitchLabel => 'Cao độ';

  @override
  String get settingsAudioSpeechPitchMinLabel => '0.70';

  @override
  String get settingsAudioSpeechPitchDefaultLabel => '1.00';

  @override
  String get settingsAudioSpeechPitchMaxLabel => '1.50';

  @override
  String get settingsAudioSpeechVolumeLabel => 'Âm lượng';

  @override
  String get settingsAudioSpeechVolumeMinLabel => '0%';

  @override
  String get settingsAudioSpeechVolumeMidLabel => '50%';

  @override
  String get settingsAudioSpeechVolumeMaxLabel => '100%';

  @override
  String settingsAudioSpeechRateValueLabel(String value) {
    return '$value×';
  }

  @override
  String settingsAudioSpeechVolumeValueLabel(String value) {
    return '$value%';
  }

  @override
  String settingsAudioSpeechResetVoiceSettings(Object language) {
    return 'Đặt lại cài đặt giọng $language';
  }

  @override
  String get settingsAudioSpeechResetAction => 'Đặt lại';

  @override
  String get settingsAudioSpeechPreviewSectionTitle => 'Xem trước';

  @override
  String get settingsAudioSpeechPreviewHint =>
      'Một câu ngắn an toàn. Chỉ phần mặt trước của thẻ được phát.';

  @override
  String get settingsAudioSpeechPreviewVoiceLabel => 'Nghe thử giọng';

  @override
  String get settingsAudioSpeechPlayingLabel => 'Đang phát… chạm để dừng';

  @override
  String get settingsAudioSpeechSupportedLanguagesTitle =>
      'Về ngôn ngữ được hỗ trợ';

  @override
  String get settingsAudioSpeechSupportedLanguagesBody =>
      'MemoX hiện phát được tiếng Hàn và tiếng Anh. Các thẻ ngôn ngữ khác sẽ im lặng và không bao giờ đọc mặt sau.';

  @override
  String get settingsAudioSpeechChangesSavedText =>
      'Mọi thay đổi được lưu tự động.';

  @override
  String get settingsAudioSpeechEngineUnavailableTitle =>
      'Text-to-speech không khả dụng';

  @override
  String get settingsAudioSpeechEngineUnavailableBody =>
      'Hãy cài một TTS engine trong cài đặt của điện thoại để bật phát âm thanh.';

  @override
  String get settingsAudioSpeechOpenSystemSettings => 'Mở cài đặt hệ thống';

  @override
  String get settingsAboutMemoXTitle => 'Thông tin MemoX';

  @override
  String settingsAboutVersion(Object version) {
    return 'Phiên bản $version';
  }

  @override
  String get settingsAboutMessage =>
      'MemoX giữ việc học flashcard theo hướng local-first, bình tĩnh và sẵn sàng sao lưu khi bạn chọn.';

  @override
  String get settingsAboutLegalese => 'MemoX';

  @override
  String get errorUnexpected => 'Đã xảy ra lỗi.';

  @override
  String get foldersRenameTitle => 'Đổi tên thư mục';

  @override
  String get foldersUpdatedMessage => 'Đã cập nhật thư mục.';

  @override
  String get foldersMoveTitle => 'Di chuyển thư mục';

  @override
  String get foldersMoveRootTitle => 'Gốc thư viện';

  @override
  String get foldersMoveRootSubtitle => 'Di chuyển thư mục này về gốc';

  @override
  String get foldersMovedMessage => 'Đã di chuyển thư mục.';

  @override
  String get foldersDeletedMessage => 'Đã xóa thư mục.';

  @override
  String get folderDeleteDialogTitle => 'Xóa thư mục này?';

  @override
  String get folderDeleteDialogReassurance =>
      'Thẻ trong các bộ đó sẽ chuyển sang \"Unsorted\" - không có gì bị mất vĩnh viễn.';

  @override
  String get folderDeleteDialogConfirmLabel => 'Nhập để xác nhận';

  @override
  String get folderDeleteDialogDeleteButton => 'Xóa thư mục';

  @override
  String folderDetailDeckMeta(int cardCount, String relativeTime) {
    return '$cardCount thẻ · $relativeTime';
  }

  @override
  String get decksDeleteTitle => 'Xóa bộ thẻ';

  @override
  String get decksDeleteMessage =>
      'Thao tác này sẽ xóa toàn bộ bộ thẻ và tất cả flashcard bên trong.';

  @override
  String get decksDeletedMessage => 'Đã xóa bộ thẻ.';

  @override
  String get flashcardsActionsTitle => 'Thao tác flashcard';

  @override
  String get flashcardsSearchHint => 'Tìm flashcard';

  @override
  String get flashcardsEmptyTitle => 'Chưa có flashcard nào';

  @override
  String get flashcardsEmptyMessage =>
      'Hãy thêm thẻ thủ công hoặc nhập chúng vào bộ thẻ này.';

  @override
  String get flashcardsNoResultsTitle => 'Không có flashcard phù hợp';

  @override
  String get flashcardsNoResultsMessage =>
      'Không có flashcard nào trong bộ thẻ này khớp với tìm kiếm của bạn.';

  @override
  String get flashcardsClearSearchAction => 'Xóa';

  @override
  String get flashcardEditorTitle => 'Thẻ mới';

  @override
  String get flashcardEditorBreadcrumbFolder => 'Thư mục';

  @override
  String get flashcardEditorBreadcrumbDeck => 'Bộ thẻ';

  @override
  String get flashcardEditorBreadcrumbCurrent => 'Thẻ mới';

  @override
  String get flashcardEditorDestinationDeckLabel => 'Bộ thẻ đã chọn';

  @override
  String get flashcardEditorRequiredWord => 'Bắt buộc';

  @override
  String get flashcardEditorFrontHeading => 'Mặt trước';

  @override
  String get flashcardEditorBackHeading => 'Mặt sau';

  @override
  String get flashcardEditorFrontPlaceholder => 'Thuật ngữ bạn muốn ghi nhớ';

  @override
  String get flashcardEditorBackPlaceholder => 'Thêm nghĩa hoặc bản dịch.';

  @override
  String get flashcardEditorMoreFieldsLabel => 'Thêm chi tiết';

  @override
  String get flashcardEditorMoreFieldsSummary => 'ví dụ · gợi ý · phát âm';

  @override
  String get flashcardEditorExampleLabel => 'Ví dụ';

  @override
  String get flashcardEditorPronunciationLabel => 'Phát âm';

  @override
  String get flashcardEditorHintLabel => 'Gợi ý';

  @override
  String get flashcardEditorTagsLabel => 'THẺ';

  @override
  String get flashcardEditorTagsOptionalLabel => 'không bắt buộc';

  @override
  String get flashcardEditorAddTagLabel => 'Thêm thẻ';

  @override
  String get flashcardEditorSaveCardLabel => 'Lưu thẻ';

  @override
  String get flashcardEditorSaveHelperText =>
      'Mặt trước và mặt sau là bắt buộc để lưu.';

  @override
  String get flashcardEditorSampleExample => '안녕하세요, 저는 민수입니다.';

  @override
  String get flashcardEditorSamplePronunciation => 'annyeonghaseyo';

  @override
  String get flashcardEditorSampleHint =>
      'Bắt đầu bằng một lời chào thân thiện.';

  @override
  String get flashcardEditorFrontError => 'Mặt trước là bắt buộc.';

  @override
  String get flashcardEditorBackError => 'Mặt sau là bắt buộc.';

  @override
  String get flashcardEditorSaveFailedMessage =>
      'Không thể lưu thẻ này. Thử lại.';

  @override
  String get flashcardsEditTitle => 'Sửa thẻ';

  @override
  String get flashcardsLoadErrorTitle => 'Không thể tải thẻ này';

  @override
  String get flashcardsLoadErrorMessage =>
      'Dữ liệu của bạn vẫn an toàn trên thiết bị này. Hãy thử lại sau một lát.';

  @override
  String get flashcardsLoadErrorBackAction => 'Quay lại bộ thẻ';

  @override
  String get flashcardsEditDangerZoneLabel => 'Khu vực nguy hiểm';

  @override
  String get flashcardsEditSaveHelperText =>
      'Các thay đổi sẽ chỉ lưu trên thiết bị này.';

  @override
  String get flashcardsEditSaveFailedMessage =>
      'Không thể lưu thay đổi. Không có gì bị mất. Hãy bấm Lưu để thử lại.';

  @override
  String get flashcardsDeleteCardTitle => 'Xóa flashcard này?';

  @override
  String flashcardsDeleteCardMessage(int reviewCount) {
    return 'Thao tác này sẽ xóa thẻ và $reviewCount lần ôn tập khỏi lịch sử. Các thẻ khác trong bộ này không bị ảnh hưởng.';
  }

  @override
  String get flashcardsDeleteCardAction => 'Xóa thẻ';

  @override
  String get flashcardsFieldTagsLabel => 'Thẻ phân loại';

  @override
  String get flashcardsTagsSheetTitle => 'Thêm tag';

  @override
  String get flashcardsTagsConfirmAction => 'Thêm';

  @override
  String get flashcardsSaveAndAddNextTooltip => 'Lưu và thêm thẻ khác';

  @override
  String get flashcardsSavedMessage => 'Đã lưu thẻ.';

  @override
  String get flashcardsSaveChanges => 'Lưu thay đổi';

  @override
  String get flashcardsLearningContentChangedTitle =>
      'Bạn đã thay đổi nội dung học.';

  @override
  String get flashcardsLearningContentChangedMessage =>
      'Giữ tiến độ hiện tại hay reset flashcard này?';

  @override
  String get flashcardsKeepProgressAction => 'Giữ';

  @override
  String get flashcardsResetProgressAction => 'Reset';

  @override
  String get flashcardsUpdatedMessage => 'Đã cập nhật flashcard.';

  @override
  String get flashcardsCreatedMessage => 'Đã tạo flashcard.';

  @override
  String get flashcardsDiscardChangesTitle => 'Hủy thay đổi?';

  @override
  String get flashcardsDiscardChangesMessage =>
      'Các thay đổi flashcard chưa lưu sẽ bị mất.';

  @override
  String get flashcardsDiscardChangesAction => 'Hủy thay đổi';

  @override
  String get flashcardsKeepEditingAction => 'Tiếp tục sửa';

  @override
  String get studyEntryTitle => 'Học';

  @override
  String get studyEntryPreparingTitle => 'Đang chuẩn bị phiên học';

  @override
  String get studyEntryPreparingMessage =>
      'Đang xác thực phạm vi và tải trạng thái học.';

  @override
  String get studyEntryResumeRequiredTitle => 'Đã có phiên học đang diễn ra';

  @override
  String get studyEntryResumeRequiredMessage =>
      'Chúng tôi đã tìm thấy một phiên học hiện có cho phạm vi này. Hãy chọn cách tiếp tục.';

  @override
  String get studyEntryResumeRequiredHeader => 'Chọn thao tác';

  @override
  String get studyEntryResumeRequiredResumeAction => 'Tiếp tục';

  @override
  String get studyEntryResumeRequiredStartOverAction => 'Bắt đầu lại';

  @override
  String get studyEntryResumeRequiredStartOverConfirmTitle =>
      'Bắt đầu lại và bỏ phiên học hiện tại?';

  @override
  String get studyEntryResumeRequiredStartOverConfirmMessage =>
      'Thao tác này sẽ hủy phiên học đang có và tạo một phiên mới cho cùng phạm vi học.';

  @override
  String get studyEntryResumeRequiredStartOverConfirmAction => 'Bắt đầu lại';

  @override
  String get studyEntryResumeRequiredStartOverFailed =>
      'Không thể bắt đầu lại. Vui lòng thử lại.';

  @override
  String get studyEntryInvalidTitle => 'Không thể mở phần học';

  @override
  String get studyEntryInvalidMessage =>
      'Tham số của đường dẫn học không hợp lệ.';

  @override
  String get studySessionTitle => 'Phiên học';

  @override
  String get studySessionGuessModeLabel => 'ĐOÁN';

  @override
  String get studySessionGuessPromptLabel => 'Đây là gì?';

  @override
  String studySessionGuessNextCardInLabel(String seconds) {
    return 'Thẻ tiếp theo sau ${seconds}s';
  }

  @override
  String get studySessionGuessSkipAction => 'Bỏ qua sang thẻ tiếp theo';

  @override
  String get studySessionGuessCorrectAnnouncement => 'Chính xác';

  @override
  String studySessionGuessWrongAnnouncement(String answer) {
    return 'Sai. Đáp án là $answer.';
  }

  @override
  String studySessionGuessOptionSemanticsLabel(
    String letter,
    String title,
    String description,
  ) {
    return 'Lựa chọn $letter: $title. $description';
  }

  @override
  String studySessionProgressLabel(int current, int total) {
    return '$current / $total';
  }

  @override
  String get studySessionFrontLabel => 'Mặt trước';

  @override
  String get studySessionBackLabel => 'Mặt sau';

  @override
  String get studySessionMeaningLabel => 'Nghĩa';

  @override
  String get studySessionSwipeHint => 'Vuốt sang trái để sang thẻ tiếp theo';

  @override
  String get studySessionRecallModeLabel => 'RECALL';

  @override
  String studySessionRecallShowAnswerAction(int seconds) {
    return 'Hiện đáp án · ${seconds}s';
  }

  @override
  String get studySessionRecallTimeoutCaption => 'Hết giờ - tự chấm điểm';

  @override
  String get studySessionEditCardAction => 'Chỉnh sửa thẻ này';

  @override
  String get studySessionSpeakFrontAction => 'Nghe mặt trước';

  @override
  String get studySessionFillModeLabel => 'FILL';

  @override
  String get studySessionFillHintAction => 'Gợi ý';

  @override
  String get studySessionFillCheckAction => 'Kiểm tra';

  @override
  String get studySessionFillMarkCorrectAction => 'Đánh dấu đúng';

  @override
  String get studySessionFillTryAgainAction => 'Thử lại';

  @override
  String get studySessionFillSpeakCorrectAnswerAction => 'Nghe đáp án đúng';

  @override
  String get studySessionFillReadyToFinishMessage =>
      'Tất cả thẻ đã được trả lời. Hãy hoàn tất phiên để lưu tiến độ.';

  @override
  String studySessionFillCorrectAnnouncement(String front) {
    return 'Đúng. $front.';
  }

  @override
  String studySessionFillWrongAnnouncement(String input, String front) {
    return 'Sai rồi. Bạn đã nhập $input. Đáp án là $front.';
  }

  @override
  String get studySessionBuryUntilTomorrowAction => 'Ẩn đến ngày mai';

  @override
  String get studySessionSuspendAction => 'Tạm dừng thẻ';

  @override
  String get studySessionBurySuccessMessage => 'Đã ẩn thẻ đến ngày mai.';

  @override
  String get studySessionSuspendSuccessMessage => 'Đã tạm dừng thẻ.';

  @override
  String get studySessionCardActionFailedMessage =>
      'Không thể cập nhật thẻ này. Vui lòng thử lại.';

  @override
  String get studyPreviousAction => 'Trước';

  @override
  String get studySessionShowAction => 'Hiện đáp án';

  @override
  String get studySessionHideAction => 'Ẩn đáp án';

  @override
  String get studySessionSavingAnswerMessage => 'Đang lưu câu trả lời...';

  @override
  String get studySessionRecordFailedMessage =>
      'Không thể lưu câu trả lời này. Vui lòng thử lại.';

  @override
  String get studySessionAllAnsweredMessage =>
      'Tất cả thẻ đã được trả lời. Hãy hoàn tất phiên để lưu tiến độ.';

  @override
  String get studySessionFinalizingMessage => 'Đang hoàn tất phiên học...';

  @override
  String get studySessionFinalizeFailedMessage =>
      'Không thể hoàn tất phiên học này. Vui lòng thử lại.';

  @override
  String get studySessionNotFoundTitle => 'Không tìm thấy phiên học';

  @override
  String get studySessionNotFoundMessage => 'Phiên học này không còn tồn tại.';

  @override
  String get studySessionLoadFailedTitle => 'Không thể tải phiên học';

  @override
  String get studySessionLoadFailedMessage =>
      'Không thể tải phiên học này. Hãy thử lại.';

  @override
  String get studySessionExitConfirmTitle => 'Rời phiên này?';

  @override
  String get studySessionExitConfirmMessage =>
      'Tiến độ của bạn đã được lưu và có thể tiếp tục sau.';

  @override
  String get studySessionExitConfirmAction => 'Rời phiên';

  @override
  String get studySessionExitKeepStudyingAction => 'Tiếp tục học';

  @override
  String get studyFinalizeAction => 'Hoàn tất phiên';

  @override
  String get studyResultTitle => 'Kết quả học';

  @override
  String get studyResultCards => 'Thẻ';

  @override
  String get studyResultAnswered => 'Đã trả lời';

  @override
  String studyResultCardsCompleted(int completed, int total) {
    return 'Đã hoàn thành $completed/$total thẻ';
  }

  @override
  String get studyResultBackToLibraryAction => 'Về thư viện';

  @override
  String get studyResultBackToHomeAction => 'Về trang chủ';

  @override
  String get studyResultCompleted => 'Đã hoàn thành';

  @override
  String get studyResultCancelled => 'Đã hủy';

  @override
  String get studyResultFailedFinalize => 'Finalize lỗi. Có thể thử lại.';

  @override
  String get studyResultInProgress => 'Đang học';

  @override
  String get studyResultDraft => 'Bản nháp';

  @override
  String get studyResultBreakdownTitle => 'Kết quả';

  @override
  String get studyResultPassed => 'Qua';

  @override
  String get studyResultForgot => 'Quên';

  @override
  String get studyResultInvalidTitle => 'Không thể mở kết quả';

  @override
  String get studyResultInvalidMessage =>
      'Tham số của đường dẫn kết quả học không hợp lệ.';

  @override
  String get studyResultNotCompleteTitle => 'Không có kết quả';

  @override
  String studyResultNotCompleteMessageWithStatus(String status) {
    return 'Phiên học này chưa được hoàn tất. Trạng thái hiện tại: $status.';
  }

  @override
  String relativeTimeAgo(String unit, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phút trước',
      one: '1 phút trước',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giờ trước',
      one: '1 giờ trước',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày trước',
      one: '1 ngày trước',
    );
    String _temp3 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tuần trước',
      one: '1 tuần trước',
    );
    String _temp4 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tháng trước',
      one: '1 tháng trước',
    );
    String _temp5 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count năm trước',
      one: '1 năm trước',
    );
    String _temp6 = intl.Intl.selectLogic(unit, {
      'justNow': 'vừa xong',
      'minutes': '$_temp0',
      'hours': '$_temp1',
      'days': '$_temp2',
      'weeks': '$_temp3',
      'months': '$_temp4',
      'years': '$_temp5',
      'other': 'vừa xong',
    });
    return '$_temp6';
  }

  @override
  String get studyForgotAction => 'Đã quên';

  @override
  String get studyNextAction => 'Tiếp theo';

  @override
  String get studyGotItAction => 'Đã nhớ';

  @override
  String get studyEmpty_deck_noCards_title => 'Bộ này chưa có thẻ nào';

  @override
  String get studyEmpty_deck_noCards_cta => 'Thêm thẻ';

  @override
  String get studyEmpty_deck_noDueCards_title => 'Đã ôn hết hôm nay';

  @override
  String get studyEmpty_deck_noDueCards_cta => 'Học bài mới';

  @override
  String get studyEmpty_folder_noCards_title => 'Thư mục này chưa có thẻ';

  @override
  String get studyEmpty_folder_noCards_cta => 'Thêm bộ thẻ';

  @override
  String get studyEmpty_folder_noDueCards_title => 'Thư mục này đã ôn xong';

  @override
  String get studyEmpty_folder_noDueCards_cta => 'Học bài mới';

  @override
  String get studyEmpty_today_allDone_title => 'Đã ôn xong hôm nay!';

  @override
  String get studyEmpty_today_allDone_message =>
      'Tuyệt vời. Hẹn gặp lại ngày mai cho lượt ôn tiếp theo.';

  @override
  String get studyEmpty_today_allDone_cta => 'Về trang chính';

  @override
  String get studyEmpty_today_noContent_title => 'Bạn chưa tạo thẻ nào';

  @override
  String get studyEmpty_today_noContent_cta => 'Tạo bộ thẻ đầu tiên';

  @override
  String studyEmptyNextDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày',
      one: '1 ngày',
    );
    return 'sau $_temp0';
  }

  @override
  String studyEmptyNextDueInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giờ',
      one: '1 giờ',
    );
    return 'sau $_temp0';
  }

  @override
  String get studyEmptyNextDueSoon => 'sắp tới';

  @override
  String get studyEmpty_allBuried_title => 'Đã ẩn hết thẻ hôm nay';

  @override
  String get studyEmpty_allBuried_message =>
      'Bạn đã ẩn tất cả thẻ. Chúng sẽ quay lại vào ngày mai.';

  @override
  String get studyEmpty_allBuried_cta => 'Học bài mới';

  @override
  String get studyEmpty_allSuspended_title => 'Tất cả thẻ đã tạm dừng';

  @override
  String get studyEmpty_allSuspended_message =>
      'Khôi phục một vài thẻ để học lại.';

  @override
  String get studyEmpty_allSuspended_cta => 'Xem thẻ';

  @override
  String get flashcardsImportTitle => 'Nhập flashcard';

  @override
  String get flashcardsImportRouteIntroMessage =>
      'V1 nhập deck hiện hỗ trợ xem trước CSV bằng cách dán và commit transaction. Tệp, Excel và text có cấu trúc vẫn để sau.';

  @override
  String get flashcardsImportMissingDeckMessage =>
      'Màn hình nhập này cần deck ID. Hãy quay lại và mở nhập từ một deck.';

  @override
  String get importSourceTitle => 'Nhập từ';

  @override
  String get importCsvContentLabel => 'Nội dung CSV';

  @override
  String get importCsvHint => 'front,back';

  @override
  String get importCsvRulesText =>
      'Dùng cột front và back. Cột phụ tùy chọn sẽ bị bỏ qua ở V1.';

  @override
  String get importPreviewAction => 'Xem trước import';

  @override
  String importCommitCardsAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nhập $count thẻ',
      one: 'Nhập 1 thẻ',
    );
    return '$_temp0';
  }

  @override
  String importSuccessMessage(int count) {
    return 'Đã nhập $count flashcard.';
  }

  @override
  String get importValidationIssuesTitle => 'Lỗi xác thực';

  @override
  String get importValidationIssuesSubtitle =>
      'Hãy sửa toàn bộ lỗi trước khi nhập.';

  @override
  String importValidationIssueLine(int line) {
    return 'Dòng $line';
  }

  @override
  String get importPreviewTitle => 'Xem trước';

  @override
  String importPreviewSubtitle(int count) {
    return '$count flashcard sẵn sàng được tạo';
  }

  @override
  String importPreviewSummary(int valid, int invalid) {
    return '$valid hợp lệ · $invalid lỗi';
  }

  @override
  String get importPreviewRowsTitle => 'Các dòng hợp lệ';

  @override
  String get importPreviewCommitReadyMessage =>
      'Bản xem trước đã sạch. Bạn có thể nhập các thẻ này ngay.';

  @override
  String get importCommittingMessage => 'Đang nhập thẻ...';

  @override
  String get importFailedMessage => 'Nhập thất bại. Hãy thử lại.';

  @override
  String get importCsvEmptyMessage =>
      'Hãy dán nội dung CSV trước khi xem trước.';

  @override
  String get importCsvFrontAndBackRequiredMessage =>
      'Cần có mặt trước và mặt sau.';

  @override
  String get importNothingTitle => 'Không có dữ liệu để nhập';

  @override
  String get importNothingMessage =>
      'Không có dòng hoặc block hợp lệ nào được tạo từ nguồn dữ liệu.';

  @override
  String get sharedErrorTitle => 'Đã xảy ra lỗi';

  @override
  String get sharedStreakLabel => 'Chuỗi';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get libraryFilterTooltip => 'Bộ lọc';

  @override
  String get librarySearchHint => 'Tìm thư mục';

  @override
  String get librarySearchClearTooltip => 'Xóa tìm kiếm';

  @override
  String get librarySearchShortcutLabel => 'K';

  @override
  String get libraryNewFolderLabel => 'Thư mục mới';

  @override
  String get libraryLoadFailedTitle => 'Không tải được thư viện';

  @override
  String get libraryLoadFailedMessage =>
      'Đã xảy ra lỗi khi tải các thư mục của bạn.';

  @override
  String get libraryLoadingFoldersLabel => 'Đang tải thư mục';

  @override
  String get libraryEmptyTitle => 'Bắt đầu thư viện của bạn';

  @override
  String get libraryEmptyMessage =>
      'Thư mục giúp nhóm các bộ thẻ liên quan lại với nhau. Hãy tạo một thư mục để sắp xếp chúng.';

  @override
  String get librarySearchNoResultsTitle => 'Không tìm thấy thư mục';

  @override
  String get librarySearchNoResultsMessage =>
      'Không có thư mục nào khớp với tìm kiếm của bạn.';

  @override
  String get folderCreateDialogTitle => 'Thư mục mới';

  @override
  String get folderCreateDialogDescription =>
      'Nhóm các bộ thẻ liên quan vào cùng một nơi.';

  @override
  String get folderCreateFieldLabel => 'Tên thư mục';

  @override
  String get folderCreateColorLabel => 'Màu';

  @override
  String get folderCreateIconLabel => 'Biểu tượng';

  @override
  String get libraryFolderDuplicateError => 'Đã có một thư mục trùng tên này.';

  @override
  String get libraryCreateFolderError =>
      'Không thể tạo thư mục. Vui lòng thử lại.';

  @override
  String libraryFolderCountLabel(int count) {
    return '$count thư mục';
  }

  @override
  String libraryDueSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ cần ôn hôm nay',
    );
    return '$_temp0';
  }

  @override
  String libraryDueSummarySubtitle(int folderCount, int minutes) {
    return 'Trong $folderCount thư mục · ~$minutes phút';
  }

  @override
  String get librarySortRecentLabel => 'Gần đây';

  @override
  String libraryFolderDecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bộ thẻ',
      zero: 'Chưa có bộ thẻ',
    );
    return '$_temp0';
  }

  @override
  String libraryFolderSubfoldersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thư mục con',
      zero: 'Chưa có thư mục con',
    );
    return '$_temp0';
  }

  @override
  String libraryFolderCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
      zero: 'Chưa có thẻ',
    );
    return '$_temp0';
  }

  @override
  String libraryFolderNewCount(int count) {
    return '$count mới';
  }

  @override
  String libraryFolderDueCount(int count) {
    return '$count cần ôn';
  }

  @override
  String get libraryOverflowTooltip => 'Tùy chọn thư mục';

  @override
  String get folderDetailSearchHint => 'Tìm trong thư mục này';

  @override
  String get folderDetailSearchSheetTitle => 'Tìm trong thư mục này';

  @override
  String get folderDetailMasteryUnavailableLabel => 'Chưa có độ thành thạo';

  @override
  String get folderDetailStartStudyLabel => 'Bắt đầu học';

  @override
  String get folderDetailSortSheetTitle => 'Sắp xếp thư mục';

  @override
  String get folderDetailSortManualLabel => 'Thứ tự thủ công';

  @override
  String get folderDetailSortNameLabel => 'Tên';

  @override
  String get folderDetailSortNewestLabel => 'Mới nhất';

  @override
  String get folderDetailSortLastStudiedLabel => 'Lần học gần nhất';

  @override
  String get folderDetailMostDueLabel => 'Đến hạn nhiều nhất';

  @override
  String get folderDetailEmptyFolderChipLabel => 'Thư mục trống';

  @override
  String get folderDetailEmptyTitle => 'Thư mục này chứa gì?';

  @override
  String get folderDetailEmptyMessage =>
      'Thêm bộ thẻ để học thẻ trực tiếp, hoặc lồng các thư mục con để sắp xếp gọn hơn. Khi đã bắt đầu, thư mục chỉ giữ một trong hai.';

  @override
  String get folderDetailEmptyHint =>
      'Khi thư mục này đã có bộ thẻ hoặc thư mục con, tùy chọn còn lại sẽ chuyển vào menu mở rộng.';

  @override
  String folderDetailNoResultsTitle(String query) {
    return 'Không có mục nào khớp \"$query\"';
  }

  @override
  String get folderDetailNoResultsMessage =>
      'Hãy thử cách viết khác hoặc xóa tìm kiếm để xem tất cả.';

  @override
  String get folderNotFoundTitle => 'Không tìm thấy thư mục';

  @override
  String get folderNotFoundMessage =>
      'Thư mục này có thể đã bị di chuyển hoặc xóa.';

  @override
  String get folderEmptyLockedTitle => 'Thư mục này đang trống';

  @override
  String get folderEmptyLockedMessage => 'Dùng nút bên dưới để thêm nội dung.';

  @override
  String get folderUnlockedTitle => 'Thư mục này đang trống';

  @override
  String get folderUnlockedMessage => 'Chọn cách lấp đầy thư mục:';

  @override
  String get folderModeLockHint =>
      'Một thư mục chỉ chứa thư mục con hoặc bộ thẻ — không cả hai.';

  @override
  String get folderNewSubfolderLabel => 'Thư mục con mới';

  @override
  String get folderNewDeckLabel => 'Bộ thẻ mới';

  @override
  String folderDeleteDialogRemovalMessage(String summaryText) {
    return ' và $summaryText của nó sẽ bị xóa khỏi thư viện.';
  }

  @override
  String get subfolderCreateDialogTitle => 'Thư mục con mới';

  @override
  String get subfolderCreateFieldLabel => 'Tên thư mục con';

  @override
  String get deckCreateDialogTitle => 'Bộ thẻ mới';

  @override
  String get deckCreateFieldLabel => 'Tên bộ thẻ';

  @override
  String get folderRenameDialogDescription =>
      'Chỉ tên thư mục thay đổi — mọi bộ thẻ và thẻ bên trong vẫn giữ nguyên.';

  @override
  String get folderRenameDialogFieldLabel => 'Tên mới';

  @override
  String folderRenameDialogHelper(String summary) {
    return '$summary sẽ tiếp tục xem thư mục này là nhà của chúng.';
  }

  @override
  String get folderDeckDuplicateError => 'Đã có một bộ thẻ trùng tên này.';

  @override
  String get folderChildCreateError => 'Không thể tạo. Vui lòng thử lại.';

  @override
  String get libraryFolderActionsRename => 'Đổi tên';

  @override
  String get libraryFolderActionsMove => 'Di chuyển đến thư mục';

  @override
  String get libraryFolderActionsImport => 'Nhập thẻ';

  @override
  String get libraryFolderActionsDelete => 'Xóa thư mục';

  @override
  String get libraryFolderActionError =>
      'Không thể hoàn tất thao tác. Vui lòng thử lại.';

  @override
  String get folderMovePickerSearchHint => 'Tìm thư mục';

  @override
  String get folderMovePickerCycleReason =>
      'Không thể di chuyển thư mục vào chính nó hoặc thư mục con của nó.';

  @override
  String get folderMovePickerLockedReason =>
      'Đã khóa ở chế độ bộ thẻ — không thể chứa thư mục.';

  @override
  String get folderSummaryAllCaughtUp => 'Đã ôn hết';

  @override
  String get folderSummarySubfoldersStat => 'thư mục con';

  @override
  String get folderSummaryCardsStat => 'thẻ';

  @override
  String get folderSummaryDueStat => 'đến hạn';

  @override
  String get searchFieldHint => 'Tìm thư mục, bộ thẻ, thẻ';

  @override
  String get searchClearTooltip => 'Xóa tìm kiếm';

  @override
  String get searchEmptyTitle => 'Tìm trong thư viện';

  @override
  String get searchEmptyMessage =>
      'Nhập ít nhất 2 ký tự để tìm thư mục, bộ thẻ và thẻ.';

  @override
  String get searchNoResultsTitle => 'Không có kết quả';

  @override
  String get searchNoResultsMessage =>
      'Không có mục nào trong thư viện khớp với tìm kiếm đó.';

  @override
  String get searchErrorTitle => 'Tìm kiếm thất bại';

  @override
  String get searchErrorMessage =>
      'Đã xảy ra lỗi khi tìm kiếm. Vui lòng thử lại.';

  @override
  String get searchRetryLabel => 'Thử lại';

  @override
  String get searchSectionFolders => 'Thư mục';

  @override
  String get searchSectionDecks => 'Bộ thẻ';

  @override
  String get searchSectionFlashcards => 'Thẻ';

  @override
  String get searchResultFolderSubtitle => 'Thư mục';

  @override
  String get searchResultDeckSubtitle => 'Bộ thẻ';

  @override
  String searchMoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count mục nữa',
      one: '+1 mục nữa',
    );
    return '$_temp0';
  }

  @override
  String get commonDone => 'Xong';

  @override
  String get flashcardListAddCardAction => 'Thêm thẻ';

  @override
  String get flashcardListErrorTitle => 'Không mở được bộ thẻ';

  @override
  String get flashcardListErrorMessage =>
      'Không thể mở bộ thẻ này. Vui lòng thử lại.';

  @override
  String get flashcardListActionError => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String flashcardListSubtitle(int count, String language) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ · $language',
    );
    return '$_temp0';
  }

  @override
  String get flashcardListLanguageKorean => 'Tiếng Hàn';

  @override
  String get flashcardListLanguageEnglish => 'Tiếng Anh';

  @override
  String get flashcardListLanguageOther => 'Ngôn ngữ khác';

  @override
  String get flashcardDeckReorderAction => 'Sắp xếp lại thẻ';

  @override
  String get flashcardDeleteOneTitle => 'Xóa thẻ này?';

  @override
  String get flashcardDeleteOneMessage =>
      'Lịch sử ôn tập của thẻ này sẽ bị xóa. Các thẻ khác trong bộ thẻ không bị ảnh hưởng.';

  @override
  String get flashcardDeletedOneMessage => 'Đã xóa thẻ.';

  @override
  String get flashcardReorderError => 'Không thể lưu thứ tự mới.';

  @override
  String get progressRangeWeek => 'Tuần';

  @override
  String get progressRangeMonth => 'Tháng';

  @override
  String get progressRangeAllTime => 'Tất cả';

  @override
  String get progressCardsStudiedTitle => 'Thẻ đã học';

  @override
  String get progressCardsStudiedCaptionWeek => 'trong 7 ngày qua';

  @override
  String get progressCardsStudiedCaptionMonth => 'trong 28 ngày qua';

  @override
  String get progressCardsStudiedCaptionAllTime => 'toàn bộ thời gian';

  @override
  String get progressAccuracyTitle => 'Độ chính xác';

  @override
  String get progressVsPreviousWeek => 'so với tuần trước';

  @override
  String get progressVsPreviousMonth => 'so với tháng trước';

  @override
  String get progressBoxDistributionTitle => 'Phân bố hộp';

  @override
  String get progressBoxTotalCaption => 'tổng số thẻ trong các hộp';

  @override
  String progressBoxLabel(int box) {
    return 'B$box';
  }

  @override
  String get progressBoxLegendLeast => 'B1 · ít thuộc nhất';

  @override
  String get progressBoxLegendBest => 'B8 · thuộc nhất';

  @override
  String get progressStreakTitle => 'Chuỗi ngày học';

  @override
  String get progressStreakCurrent => 'Hiện tại';

  @override
  String get progressStreakLongest => 'Dài nhất';

  @override
  String progressStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày',
      one: '1 ngày',
    );
    return '$_temp0';
  }

  @override
  String get progressCardStatesTitle => 'Trạng thái thẻ';

  @override
  String get progressSuspendedTitle => 'Tạm dừng';

  @override
  String get progressSuspendedSubtitle =>
      'Ngừng ôn tập cho đến khi bạn kích hoạt lại';

  @override
  String get progressSuspendedCaption => 'trong thư viện';

  @override
  String get progressBuriedTitle => 'Ẩn hôm nay';

  @override
  String get progressBuriedSubtitle => 'Bỏ qua đến ngày mai';

  @override
  String get progressBuriedCaption => 'chỉ hôm nay';

  @override
  String get progressFooterWeek => 'Tóm tắt chỉ đọc · 7 ngày qua';

  @override
  String get progressFooterMonth => 'Tóm tắt chỉ đọc · 28 ngày qua';

  @override
  String get progressFooterAllTime => 'Tóm tắt chỉ đọc · toàn bộ thời gian';

  @override
  String get progressChartEmptyHint =>
      'Chưa có phiên học nào trong khoảng này. Học bất kỳ bộ thẻ nào để bắt đầu theo dõi xu hướng.';

  @override
  String progressChartInsufficientHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mới có dữ liệu của $count ngày.',
      one: 'Mới có dữ liệu của 1 ngày.',
    );
    return '$_temp0';
  }

  @override
  String progressTrendBanner(int days) {
    return 'Xu hướng hiển thị sau $days ngày có dữ liệu.';
  }

  @override
  String get progressAccuracyEmptyHint =>
      'Độ chính xác hiển thị khi bạn đã trả lời thẻ.';

  @override
  String get progressBoxEmptyHint => 'Thẻ sẽ phân bố vào các hộp khi bạn học.';

  @override
  String get progressStreakEmptyHint =>
      'Chuỗi ngày học bắt đầu sau một phiên học.';

  @override
  String get progressErrorTitle => 'Không thể tổng hợp tiến độ của bạn';

  @override
  String get progressErrorMessage =>
      'Lịch sử học vẫn an toàn trên thiết bị này. Hãy thử lại sau giây lát.';

  @override
  String flashcardListCountHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count THẺ',
      one: '1 THẺ',
    );
    return '$_temp0';
  }

  @override
  String flashcardListReorderHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count THẺ · KÉO ĐỂ SẮP XẾP',
      one: '1 THẺ · KÉO ĐỂ SẮP XẾP',
    );
    return '$_temp0';
  }

  @override
  String get flashcardsEmptyAddFirstAction => 'Thêm thẻ đầu tiên';

  @override
  String get flashcardsEmptyImportAction => 'Nhập thẻ (CSV, TSV, Anki)';

  @override
  String get flashcardEditorSavingLabel => 'Đang lưu…';

  @override
  String get flashcardEditorSavingHelperText => 'Đang lưu vào thiết bị này…';

  @override
  String get flashcardEditorRetrySaveLabel => 'Lưu lại';

  @override
  String get flashcardEditorOptionalDetailsHeading => 'Chi tiết tùy chọn';

  @override
  String flashcardsEditMeta(int reviewCount, String relativeTime) {
    String _temp0 = intl.Intl.pluralLogic(
      reviewCount,
      locale: localeName,
      other: 'Chỉnh sửa lần cuối $relativeTime · $reviewCount lượt ôn',
      one: 'Chỉnh sửa lần cuối $relativeTime · 1 lượt ôn',
      zero: 'Chỉnh sửa lần cuối $relativeTime',
    );
    return '$_temp0';
  }

  @override
  String get cardHistoryTitle => 'Lịch sử thẻ';

  @override
  String get cardHistoryStateSuspended => 'Đã tạm dừng';

  @override
  String relativeTimeUntil(String unit, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sau $count phút',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sau $count giờ',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sau $count ngày',
    );
    String _temp3 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sau $count tuần',
    );
    String _temp4 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sau $count tháng',
    );
    String _temp5 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sau $count năm',
    );
    String _temp6 = intl.Intl.selectLogic(unit, {
      'justNow': 'bây giờ',
      'minutes': '$_temp0',
      'hours': '$_temp1',
      'days': '$_temp2',
      'weeks': '$_temp3',
      'months': '$_temp4',
      'years': '$_temp5',
      'other': 'bây giờ',
    });
    return '$_temp6';
  }

  @override
  String cardHistoryResetSubLabel(String date) {
    return 'Bao gồm các lượt ôn trước lần đặt lại gần nhất vào $date.';
  }

  @override
  String get cardHistoryResultPerfect => 'Hoàn hảo';

  @override
  String get cardHistoryResultPassed => 'Đạt';

  @override
  String get cardHistoryResultRecovered => 'Gỡ lại';

  @override
  String get cardHistoryResultForgot => 'Quên';

  @override
  String get cardHistoryBoxUnknown => '—';

  @override
  String cardHistoryModeLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'review': 'Ôn tập',
      'match': 'Ghép',
      'guess': 'Đoán',
      'recall': 'Nhớ lại',
      'fill': 'Điền',
      'other': 'Học',
    });
    return 'Chế độ: $_temp0';
  }

  @override
  String get cardHistoryEmptyTitle => 'Chưa có lượt ôn nào';

  @override
  String get cardHistoryEmptyMessage =>
      'Lịch sử sẽ xuất hiện ở đây sau khi bạn học thẻ này.';

  @override
  String get cardHistoryEmptyAction => 'Học thẻ này ngay';

  @override
  String get cardHistoryErrorTitle => 'Không tải được lịch sử';

  @override
  String get cardHistoryErrorMessage =>
      'Dữ liệu của bạn vẫn an toàn trên thiết bị này. Vui lòng thử lại sau giây lát.';

  @override
  String get cardHistoryNotFoundTitle => 'Thẻ không còn tồn tại';

  @override
  String get cardHistoryNotFoundMessage => 'Thẻ này đã bị xóa.';

  @override
  String get cardHistoryResetAction => 'Đặt lại tiến độ';

  @override
  String get cardHistoryResetConfirmTitle => 'Đặt lại tiến độ?';

  @override
  String get cardHistoryResetConfirmMessage =>
      'Lịch sử lượt ôn được giữ lại; chỉ trạng thái SRS bị đặt lại.';

  @override
  String get cardHistoryResetDoneMessage => 'Đã đặt lại tiến độ';

  @override
  String get cardHistoryActionError => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get cardHistoryViewAction => 'Xem lịch sử';

  @override
  String get cardHistoryBreadcrumbCurrent => 'Lịch sử';

  @override
  String cardHistoryBoxChip(int box, int total) {
    return 'Hộp $box / $total';
  }

  @override
  String get cardHistoryProgressTitle => 'Tiến độ hiện tại';

  @override
  String cardHistoryBoxStepLabel(int box) {
    return 'Hộp $box';
  }

  @override
  String get cardHistoryStatDue => 'Đến hạn';

  @override
  String get cardHistoryStatReviews => 'Lượt ôn';

  @override
  String get cardHistoryStatRecall => 'Tỷ lệ nhớ';

  @override
  String get cardHistoryStatLapses => 'Lần quên';

  @override
  String get cardHistoryStatStreak => 'Chuỗi đúng';

  @override
  String get cardHistoryStatSinceAdded => 'Đã thêm';

  @override
  String cardHistoryPercentValue(int percent) {
    return '$percent%';
  }

  @override
  String cardHistoryStreakValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lần liên tiếp',
    );
    return '$_temp0';
  }

  @override
  String cardHistorySinceAddedValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày',
      zero: 'hôm nay',
    );
    return '$_temp0';
  }

  @override
  String cardHistoryTimelineHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dòng thời gian · $count sự kiện',
    );
    return '$_temp0';
  }

  @override
  String get cardHistoryChipCorrect => 'Đúng';

  @override
  String get cardHistoryChipRecovered => 'Gỡ lại';

  @override
  String get cardHistoryChipForgot => 'Quên';

  @override
  String get cardHistoryDescCorrect => 'Trả lời đúng';

  @override
  String get cardHistoryDescRecovered => 'Nhớ lại sau khi nhầm';

  @override
  String get cardHistoryDescForgot => 'Không nhớ ra — đặt lại về hộp 1';

  @override
  String get cardHistoryPartialDescription => 'Ghi nhận nhưng thiếu chi tiết';

  @override
  String cardHistoryDurationValue(String seconds) {
    return '${seconds}s';
  }

  @override
  String get cardHistoryDurationMissing => 'không ghi thời lượng';

  @override
  String get cardHistoryEventCreatedChip => 'Đã tạo';

  @override
  String get cardHistoryEventEditedChip => 'Đã sửa';

  @override
  String get cardHistoryEventAudioChip => 'Thêm âm thanh';

  @override
  String cardHistoryEventCreatedDescription(String deck) {
    return 'Đã thêm thẻ vào $deck';
  }

  @override
  String get cardHistoryEventEditedDescription => 'Đã sửa thẻ';

  @override
  String get cardHistoryEventAudioDescription => 'Đã ghi phát âm';

  @override
  String get cardHistoryEventResetChip => 'Đặt lại';

  @override
  String get cardHistoryEventResetDescription => 'Đã đặt lại tiến độ về hộp 1';

  @override
  String get cardHistoryBeginning => 'Bắt đầu lịch sử';

  @override
  String get cardHistoryFilterSheetTitle => 'Lọc dòng thời gian';

  @override
  String get cardHistoryFilterAll => 'Tất cả sự kiện';

  @override
  String get cardHistoryFilterReviews => 'Chỉ lượt ôn';

  @override
  String get cardHistoryFilterLifecycle => 'Thay đổi thẻ';
}
