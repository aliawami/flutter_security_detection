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