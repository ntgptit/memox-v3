/// Barrel for the MemoX shared widget kit (`Mx*`).
///
/// Built from the "0 · Foundations · Shared widgets" handoff in
/// `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`. Import
/// this single file from feature code instead of reaching into the tree.
library;

// Feedback & overlays.
export 'feedback/mx_callout.dart';
export 'feedback/mx_offline_banner.dart';
// Layouts & shells.
export 'layouts/mx_adaptive_scaffold.dart';
export 'layouts/mx_content_shell.dart';
export 'layouts/mx_form_scaffold.dart';
export 'layouts/mx_list_scaffold.dart';
export 'layouts/mx_scaffold.dart';
export 'layouts/mx_study_scaffold.dart';
// Buttons & actions.
export 'widgets/buttons/mx_action_button.dart';
export 'widgets/buttons/mx_action_intent.dart';
export 'widgets/buttons/mx_button_size.dart';
export 'widgets/buttons/mx_card_actions.dart';
export 'widgets/buttons/mx_icon_button.dart';
export 'widgets/buttons/mx_primary_button.dart';
export 'widgets/buttons/mx_secondary_button.dart';
// Interaction primitive.
export 'widgets/mx_tappable.dart';
// Navigation chrome.
export 'widgets/navigation/mx_breadcrumb.dart';
export 'widgets/navigation/mx_study_top_bar.dart';
// State placeholders.
export 'widgets/states/mx_empty_state.dart';
export 'widgets/states/mx_error_state.dart';
export 'widgets/states/mx_loading_state.dart';
export 'widgets/states/mx_skeleton.dart';
// Status & data viz.
export 'widgets/status/mx_bar_chart.dart';
export 'widgets/status/mx_card_status.dart';
export 'widgets/status/mx_linear_progress.dart';
export 'widgets/status/mx_mastery_ring.dart';
export 'widgets/status/mx_stat_display.dart';
export 'widgets/status/mx_status_badge.dart';
export 'widgets/status/mx_streak_chip.dart';
// Study-mode widgets.
export 'widgets/study/mx_choice_option.dart';
export 'widgets/study/mx_flashcard.dart';
export 'widgets/study/mx_match_tile.dart';
export 'widgets/study/mx_rating_bar.dart';
export 'widgets/study/mx_self_assessment.dart';
// Surfaces, cards & list items.
export 'widgets/surfaces/mx_avatar.dart';
export 'widgets/surfaces/mx_card.dart';
export 'widgets/surfaces/mx_icon_tile.dart';
export 'widgets/surfaces/mx_list_tile.dart';
export 'widgets/surfaces/mx_section_header.dart';
export 'widgets/surfaces/mx_settings_tile.dart';
