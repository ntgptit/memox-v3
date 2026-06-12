import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('MxFailureMessage.failureMessage', () {
    test('duplicate uses the entity-specific override', () {
      expect(
        l10n.failureMessage(
          const Failure.validation(
            field: 'name',
            code: ValidationCode.duplicate,
          ),
          duplicate: l10n.folderDeckDuplicateError,
          fallback: l10n.folderChildCreateError,
        ),
        l10n.folderDeckDuplicateError,
      );
    });

    test('storage prefers the action-specific fallback when provided', () {
      expect(
        l10n.failureMessage(
          const Failure.storage(operation: StorageOp.write, cause: 'x'),
          fallback: l10n.libraryCreateFolderError,
        ),
        l10n.libraryCreateFolderError,
      );
    });

    test('storage uses the generic storage copy without a fallback', () {
      expect(
        l10n.failureMessage(
          const Failure.storage(operation: StorageOp.read, cause: 'x'),
        ),
        l10n.errorUnexpected,
      );
    });

    test('unsupported action maps to the folder mode-locked copy', () {
      expect(
        l10n.failureMessage(const Failure.unsupportedAction()),
        l10n.folderModeLockHint,
      );
    });

    test('cycle validation maps to the move-cycle copy', () {
      expect(
        l10n.failureMessage(
          const Failure.validation(
            field: 'parent',
            code: ValidationCode.cycleDetected,
          ),
        ),
        l10n.folderMovePickerCycleReason,
      );
    });

    test('network timeout maps to the timeout copy', () {
      expect(
        l10n.failureMessage(
          const Failure.network(kind: NetworkErrorKind.timeout),
        ),
        l10n.errorUnexpected,
      );
    });

    test('not-found without a fallback uses the generic not-found copy', () {
      expect(
        l10n.failureMessage(const Failure.notFound(entity: 'folder')),
        l10n.errorUnexpected,
      );
    });
  });
}
