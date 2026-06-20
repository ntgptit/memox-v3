// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MemoX';

  @override
  String get appDescription => 'Local-first flashcard app';

  @override
  String get homeTitle => 'Home';

  @override
  String get libraryTitle => 'Library';

  @override
  String get progressTitle => 'Progress';

  @override
  String get settingsTitle => 'Settings';
}
