import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_security_detection/flutter_security_detection.dart';
import 'package:flutter_security_detection/src/flutter_security_detection_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.flutter_shield/security');

  tearDown(() {
    TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('FlutterShieldChannel.checkDevice', () {
    test('returns passed result when native returns clean', () async {
      TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'checkDevice') {
          return {
            'passed': true,
            'isJailbroken': false,
            'isRooted': false,
            'isFridaDetected': false,
            'threats': <String>[],
          };
        }
        return null;
      });

      final result = await FlutterSecurityDetectionChannel.checkDevice(
        const ShieldConfig(),
      );

      expect(result.passed, true);
      expect(result.threats, isEmpty);
    });

    test('returns failed result when native detects frida', () async {
      TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'checkDevice') {
          return {
            'passed': false,
            'isJailbroken': false,
            'isRooted': false,
            'isFridaDetected': true,
            'threats': ['frida_port_open'],
          };
        }
        return null;
      });

      final result = await FlutterSecurityDetectionChannel.checkDevice(
        const ShieldConfig(),
      );

      expect(result.passed, false);
      expect(result.isFridaDetected, true);
      expect(result.threats, contains(ShieldThreat.fridaPortOpen));
    });

    test('fails secure when native throws PlatformException', () async {
      TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'SHIELD_ERROR', message: 'crash');
      });

      final result = await FlutterSecurityDetectionChannel.checkDevice(
        const ShieldConfig(),
      );

      // Fail secure — passed must be false when native crashes
      expect(result.passed, false);
    });

    test('passes correct arguments to native', () async {
      Map<String, dynamic>? capturedArgs;

      TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        capturedArgs = Map<String, dynamic>.from(
          call.arguments as Map,
        );
        return {
          'passed': true,
          'isJailbroken': false,
          'isRooted': false,
          'isFridaDetected': false,
          'threats': <String>[],
        };
      });

      await FlutterSecurityDetectionChannel.checkDevice(
        const ShieldConfig(
          enableFridaDetection: false,
          enableDebugDetection: true,
        ),
      );

      expect(capturedArgs?['enableFrida'], false);
      expect(capturedArgs?['enableDebugDetection'], true);
    });
  });
}