

import 'package:flutter/widgets.dart';

import 'shield_result.dart';

class ShieldConfig {
  final bool enableFridaDetection;
  final bool enableJailbreakDetection;
  final bool enableRootDetection;
  final bool enableEmulatorDetection;
  final bool enableHookDetection;
  final bool enableDebugDetection;
  final bool devMode;
  final void Function(ShieldResult)? onThreatDetected;
  final String blockedRoutePath;
  final Widget? blockedWidget;
  

  const ShieldConfig({
    this.enableFridaDetection = true,
    this.enableJailbreakDetection = true,
    this.enableRootDetection = true,
    this.enableEmulatorDetection = true,
    this.enableHookDetection = true,
    this.enableDebugDetection = false,
    this.onThreatDetected,
    this.devMode = false, 
    this.blockedRoutePath = '/blocked',
    this.blockedWidget,
  });
}