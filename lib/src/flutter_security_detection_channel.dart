import 'package:flutter/services.dart';
import 'package:flutter_security_detection/src/core/constants/constants_strings.dart';
import 'shield_config.dart';
import 'shield_result.dart';

class FlutterSecurityDetectionChannel {
  static const _channel = MethodChannel(channelName);

  /// Result returned when the check itself cannot run — native error,
  /// malformed native payload, or no plugin implementation (web, desktop,
  /// widget tests). Fails open: real threats block, internal errors don't.
  static const _failedCheck = ShieldResult(
    passed: true,
    isJailbroken: false,
    isRooted: false,
    isFridaDetected: false,
    threats: [],
    checkFailed: true,
  );

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

      if (result == null) return _failedCheck;

      return ShieldResult.fromMap(result);
    } on PlatformException {
      return _failedCheck;
    } on MissingPluginException {
      return _failedCheck;
    } catch (_) {
      // Malformed native payload must never crash the consumer app.
      return _failedCheck;
    }
  }
}
