import 'shield_result.dart';

class ShieldConfig {
  const ShieldConfig({
    this.enableFridaDetection = true,
    this.enableJailbreakDetection = true,
    this.enableRootDetection = true,
    this.enableEmulatorDetection = true,
    this.enableHookDetection = true,
    this.enableDebugDetection = false,
    this.devMode = false,
    this.recheckOnResume = false,
    this.recheckInterval,
    this.onThreatDetected,
  });

  final bool enableFridaDetection;
  final bool enableJailbreakDetection;
  final bool enableRootDetection;
  final bool enableEmulatorDetection;
  final bool enableHookDetection;
  final bool enableDebugDetection;

  /// Bypasses all native checks and always reports a clean device.
  final bool devMode;

  /// Re-run the checks every time the app returns to the foreground. An
  /// attacker can attach Frida or enable a hook after launch; this narrows
  /// that window.
  final bool recheckOnResume;

  /// Re-run the checks periodically while the app is running. `null`
  /// (default) disables periodic checks.
  final Duration? recheckInterval;

  /// Called when a check finds threats, and again whenever a later re-check
  /// reports a different failing result. Not called for an unchanged result.
  final void Function(ShieldResult)? onThreatDetected;
}
