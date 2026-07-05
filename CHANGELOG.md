## 0.1.3

**Critical fix**

* Fixed a crash on compromised iOS devices: the native side emitted threat
  strings (`frida_env_found`, `suspicious_symlink`, `dylib_injected`,
  `debugger_attached`, `debug_env_found`) that the Dart `ShieldThreat` enum
  did not contain, so `ShieldThreat.fromString` threw during `init()` —
  the app crashed at startup instead of showing the blocked screen.
  All five values are now in the enum, and unrecognized strings fall back
  to `ShieldThreat.unknown` so version skew can never crash a consumer app.

**Detection fixes**

* Added the `<queries>` declarations required on Android 11+ — without them,
  package-visibility filtering silently disabled `root_app_found`,
  `lsposed_found`, `hook_package_found`, and `emulator_package_found`.
* Emulator detection no longer treats an empty radio version as a signal;
  real Wi-Fi-only devices (tablets without cellular) were false-positived
  and permanently blocked.

**Behavior changes**

* Removed the `su -c id` execution check — it popped a superuser grant
  dialog on rooted users' devices at launch and could block for ~10 seconds.
  The passive `su` binary file check covers the same signal.
  `ShieldThreat.suCommandExecuted` remains in the enum but is never emitted.
* Internal errors now fail open instead of blocking: a native error,
  malformed payload, or missing plugin implementation (web, desktop, widget
  tests — previously an uncaught `MissingPluginException`) returns
  `passed: true` with the new `ShieldResult.checkFailed` flag set, so real
  threats still block but a transient bug never bricks the app. Consumers
  wanting stricter behavior can inspect `checkFailed`.

**Other**

* Concurrent `check()` calls now share a single in-flight native check.
* Fixed process/reader leaks in the Android `getprop` checks.
* Filled in real podspec metadata and bundled the iOS privacy manifest.
* Removed dead code (`shield_route_guard.dart`).

## 0.1.2

* Enhanced CI security workflows with OSV scanner integration
* Updated CodeQL workflow configurations

## 0.1.1

* Added CodeQL static analysis CI (Dart, Android Kotlin, iOS Swift)
* Added OpenSSF Scorecard for supply-chain security monitoring
* Added SECURITY.md with private vulnerability reporting policy
* Fixed README: corrected go_router version to ^17.1.0

## 0.1.0

* Initial release
* Frida detection — port scanning, file detection, library scanning, process scanning
* Jailbreak detection for iOS — Cydia, suspicious dylibs, sandbox breach, symlinks
* Root detection for Android — su binary, root apps, test keys, dangerous props
* Emulator detection for Android — build props, files, hardware, packages
* Hook framework detection — Xposed, LSPosed, Substrate
* Debug mode detection — optional, off by default
* go_router integration with automatic redirect and pre-built blocked route
* Configurable behavior — callback, auto-block, or both
* Custom blocked widget support
* devMode flag for safe development on emulators and simulators
* Fail-secure defaults — native crashes default to blocked