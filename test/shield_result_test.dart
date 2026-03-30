import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_security_detection/flutter_security_detection.dart';

void main() {
  group('ShieldResult.fromMap', () {
    test('parses a clean device correctly', () {
      final map = {
        'passed': true,
        'isJailbroken': false,
        'isRooted': false,
        'isFridaDetected': false,
        'threats': <String>[],
      };

      final result = ShieldResult.fromMap(map);

      expect(result.passed, true);
      expect(result.isJailbroken, false);
      expect(result.isRooted, false);
      expect(result.isFridaDetected, false);
      expect(result.threats, isEmpty);
    });

    test('parses a compromised device correctly', () {
      final map = {
        'passed': false,
        'isJailbroken': true,
        'isRooted': false,
        'isFridaDetected': true,
        'threats': ['frida_port_open', 'cydia_found'],
      };

      final result = ShieldResult.fromMap(map);

      expect(result.passed, false);
      expect(result.isFridaDetected, true);
      expect(
          result.threats,
          containsAll([
            ShieldThreat.fridaPortOpen,
            ShieldThreat.cydiaFound,
          ]));
    });

    test('handles empty threats list gracefully', () {
      final map = {
        'passed': false,
        'isJailbroken': false,
        'isRooted': false,
        'isFridaDetected': false,
        'threats': null,
      };

      final result = ShieldResult.fromMap(map);
      expect(result.threats, isEmpty);
    });
  });

  group('ShieldResult equality', () {
    test('two identical results are equal', () {
      const a = ShieldResult(
        passed: true,
        isJailbroken: false,
        isRooted: false,
        isFridaDetected: false,
        threats: [],
      );
      const b = ShieldResult(
        passed: true,
        isJailbroken: false,
        isRooted: false,
        isFridaDetected: false,
        threats: [],
      );

      expect(a, equals(b));
    });
  });
}
