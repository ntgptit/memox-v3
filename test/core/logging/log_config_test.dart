import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:memox/core/logging/log_config.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Lets the `Logger.root.onRecord` stream deliver the record to the Talker sink.
Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  setUp(() {
    MxLog.init();
    MxLog.talker!.cleanHistory();
  });

  test('init wires the root logger at the debug (FINE) threshold', () {
    // `flutter test` is a non-release build, so the threshold is FINE.
    expect(Logger.root.level, Level.FINE);
    expect(MxLog.talker, isNotNull);
  });

  test('init is idempotent — a second call keeps the same Talker', () {
    final Talker first = MxLog.talker!;
    MxLog.init();
    expect(identical(MxLog.talker, first), isTrue);
  });

  test(
    'a logging record reaches the Talker history with its payload',
    () async {
      Logger('library.test').info('overview_load entry count=3');
      await _flush();

      expect(
        MxLog.talker!.history.any(
          (TalkerData d) =>
              d.message?.contains(
                '[library.test] overview_load entry count=3',
              ) ??
              false,
        ),
        isTrue,
      );
    },
  );

  group('level mapping', () {
    final Map<Level, LogLevel> cases = <Level, LogLevel>{
      Level.SEVERE: LogLevel.error,
      Level.WARNING: LogLevel.warning,
      Level.INFO: LogLevel.info,
      Level.FINE: LogLevel.debug,
    };

    cases.forEach((Level source, LogLevel expected) {
      test('${source.name} → ${expected.name}', () async {
        Logger('map.test').log(source, 'msg ${source.name}');
        await _flush();

        final TalkerData data = MxLog.talker!.history.lastWhere(
          (TalkerData d) => d.message?.contains('msg ${source.name}') ?? false,
        );
        expect(data.logLevel, expected);
      });
    });
  });
}
