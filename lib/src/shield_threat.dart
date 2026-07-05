enum ShieldThreat {
  // Frida
  fridaPortOpen,
  fridaLibraryFound,
  fridaProcessFound,
  fridaFileFound,
  fridaEnvFound,
  // Root — Android
  suBinaryFound,
  rootAppFound,
  testKeysFound,
  dangerousPropsFound,
  // No longer emitted since 0.2.0 — executing `su` triggered a superuser
  // prompt on rooted devices. Kept so existing switch statements compile.
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
  forkAllowed,
  suspiciousSymlink,
  dylibInjected,
  // Debug — iOS
  debuggerAttached,
  debugEnvFound,
  // Fallback for threat names this Dart version does not know.
  // Guarantees a native/Dart version skew can never crash the app.
  unknown;

  static ShieldThreat fromString(String value) {
    final name = _toCamelCase(value);
    return ShieldThreat.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ShieldThreat.unknown,
    );
  }

  // Converts "frida_port_open" → "fridaPortOpen"
  static String _toCamelCase(String value) {
    final parts = value.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }
}
