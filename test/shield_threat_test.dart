import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_security_detection/flutter_security_detection.dart';

void main() {
  group('ShieldThreat.fromString', () {
    test('converts snake_case to camelCase correctly', () {
      expect(
        ShieldThreat.fromString('frida_port_open'),
        ShieldThreat.fridaPortOpen,
      );
      expect(
        ShieldThreat.fromString('su_binary_found'),
        ShieldThreat.suBinaryFound,
      );
      expect(
        ShieldThreat.fromString('cydia_found'),
        ShieldThreat.cydiaFound,
      );
    });

    test('throws ArgumentError for unknown threat', () {
      expect(
        () => ShieldThreat.fromString('unknown_threat'),
        throwsArgumentError,
      );
    });
  });
}
