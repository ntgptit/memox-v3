import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/data/datasources/local/app_database.dart' as db;
import 'package:memox/data/datasources/local/daos/tts_settings_dao.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/types/tts_language_code.dart';

class TtsSettingsRepositoryImpl implements TtsSettingsRepository {
  TtsSettingsRepositoryImpl(this._dao);

  final TtsSettingsDao _dao;

  @override
  Future<Result<TtsSettings>> load() async {
    try {
      final db.TtsSettingsRow? row = await _dao.loadSettings();
      return Result<TtsSettings>.ok(
        row != null ? _fromRow(row) : TtsSettings.defaults,
      );
    } catch (e) {
      return Result<TtsSettings>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: e.toString(),
          table: 'tts_settings',
        ),
      );
    }
  }

  @override
  Future<Result<void>> save(TtsSettings settings) async {
    try {
      await _dao.saveSettings(_toCompanion(settings));
      return const Result<void>.ok(null);
    } catch (e) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: e.toString(),
          table: 'tts_settings',
        ),
      );
    }
  }

  static TtsSettings _fromRow(db.TtsSettingsRow row) {
    final String? trimmedVoice = row.frontVoiceName != null
        ? StringUtils.trimmed(row.frontVoiceName!)
        : null;
    return TtsSettings(
      autoPlay: row.autoPlay != 0,
      frontLanguage: _decodeLanguage(row.frontLanguage),
      rate: TtsSettings.normalizeRate(row.rate),
      pitch: TtsSettings.normalizePitch(row.pitch),
      volume: TtsSettings.normalizeVolume(row.volume),
      frontVoiceName: (trimmedVoice == null || trimmedVoice.isEmpty)
          ? null
          : trimmedVoice,
    );
  }

  static db.TtsSettingsCompanion _toCompanion(TtsSettings s) =>
      db.TtsSettingsCompanion(
        id: const Value<String>('default'),
        autoPlay: Value<int>(s.autoPlay ? 1 : 0),
        frontLanguage: Value<String>(_encodeLanguage(s.frontLanguage)),
        rate: Value<double>(s.rate),
        pitch: Value<double>(s.pitch),
        volume: Value<double>(s.volume),
        frontVoiceName: Value<String?>(s.frontVoiceName),
      );

  static TtsLanguageCode _decodeLanguage(String value) => switch (value) {
    'english' => TtsLanguageCode.enUS,
    _ => TtsLanguageCode.koKR,
  };

  static String _encodeLanguage(TtsLanguageCode lang) => switch (lang) {
    TtsLanguageCode.enUS => 'english',
    TtsLanguageCode.koKR => 'korean',
  };
}
