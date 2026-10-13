# Testing on a real device

Unit tests cannot tell you whether a detector fires (or misfires) on real
hardware. This guide walks through verifying the checks with the example app.
Do **Part 1 first**: a false positive on a normal phone is the worst bug this
package can have, because it blocks a legitimate user.

## 0. Setup

```bash
git clone https://github.com/aliawami/flutter_security_detection
cd flutter_security_detection/example
flutter pub get
```

Always test **release** builds (`--release`). Debug builds are
`debuggable`, and the example's `devMode` is **off** by default, so you see
real results. Switches (pass with `--dart-define=NAME=true`):

| Define | Effect |
|---|---|
| `SHIELD_DEBUG_DETECTION` | also report debuggers / debuggable builds |
| `SHIELD_DEV_MODE` | bypass all checks (simulator / emulator development) |

The example opens on the home screen when the device passes. If the device
fails, it shows a **Device Not Secure** page listing every threat found.
Press **Re-check** to run again. `flutter run` also prints
`Threats: [...]` from the `onThreatDetected` callback.

**Android:** `flutter run --release -d <device-id>` (`adb devices` lists ids).
**iOS:** open `ios/Runner.xcworkspace` once in Xcode, set your Team under
Signing & Capabilities, then `flutter run --release -d <device-id>`.

## 1. Baseline: a normal, unmodified phone (must pass)

On a stock device (no root, no jailbreak, no custom ROM), release build:

- [ ] The home screen appears and **Run Security Check** shows **Passed**
  with **None — device is clean**.
- [ ] Background the app and bring it back (the example re-checks on
  resume). Still passes.

On Android, `adb_enabled` is only reported with `SHIELD_DEBUG_DETECTION`, so a
USB-connected phone still passes without it.

If you have more than one device, repeat on each. The most useful extra
devices are a **Wi-Fi-only tablet**, a **non-Google brand** (Xiaomi, Huawei,
Samsung) and a phone on a **custom ROM**. **Any threat listed here is a bug**:
note the device and ROM and send me the threat names.

## 2. Android scenarios

| # | Setup | Expected threats |
|---|---|---|
| A1 | Android Studio emulator (AVD): `flutter run --release -d emulator-5554` | `emulatorBuildProps`, `emulatorHardwareFound` (+ maybe `emulatorFilesFound`) |
| A2 | Stock phone, `--dart-define=SHIELD_DEBUG_DETECTION=true`, USB debugging on | `adbEnabled` |
| A3 | Same, but a **debug** build (`flutter run --debug ...`) | `debugModeEnabled`, `adbEnabled` |
| A4 | Rooted device or rootable AVD (no Play Store image), Magisk/KernelSU installed with its **default** app name | `suBinaryFound` and/or `rootAppFound` |
| A5 | Same rooted device, Magisk app **renamed/hidden** ("Hide the Magisk app") | May pass — this is a documented limitation. Note what is reported. |
| A6 | Frida server (below) running | `fridaPortOpen`, `fridaFileFound` |
| A7 | LSPosed installed, example app in a module's scope | `lsposedFound`, `hookPackageFound`, possibly `xposedFrameworkFound` / `xposedStackTrace` |

**Frida server on Android (A6)** — needs a rooted device or a rootable AVD:

1. Download the `frida-server-<ver>-android-<arch>.xz` matching your device
   from <https://github.com/frida/frida/releases>, and unpack it.
2. ```bash
   adb root                      # AVD; on a Magisk phone use `adb shell su -c ...`
   adb push frida-server /data/local/tmp/frida-server
   adb shell chmod 755 /data/local/tmp/frida-server
   adb shell "/data/local/tmp/frida-server &"
   ```
3. Tap **Re-check** (or background and resume the app). Expect
   `fridaPortOpen` (27042) and `fridaFileFound`.
4. Stop it (`adb shell pkill frida-server`), delete the file, **Re-check**
   again. Expect them to disappear: that confirms runtime re-checks work.

`fridaProcessFound` usually will **not** appear on Android 7+ (process
isolation); that is expected and documented.

## 3. iOS scenarios

| # | Setup | Expected threats |
|---|---|---|
| I1 | iOS Simulator, `flutter run --release` | none (checks are skipped on the Simulator by design) |
| I2 | Stock iPhone, `flutter run --debug --dart-define=SHIELD_DEBUG_DETECTION=true` (debugger attached) | `debuggerAttached` (+ maybe `debugEnvFound`) |
| I3 | Stock iPhone, same flag but `--release` (no debugger) | none |
| I4 | Jailbroken iPhone, release build | `cydiaFound` (files such as `/var/jb`, Sileo, Zebra), `suspiciousDylib` / `sandboxBreach` depending on the jailbreak |
| I5 | Jailbroken + `frida-server` running | `fridaPortOpen` (+ `fridaFileFound`) |

If you only have a **stock iPhone**, I1–I3 plus Part 1 are the meaningful
tests: the baseline must pass, and I2 proves the native code is really
running. Note that on iOS 17+ a `--debug` build cannot be relaunched from the
home screen without Xcode; use `flutter run`.

If you have a **jailbroken** iPhone and I4 reports nothing, that is a missed
detection. Please send: iOS version, jailbreak name (Dopamine, palera1n,
checkra1n...), rootful or rootless, and the output of
`ls -d /var/jb /var/binpack /Applications/*.app` from a terminal on the device.

## 4. Run the native unit tests locally (optional)

```bash
cd example/android && ./gradlew testDebugUnitTest      # Kotlin
```
iOS unit tests: open `example/ios/Runner.xcworkspace` in Xcode, select the
**RunnerTests** scheme and press Cmd+U. (CI also runs both.)

## 5. What to send back

For each scenario that surprised you:

1. Device model and OS version (and ROM / jailbreak / root method).
2. Build mode and `--dart-define`s used.
3. The threat names from the screen or from the `Threats: [...]` log line
   (`adb logcat -s flutter` on Android).
4. What you expected instead.

Do not treat a threat reported on a modified device (root, jailbreak, hooking
tools) as a bug: that is the package working.
