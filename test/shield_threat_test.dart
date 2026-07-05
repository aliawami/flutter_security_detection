import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_security_detection/flutter_security_detection.dart';

/// Every threat string the Android native code can emit.
/// Keep in sync with android/src/main/kotlin — the test below guarantees
/// each one parses to a real enum value instead of falling back to unknown.
const androidNativeThreats = [
  'frida_port_open',
  'frida_process_found',
  'frida_library_found',
  'frida_file_found',
  'su_binary_found',
  'root_app_found',
  'test_keys_found',
  'dangerous_props_found',
  'emulator_build_props',
  'emulator_files_found',
  'emulator_package_found',
  'emulator_hardware_found',
  'xposed_framework_found',
  'lsposed_found',
  'hook_package_found',
  'xposed_stack_trace',
  'debug_mode_enabled',
  'adb_enabled',
];

/// Every threat string the iOS native code can emit.
/// Keep in sync with ios/Classes.
const iosNativeThreats = [
  'frida_port_open',
  'frida_library_found',
  'frida_file_found',
  'frida_env_found',
  'cydia_found',
  'suspicious_dylib',
  'sandbox_breach',
  'fork_allowed',
  'suspicious_symlink',
  'dylib_injected',
  'debugger_attached',
  'debug_env_found',
];

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

    test('returns unknown for unrecognized threat instead of throwing', () {
      expect(
        ShieldThreat.fromString('some_future_threat'),
        ShieldThreat.unknown,
      );
    });

    test('never throws on malformed input', () {
      expect(ShieldThreat.fromString(''), ShieldThreat.unknown);
      expect(ShieldThreat.fromString('__'), ShieldThreat.unknown);
      expect(ShieldThreat.fromString('_leading_underscore'),
          ShieldThreat.unknown);
    });

    test('every Android native threat string maps to a real enum value', () {
      for (final raw in androidNativeThreats) {
        expect(
          ShieldThreat.fromString(raw),
          isNot(ShieldThreat.unknown),
          reason: 'Android emits "$raw" but ShieldThreat cannot parse it',
        );
      }
    });

    test('every iOS native threat string maps to a real enum value', () {
      for (final raw in iosNativeThreats) {
        expect(
          ShieldThreat.fromString(raw),
          isNot(ShieldThreat.unknown),
          reason: 'iOS emits "$raw" but ShieldThreat cannot parse it',
        );
      }
    });
  });
}
