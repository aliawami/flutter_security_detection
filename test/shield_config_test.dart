import 'package:flutter_security_detection/src/shield_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShieldConfig defaults', () {
    test('all detections enabled by default except debug', () {
      const config = ShieldConfig();

      expect(config.enableFridaDetection, true);
      expect(config.enableJailbreakDetection, true);
      expect(config.enableRootDetection, true);
      expect(config.enableEmulatorDetection, true);
      expect(config.enableHookDetection, true);
      expect(config.enableDebugDetection, false);
    });

    test('runtime re-checks are opt-in', () {
      const config = ShieldConfig();
      expect(config.recheckOnResume, false);
      expect(config.recheckInterval, isNull);
    });

    test('custom config overrides defaults', () {
      const config = ShieldConfig(
        enableFridaDetection: false,
        enableDebugDetection: true,
        recheckOnResume: true,
      );

      expect(config.enableFridaDetection, false);
      expect(config.enableDebugDetection, true);
      expect(config.recheckOnResume, true);
    });
  });
}
