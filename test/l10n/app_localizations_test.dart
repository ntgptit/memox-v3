import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('supports English and Vietnamese', () {
      final List<String> codes = AppLocalizations.supportedLocales
          .map((Locale l) => l.languageCode)
          .toList();

      expect(codes, containsAll(<String>['en', 'vi']));
    });

    test('English resolves the source copy', () async {
      final AppLocalizations l10n = await AppLocalizations.delegate.load(
        const Locale('en'),
      );

      expect(l10n.appTitle, 'MemoX');
      expect(l10n.appDescription, 'Local-first flashcard app');
    });

    test('Vietnamese resolves translated copy', () async {
      final AppLocalizations l10n = await AppLocalizations.delegate.load(
        const Locale('vi'),
      );

      expect(l10n.appTitle, 'MemoX');
      expect(l10n.appDescription, 'Ứng dụng thẻ ghi nhớ ưu tiên ngoại tuyến');
    });
  });
}
