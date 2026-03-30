import 'package:flutter/services.dart';
import 'package:flutter_security_detection/src/core/constants/constants_strings.dart';
import 'shield_config.dart';
import 'shield_result.dart';

class FlutterSecurityDetectionChannel {
  static const _channel = MethodChannel(channelName);
  static Future<ShieldResult> checkDevice(ShieldConfig config) async {
    try {
      final result = await _channel.invokeMethod<Map>('checkDevice', {
        'enableFrida': config.enableFridaDetection,
        'enableJailbreak': config.enableJailbreakDetection,
        'enableRoot': config.enableRootDetection,
        'enableEmulator': config.enableEmulatorDetection,
        'enableHookDetection': config.enableHookDetection,
        'enableDebugDetection': config.enableDebugDetection,
      });

      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'Native check returned null',
        );
      }

      return ShieldResult.fromMap(result);
    } on PlatformException catch (_) {
      return ShieldResult(
        passed: false,
        isJailbroken: false,
        isRooted: false,
        isFridaDetected: false,
        threats: [],
      );
    }
  }
}
