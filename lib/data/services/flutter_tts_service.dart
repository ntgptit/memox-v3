import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/services/tts_service.dart';

class FlutterTtsService implements TtsService {
  FlutterTtsService() {
    _tts.setStartHandler(() => _emitState(TtsState.speaking));
    _tts.setCompletionHandler(() => _emitState(TtsState.idle));
    _tts.setCancelHandler(() => _emitState(TtsState.idle));
    _tts.setErrorHandler((_) => _emitState(TtsState.error));
  }

  final FlutterTts _tts = FlutterTts();
  final StreamController<TtsState> _stateController =
      StreamController<TtsState>.broadcast();
  TtsState _currentState = TtsState.idle;

  void _emitState(TtsState s) {
    _currentState = s;
    if (!_stateController.isClosed) {
      _stateController.add(s);
    }
  }

  @override
  Stream<TtsState> get stateStream => _stateController.stream;

  @override
  TtsState get currentState => _currentState;

  @override
  Future<void> speak(
    String text, {
    required String languageCode,
    String? voiceName,
    required double rate,
    required double pitch,
    required double volume,
  }) async {
    await _tts.stop();
    await _tts.setLanguage(languageCode);
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
    await _tts.setVolume(volume);
    if (voiceName != null && voiceName.isNotEmpty) {
      await _tts.setVoice(<String, String>{
        'name': voiceName,
        'locale': languageCode,
      });
    }
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _emitState(TtsState.idle);
  }

  @override
  Future<List<TtsVoice>> availableVoices(String languageCode) async {
    try {
      final Object? rawVoices = await _tts.getVoices;
      if (rawVoices is! List) return <TtsVoice>[];
      final List<Object?> voices = rawVoices.cast<Object?>();
      // 'ko' from 'ko-KR' — match any voice whose locale starts with the
      // language subtag so both 'ko-KR' and 'ko-KP' variants are included.
      final String langPrefix = languageCode.split('-').first;
      return voices
          .whereType<Map<Object?, Object?>>()
          .where((Map<Object?, Object?> v) {
            final String locale = (v['locale'] as String?) ?? '';
            return locale.startsWith(langPrefix);
          })
          .map(
            (Map<Object?, Object?> v) => TtsVoice(
              name: (v['name'] as String?) ?? '',
              displayName: (v['name'] as String?) ?? '',
              lang: (v['locale'] as String?) ?? '',
            ),
          )
          .where((TtsVoice voice) => voice.name.isNotEmpty)
          .toList();
    } catch (_) {
      return <TtsVoice>[];
    }
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    unawaited(_stateController.close());
  }
}
