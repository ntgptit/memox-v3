import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
// Hide Drift's generated `TtsSettings` table class — the domain model of the
// same name is the one this repository maps to.
import 'package:memox/data/datasources/local/app_database.dart'
    hide TtsSettings;
import 'package:memox/data/datasources/local/daos/tts_settings_dao.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/types/tts_front_language.dart';

/// Drift-backed [TtsSettingsRepository] over the single-row `tts_settings` table.
///
/// Persistence only: applies defaults when the row is missing and clamps
/// (self-heals) out-of-range slider values on both load and save via
/// `TtsSettings.normalized()`.
class TtsSettingsRepositoryImpl implements TtsSettingsRepository {
  TtsSettingsRepositoryImpl({required TtsSettingsDao dao}) : _dao = dao;

  final TtsSettingsDao _dao;

  @override
  Future<Result<TtsSettings>> load() async {
    try {
      final TtsSettingsRow? row = await _dao.read();
      if (row == null) {
        return (failure: null, data: const TtsSettings());
      }
      return (failure: null, data: _toModel(row).normalized());
    } catch (error) {
      return (failure: _storage(StorageOp.read, error), data: null);
    }
  }

  @override
  Future<Result<void>> save(TtsSettings settings) async {
    try {
      await _dao.upsert(_toCompanion(settings.normalized()));
      return (failure: null, data: null);
    } catch (error) {
      return (failure: _storage(StorageOp.write, error), data: null);
    }
  }

  TtsSettings _toModel(TtsSettingsRow row) => TtsSettings(
    autoPlay: row.autoPlay,
    frontLanguage: TtsFrontLanguage.fromStorage(row.frontLanguage),
    rate: row.rate,
    pitch: row.pitch,
    volume: row.volume,
    frontVoiceName: row.frontVoiceName,
  );

  TtsSettingsCompanion _toCompanion(TtsSettings settings) =>
      TtsSettingsCompanion.insert(
        id: TtsSettingsDao.defaultRowId,
        autoPlay: Value<bool>(settings.autoPlay),
        frontLanguage: Value<String>(settings.frontLanguage.storageValue),
        rate: Value<double>(settings.rate),
        pitch: Value<double>(settings.pitch),
        volume: Value<double>(settings.volume),
        frontVoiceName: Value<String?>(settings.frontVoiceName),
      );

  Failure _storage(StorageOp op, Object error) => Failure.storage(
    operation: op,
    table: 'tts_settings',
    cause: error.toString(),
  );
}
