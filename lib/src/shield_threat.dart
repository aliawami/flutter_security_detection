enum ShieldThreat {
  // Frida
  fridaPortOpen,
  fridaLibraryFound,
  fridaProcessFound,
  fridaFileFound,
  // Root — Android
  suBinaryFound,
  rootAppFound,
  testKeysFound,
  dangerousPropsFound,
  suCommandExecuted,
  // Emulator — Android
  emulatorBuildProps,
  emulatorFilesFound,
  emulatorPackageFound,
  emulatorHardwareFound,
  // Hook frameworks — Android
  xposedFrameworkFound,
  lsposedFound,
  hookPackageFound,
  xposedStackTrace,
  // Debug — Android
  debugModeEnabled,
  adbEnabled,
  // Jailbreak — iOS
  cydiaFound,
  suspiciousDylib,
  sandboxBreach,
  forkAllowed;

  static ShieldThreat fromString(String value) {
    return ShieldThreat.values.firstWhere(
      (e) => e.name == _toCamelCase(value),
      orElse: () => throw ArgumentError('Unknown threat: $value'),
    );
  }

  // Converts "frida_port_open" → "fridaPortOpen"
  static String _toCamelCase(String value) {
    final parts = value.split('_');
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }
}
