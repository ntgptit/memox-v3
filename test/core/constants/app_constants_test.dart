import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/constants/app_constants.dart';

void main() {
  group('AppConstants.guestDatabaseStore', () {
    test('embeds the base name and the local-store generation', () {
      // The store name is shared verbatim by the web (IndexedDB/OPFS db name)
      // and native (file stem) connections, so its format is an invariant:
      // changing it silently abandons every on-device database.
      expect(
        AppConstants.guestDatabaseStore,
        '${AppConstants.localDatabaseName}_guest_g${AppConstants.localStoreGeneration}',
      );
    });

    test('current generation resolves to memox_guest_g2', () {
      // Locks the as-shipped value: a bump here is a deliberate, destructive
      // local-store reset (see app_constants.dart / storage-boundaries.md).
      expect(AppConstants.localStoreGeneration, 2);
      expect(AppConstants.guestDatabaseStore, 'memox_guest_g2');
    });
  });
}
