import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/presentation/shared/hooks/mx_hooks.dart';

final class FlashcardEditorDraft {
  const FlashcardEditorDraft({
    required this.formKey,
    required this.frontController,
    required this.backController,
    required this.exampleController,
    required this.pronunciationController,
    required this.hintController,
    required this.frontFocusNode,
    required this.backFocusNode,
    required this.exampleFocusNode,
    required this.pronunciationFocusNode,
    required this.hintFocusNode,
    required this.frontText,
    required this.backText,
    required this.exampleText,
    required this.pronunciationText,
    required this.hintText,
    required this.tags,
    required this.initialFront,
    required this.initialBack,
    required this.initialExample,
    required this.initialPronunciation,
    required this.initialHint,
    required this.initialTags,
    required this.detailsOpen,
    required this.saveAndAddAnother,
    required this.didPrefillCard,
    required this.saveFailure,
    required this.loadedDetail,
    required this.markDraftChanged,
    required this.setSaveFailure,
    required this.hydrateFromDetail,
    required this.resetForAnotherCard,
    required this.resetForRetry,
    required this.toggleDetails,
    required this.toggleSaveAndAddAnother,
    required this.addTag,
    required this.removeTag,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController frontController;
  final TextEditingController backController;
  final TextEditingController exampleController;
  final TextEditingController pronunciationController;
  final TextEditingController hintController;
  final FocusNode frontFocusNode;
  final FocusNode backFocusNode;
  final FocusNode exampleFocusNode;
  final FocusNode pronunciationFocusNode;
  final FocusNode hintFocusNode;
  final String frontText;
  final String backText;
  final String exampleText;
  final String pronunciationText;
  final String hintText;
  final List<String> tags;
  final String initialFront;
  final String initialBack;
  final String initialExample;
  final String initialPronunciation;
  final String initialHint;
  final List<String> initialTags;
  final bool detailsOpen;
  final bool saveAndAddAnother;
  final bool didPrefillCard;
  final Failure? saveFailure;
  final FlashcardDetail? loadedDetail;
  final VoidCallback markDraftChanged;
  final void Function(Failure? failure) setSaveFailure;
  final void Function(FlashcardDetail detail) hydrateFromDetail;
  final VoidCallback resetForAnotherCard;
  final VoidCallback resetForRetry;
  final VoidCallback toggleDetails;
  final ValueChanged<bool> toggleSaveAndAddAnother;
  final void Function(String tag) addTag;
  final void Function(String tag) removeTag;

  bool get canSave =>
      StringUtils.trimmed(frontText).isNotEmpty &&
      StringUtils.trimmed(backText).isNotEmpty;

  bool get frontBackChanged =>
      StringUtils.trimmed(frontText) != initialFront ||
      StringUtils.trimmed(backText) != initialBack;

  bool get hasUnsavedChanges =>
      frontBackChanged ||
      StringUtils.trimmed(exampleText) != initialExample ||
      StringUtils.trimmed(pronunciationText) != initialPronunciation ||
      StringUtils.trimmed(hintText) != initialHint ||
      !sameTags(tags, initialTags);

  bool get shouldPromptProgressPolicy =>
      loadedDetail?.progress?.isFresh == false && frontBackChanged;

  bool sameTags(List<String> current, List<String> original) {
    if (current.length != original.length) {
      return false;
    }
    for (int index = 0; index < current.length; index++) {
      if (!StringUtils.equalsIgnoreCase(current[index], original[index])) {
        return false;
      }
    }
    return true;
  }
}

FlashcardEditorDraft useFlashcardEditorDraft() {
  final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);
  final TextEditingController frontController = useTextEditingController();
  final TextEditingController backController = useTextEditingController();
  final TextEditingController exampleController = useTextEditingController();
  final TextEditingController pronunciationController =
      useTextEditingController();
  final TextEditingController hintController = useTextEditingController();

  final FocusNode frontFocusNode = useFocusNode();
  final FocusNode backFocusNode = useFocusNode();
  final FocusNode exampleFocusNode = useFocusNode();
  final FocusNode pronunciationFocusNode = useFocusNode();
  final FocusNode hintFocusNode = useFocusNode();

  final String frontText = useMxTextValue(frontController);
  final String backText = useMxTextValue(backController);
  final String exampleText = useMxTextValue(exampleController);
  final String pronunciationText = useMxTextValue(pronunciationController);
  final String hintText = useMxTextValue(hintController);

  final ValueNotifier<List<String>> tags = useState<List<String>>(<String>[]);
  final ValueNotifier<String> initialFront = useState<String>('');
  final ValueNotifier<String> initialBack = useState<String>('');
  final ValueNotifier<String> initialExample = useState<String>('');
  final ValueNotifier<String> initialPronunciation = useState<String>('');
  final ValueNotifier<String> initialHint = useState<String>('');
  final ValueNotifier<List<String>> initialTags = useState<List<String>>(
    <String>[],
  );
  final ValueNotifier<bool> detailsOpen = useState<bool>(false);
  final ValueNotifier<bool> saveAndAddAnother = useState<bool>(false);
  final ValueNotifier<bool> didPrefillCard = useState<bool>(false);
  final ValueNotifier<Failure?> saveFailure = useState<Failure?>(null);
  final ValueNotifier<FlashcardDetail?> loadedDetail =
      useState<FlashcardDetail?>(null);

  void markDraftChanged() {
    saveFailure.value = null;
  }

  void updateSaveFailure(Failure? failure) {
    saveFailure.value = failure;
  }

  void hydrateFromDetail(FlashcardDetail detail) {
    frontController.text = detail.flashcard.front;
    backController.text = detail.flashcard.back;
    exampleController.text = detail.flashcard.exampleSentence ?? '';
    pronunciationController.text = detail.flashcard.pronunciation ?? '';
    hintController.text = detail.flashcard.hint ?? '';
    tags.value = List<String>.from(detail.tags);
    detailsOpen.value =
        detail.flashcard.exampleSentence != null ||
        detail.flashcard.pronunciation != null ||
        detail.flashcard.hint != null ||
        detail.tags.isNotEmpty;
    initialFront.value = StringUtils.trimmed(detail.flashcard.front);
    initialBack.value = StringUtils.trimmed(detail.flashcard.back);
    initialExample.value = StringUtils.trimmed(
      detail.flashcard.exampleSentence ?? '',
    );
    initialPronunciation.value = StringUtils.trimmed(
      detail.flashcard.pronunciation ?? '',
    );
    initialHint.value = StringUtils.trimmed(detail.flashcard.hint ?? '');
    initialTags.value = List<String>.from(detail.tags);
    saveFailure.value = null;
    loadedDetail.value = detail;
    didPrefillCard.value = true;
  }

  void resetForAnotherCard() {
    frontController.clear();
    backController.clear();
    exampleController.clear();
    pronunciationController.clear();
    hintController.clear();
    tags.value = <String>[];
    detailsOpen.value = false;
    initialFront.value = '';
    initialBack.value = '';
    initialExample.value = '';
    initialPronunciation.value = '';
    initialHint.value = '';
    initialTags.value = <String>[];
    saveFailure.value = null;
    loadedDetail.value = null;
    didPrefillCard.value = false;
  }

  void resetForRetry() {
    saveFailure.value = null;
    loadedDetail.value = null;
    didPrefillCard.value = false;
  }

  void toggleDetails() {
    detailsOpen.value = !detailsOpen.value;
  }

  void toggleSaveAndAddAnother(bool value) {
    saveAndAddAnother.value = value;
  }

  void addTag(String tag) {
    tags.value = <String>[...tags.value, tag];
  }

  void removeTag(String tag) {
    tags.value = <String>[
      for (final String current in tags.value)
        if (!StringUtils.equalsIgnoreCase(current, tag)) current,
    ];
  }

  return FlashcardEditorDraft(
    formKey: formKey,
    frontController: frontController,
    backController: backController,
    exampleController: exampleController,
    pronunciationController: pronunciationController,
    hintController: hintController,
    frontFocusNode: frontFocusNode,
    backFocusNode: backFocusNode,
    exampleFocusNode: exampleFocusNode,
    pronunciationFocusNode: pronunciationFocusNode,
    hintFocusNode: hintFocusNode,
    frontText: frontText,
    backText: backText,
    exampleText: exampleText,
    pronunciationText: pronunciationText,
    hintText: hintText,
    tags: tags.value,
    initialFront: initialFront.value,
    initialBack: initialBack.value,
    initialExample: initialExample.value,
    initialPronunciation: initialPronunciation.value,
    initialHint: initialHint.value,
    initialTags: initialTags.value,
    detailsOpen: detailsOpen.value,
    saveAndAddAnother: saveAndAddAnother.value,
    didPrefillCard: didPrefillCard.value,
    saveFailure: saveFailure.value,
    loadedDetail: loadedDetail.value,
    markDraftChanged: markDraftChanged,
    setSaveFailure: updateSaveFailure,
    hydrateFromDetail: hydrateFromDetail,
    resetForAnotherCard: resetForAnotherCard,
    resetForRetry: resetForRetry,
    toggleDetails: toggleDetails,
    toggleSaveAndAddAnother: toggleSaveAndAddAnother,
    addTag: addTag,
    removeTag: removeTag,
  );
}
