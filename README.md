# flutter_security_detection

[![pub.dev](https://img.shields.io/pub/v/flutter_security_detection.svg)](https://pub.dev/packages/flutter_security_detection)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/aliAlawami/flutter_security_detection/blob/main/LICENSE)
[![platform](https://img.shields.io/badge/platform-android%20%7C%20ios-green.svg)](https://pub.dev/packages/flutter_security_detection)
[![likes](https://img.shields.io/pub/likes/flutter_security_detection)](https://pub.dev/packages/flutter_security_detection)
[![pub points](https://img.shields.io/pub/points/flutter_security_detection)](https://pub.dev/packages/flutter_security_detection)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/aliawami/flutter_security_detection/badge)](https://securityscorecards.dev/viewer/?uri=github.com/aliawami/flutter_security_detection)
[![CodeQL](https://github.com/aliawami/flutter_security_detection/actions/workflows/codeql.yml/badge.svg)](https://github.com/aliawami/flutter_security_detection/actions/workflows/codeql.yml)

Device integrity checks for Flutter. Detects Frida instrumentation, jailbreak, root, emulator, and hook frameworks, with a router-agnostic gate widget and optional runtime re-checks.

---

<div dir="rtl">

حزمة فحص سلامة الجهاز لتطبيقات Flutter. تكشف عن أدوات الاختراق مثل Frida، والأجهزة المكسورة (Jailbreak)، والأجهزة المُطوَّرة (Root)، والمحاكيات، وأطر الاعتراض — مع أداة جاهزة لحجب التطبيق وفحص دوري أثناء التشغيل.

</div>

---

## Security model / نموذج الأمان

> **These checks run on a device the attacker controls. A determined attacker can bypass them** — for example by hooking this plugin's method channel, patching the app, or hiding root. Treat this package as a **deterrent and a UX layer** that stops casual tampering and gives you a signal, **not as a security boundary**.
>
> Anything that matters must be enforced **on your server**: validate sessions, authorize every request, and for high-risk flows use server-verified attestation — [Play Integrity API](https://developer.android.com/google/play/integrity) on Android and [App Attest](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity) on iOS. This package does not provide attestation.
>
> If you need a commercial-grade runtime protection suite, look at dedicated RASP products in addition to this package.

<div dir="rtl">

> **هذه الفحوصات تعمل على جهاز يتحكم به المهاجم، ويمكن لمهاجم مصمم تجاوزها** — مثلًا بالتعديل على قناة الاتصال الخاصة بالإضافة أو تعديل التطبيق أو إخفاء الروت. اعتبر هذه الحزمة **رادعًا وطبقة تجربة مستخدم** تمنع العبث البسيط وتمنحك إشارة، **وليست حدًا أمنيًا**.
>
> أي شيء مهم يجب فرضه **على الخادم**: تحقق من الجلسات، وصرّح لكل طلب، وللعمليات عالية الخطورة استخدم التحقق من الجهاز عبر الخادم: Play Integrity على أندرويد و App Attest على iOS. هذه الحزمة لا توفر هذه الخدمات.

</div>

---

## Features / المميزات

| | English | العربية |
|---|---|---|
| 🔍 | Frida Detection | كشف Frida |
| 📱 | Jailbreak Detection (iOS) | كشف الجيلبريك |
| 🔓 | Root Detection (Android) | كشف الروت |
| 🖥️ | Emulator Detection (Android) | كشف المحاكي |
| 🪝 | Hook Framework Detection (Android) | كشف أطر الاعتراض |
| 🛡️ | `ShieldGate` widget, works with any router | أداة حجب تعمل مع أي موجّه |
| 🔁 | Opt-in re-checks on resume / on a timer | فحص دوري اختياري |
| ⚙️ | Fully Configurable | قابل للتخصيص بالكامل |
| 🧑‍💻 | devMode for safe development | وضع التطوير الآمن |

---

## Installation / التثبيت

Add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_security_detection: ^0.3.0
```
```bash
flutter pub get
```

The package has no dependency on any router.

---

## Quick Start / البداية السريعة

### 1. Initialize in `main()`
```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_security_detection/flutter_security_detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterSecurityDetection.init(
    config: ShieldConfig(
      devMode: kDebugMode, // safe in dev, full protection in release
      recheckOnResume: true, // re-check when the app returns to foreground
      onThreatDetected: (result) {
        print('Threats: ${result.threats}');
      },
    ),
  );

  runApp(const MyApp());
}
```

### 2. Wrap your app in `ShieldGate`
```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Works with Navigator, go_router, auto_route, ... — any router.
      builder: (context, child) => ShieldGate(child: child!),
      home: const HomeScreen(),
    );
  }
}
```

`ShieldGate` shows your app only while the device passes. While the first
check is running it shows a `loading` widget (empty by default), so protected
UI never flashes on a compromised device. When a runtime re-check finds a
threat, it swaps to the blocked screen on the spot.

<div dir="rtl">

يعرض `ShieldGate` تطبيقك فقط ما دام الجهاز يجتاز الفحص، ويستبدله بشاشة الحظر فور اكتشاف تهديد أثناء التشغيل.

</div>

### Using go_router

The package does not depend on `go_router`; use the result listenable and
`isBlocked` to build the redirect yourself:
```dart
final router = GoRouter(
  // Re-evaluate the redirect when a runtime re-check changes the result.
  refreshListenable: FlutterSecurityDetection.resultListenable,
  redirect: (context, state) {
    final blocked = FlutterSecurityDetection.isBlocked;
    if (blocked && state.uri.path != '/blocked') return '/blocked';
    if (!blocked && state.uri.path == '/blocked') return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/blocked',
      builder: (context, state) => const ShieldBlockedScreen(),
    ),
  ],
);
```
`isBlocked` is `false` until the first check completes, so `await
FlutterSecurityDetection.init()` before `runApp()` when you use this recipe.

---

## Runtime re-checks / الفحص أثناء التشغيل

By default the check runs once, at `init()`. An attacker can attach Frida or
enable a hook after launch, so you can opt in to more:
```dart
ShieldConfig(
  recheckOnResume: true,                       // every time the app resumes
  recheckInterval: const Duration(minutes: 5), // and/or on a timer
)
```
Listen to `FlutterSecurityDetection.resultListenable` to react to changes.
`onThreatDetected` fires when a check finds threats, and again when a later
re-check reports a different failing result — not for an unchanged result.

---

## Configuration / الإعدادات
```dart
await FlutterSecurityDetection.init(
  config: ShieldConfig(
    enableFridaDetection: true,       // كشف Frida — الافتراضي: true
    enableJailbreakDetection: true,   // كشف الجيلبريك — الافتراضي: true
    enableRootDetection: true,        // كشف الروت — الافتراضي: true
    enableEmulatorDetection: true,    // كشف المحاكي — الافتراضي: true
    enableHookDetection: true,        // كشف أطر الاعتراض — الافتراضي: true
    enableDebugDetection: false,      // كشف وضع التصحيح — الافتراضي: false
    devMode: false,                   // وضع التطوير — الافتراضي: false
    recheckOnResume: false,           // فحص عند العودة للتطبيق — الافتراضي: false
    recheckInterval: null,            // فحص دوري — الافتراضي: null
    onThreatDetected: (result) {},    // يُستدعى عند اكتشاف تهديد — الافتراضي: null
  ),
);
```

---

## Custom Blocked Screen / شاشة حظر مخصصة
```dart
ShieldGate(
  blocked: const Scaffold(
    backgroundColor: Colors.red,
    body: Center(
      child: Text(
        'هذا الجهاز غير آمن',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  ),
  loading: const Center(child: CircularProgressIndicator()),
  child: child!,
)
```

---

## Manual Check / فحص يدوي
```dart
// Returns the latest result (runs a check if none exists yet)
final result = await FlutterSecurityDetection.check();

// Force a fresh check
final result = await FlutterSecurityDetection.recheck();

// Synchronous access to the latest result
FlutterSecurityDetection.lastResult; // null before the first check
FlutterSecurityDetection.isBlocked;  // false before the first check

if (!result.passed) {
  print(result.threats);
  // [ShieldThreat.fridaPortOpen, ShieldThreat.cydiaFound]
}
```

---

## Threat Reference / مرجع التهديدات

| Threat | Platform | Description | الوصف |
|---|---|---|---|
| `fridaPortOpen` | Both | Frida server port 27042 open | منفذ Frida مفتوح |
| `fridaLibraryFound` | Both | Frida agent in memory | مكتبة Frida في الذاكرة |
| `fridaFileFound` | Both | Frida binary on disk | ملف Frida على الجهاز |
| `fridaProcessFound` | Android | Frida process running | عملية Frida قيد التشغيل |
| `fridaEnvFound` | iOS | Frida environment variables | متغيرات بيئة Frida |
| `suBinaryFound` | Android | su binary detected | ملف su موجود |
| `rootAppFound` | Android | Root app installed | تطبيق روت مثبت |
| `testKeysFound` | Android | Test-signed build | بناء بمفاتيح اختبار |
| `dangerousPropsFound` | Android | Dangerous system props | خصائص نظام خطيرة |
| `emulatorBuildProps` | Android | Emulator build fingerprint | بصمة بناء المحاكي |
| `emulatorFilesFound` | Android | Emulator files on disk | ملفات المحاكي |
| `emulatorPackageFound` | Android | Emulator launcher installed | مشغل محاكي مثبت |
| `emulatorHardwareFound` | Android | Emulator hardware | عتاد المحاكي |
| `xposedFrameworkFound` | Android | Xposed framework | إطار Xposed |
| `lsposedFound` | Android | LSPosed manager | مدير LSPosed |
| `hookPackageFound` | Android | Hook management app installed | تطبيق اعتراض مثبت |
| `xposedStackTrace` | Android | Xposed traces in stack | آثار Xposed في المكدس |
| `debugModeEnabled` | Android | App is debuggable | التطبيق قابل للتصحيح |
| `adbEnabled` | Android | ADB debugging enabled | تصحيح ADB مفعل |
| `cydiaFound` | iOS | Cydia or jailbreak files | ملفات الجيلبريك |
| `suspiciousDylib` | iOS | MobileSubstrate loaded | MobileSubstrate محمل |
| `sandboxBreach` | iOS | Sandbox write succeeded | اختراق الحماية |
| `forkAllowed` | iOS | Process spawn succeeded | إنتاج العمليات |
| `suspiciousSymlink` | iOS | Jailbreak symlinks present | روابط رمزية للجيلبريك |
| `dylibInjected` | iOS | DYLD library injection | حقن مكتبة DYLD |
| `debuggerAttached` | iOS | Debugger attached | مصحح أخطاء متصل |
| `debugEnvFound` | iOS | Debug environment variables | متغيرات بيئة التصحيح |
| `unknown` | Both | Unrecognized threat (version skew) | تهديد غير معروف |

### Error handling / معالجة الأخطاء

If the check itself cannot run — a native error, or an unsupported platform
such as web, desktop, or widget tests — the package **fails open**:
`passed` is `true` and `ShieldResult.checkFailed` is set. Real threats always
block; internal errors never brick the app. Enforce a stricter policy if you
need one:

```dart
final result = await FlutterSecurityDetection.check();
if (result.checkFailed) {
  // The check did not run. Retry with recheck(), or block if your
  // compliance requirements demand fail-closed behavior.
}
```

---

## devMode / وضع التطوير

`devMode` bypasses all native checks and always returns `passed: true`.
Use it during development to work safely on emulators and simulators.

<div dir="rtl">

`devMode` يتجاوز جميع فحوصات الأمان ويعيد دائمًا `passed: true`.
استخدمه أثناء التطوير للعمل بأمان على المحاكيات.

</div>
```dart
// Recommended — automatic per build mode
config: ShieldConfig(devMode: kDebugMode)

// Manual
config: ShieldConfig(devMode: true)  // development
config: ShieldConfig(devMode: false) // production
```

> ⚠️ Never ship with `devMode: true` in production.
>
> ⚠️ لا تنشر التطبيق وهو في وضع `devMode: true`.

---

## Known Limitations / القيود المعروفة

**Android process scanning** — Due to Android's process namespace isolation and SELinux restrictions, `fridaProcessFound` is a best-effort signal. Port scanning and file detection are the primary Frida signals and work reliably across all Android versions.

**Android `INTERNET` permission** — The Frida port check opens a loopback socket, which needs `<uses-permission android:name="android.permission.INTERNET"/>` in your app's manifest (most apps already have it). Without it that one check silently reports "not found"; every other check is unaffected. The plugin does not add the permission for you, so as not to impose it on every consumer.

**Hidden root managers** — Magisk can randomize its app's package name and hide `su`, and KernelSU/APatch can hide from the app list. Package- and file-based root detection cannot see a manager that is hidden from your app.

**Simulator** — Detection is intentionally skipped on the iOS Simulator at compile time via `#if targetEnvironment(simulator)`.

**Client-side only** — See [Security model](#security-model--نموذج-الأمان) above. Every signal here can be defeated by an attacker who controls the device.

**Determined attackers** — No detection solution is foolproof. A sophisticated attacker with full device control can bypass individual checks. `flutter_security_detection` raises the security bar significantly and satisfies most enterprise compliance requirements.

<div dir="rtl">

**فحص العمليات على Android** — بسبب قيود نظام Android على الوصول إلى `/proc`، فإن `fridaProcessFound` إشارة بالجهد الأفضل. فحص المنافذ والملفات هو الأساس.

**المحاكي** — يتم تجاهل الفحوصات على محاكي iOS تلقائيًا عند وقت الترجمة.

**المهاجمون المتمرسون** — لا توجد حماية مطلقة. الحزمة ترفع مستوى الأمان بشكل كبير وتلبي متطلبات الامتثال المؤسسي في معظم الحالات.

</div>

---

## License / الرخصة

MIT © [Ali Alawami](https://github.com/aliAlawami)

---

<div align="center">

Made with ❤️ for the Flutter community

صُنع بـ ❤️ لمجتمع Flutter

</div>