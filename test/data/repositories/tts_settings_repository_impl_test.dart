import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart'
    hide TtsSettings;
import 'package:memox/data/datasources/local/daos/tts_settings_dao.dart';
import 'package:memox/data/repositories/tts_settings_repository_impl.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/types/tts_front_language.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());

  TtsSettingsRepositoryImpl repo() =>
      TtsSettingsRepositoryImpl(dao: TtsSettingsDao(db));

  test('load returns defaults when the row is missing', () async {
    final Result<TtsSettings> result = await repo().load();
    expect(result.failure, isNull);
    expect(result.data, const TtsSettings());
  });

  test('save then load round-trips every field', () async {
    final TtsSettingsRepositoryImpl repository = repo();
    await repository.save(
      const TtsSettings(
        autoPlay: true,
        frontLanguage: TtsFrontLanguage.english,
        rate: 0.6,
        pitch: 1.2,
        volume: 0.8,
        frontVoiceName: 'en-voice',
      ),
    );
    final TtsSettings loaded = (await repository.load()).data!;
    expect(loaded.autoPlay, isTrue);
    expect(loaded.frontLanguage, TtsFrontLanguage.english);
    expect(loaded.rate, 0.6);
    expect(loaded.pitch, 1.2);
    expect(loaded.volume, 0.8);
    expect(loaded.frontVoiceName, 'en-voice');
  });

  test('save clamps out-of-range sliders (CHECK never trips)', () async {
    final TtsSettingsRepositoryImpl repository = repo();
    final Result<void> saved = await repository.save(
      const TtsSettings(rate: 9, pitch: 9, volume: 9),
    );
    expect(saved.failure, isNull);
    final TtsSettings loaded = (await repository.load()).data!;
    expect(loaded.rate, TtsSettings.maxRate);
    expect(loaded.pitch, TtsSettings.maxPitch);
    expect(loaded.volume, TtsSettings.maxVolume);
  });
}
