# flutter_security_detection

<div dir="rtl">

# flutter_security_detection

</div>

[![pub.dev](https://img.shields.io/pub/v/flutter_security_detection.svg)](https://pub.dev/packages/flutter_security_detection)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/aliAlawami/flutter_security_detection/blob/main/LICENSE)
[![platform](https://img.shields.io/badge/platform-android%20%7C%20ios-green.svg)](https://pub.dev/packages/flutter_security_detection)

Enterprise-grade security package for Flutter. Detects Frida instrumentation, jailbreak, root, emulator, and hook frameworks with built-in go_router integration.

---

<div dir="rtl">

حزمة أمان متكاملة لتطبيقات Flutter. تكشف عن أدوات الاختراق مثل Frida، والأجهزة المكسورة (Jailbreak)، والأجهزة المُطوَّرة (Root)، والمحاكيات، وأطر الاعتراض — مع دعم مدمج لـ go_router.

</div>

---

## Features / المميزات

| | English | العربية |
|---|---|---|
| 🔍 | Frida Detection | كشف Frida |
| 📱 | Jailbreak Detection (iOS) | كشف الجيلبريك |
| 🔓 | Root Detection (Android) | كشف الروت |
| 🖥️ | Emulator Detection | كشف المحاكي |
| 🪝 | Hook Framework Detection | كشف أطر الاعتراض |
| 🛡️ | go_router Integration | تكامل مع go_router |
| ⚙️ | Fully Configurable | قابل للتخصيص بالكامل |
| 🧑‍💻 | devMode for safe development | وضع التطوير الآمن |

---

## Why flutter_security_detection?

| Feature | flutter_security_detection | flutter_jailbreak_detection | safe_device | freeRASP |
|---|:---:|:---:|:---:|:---:|
| Frida Detection | ✅ | ❌ | ❌ | ✅ |
| Jailbreak / Root | ✅ | ✅ | ✅ | ✅ |
| Emulator Detection | ✅ | ❌ | ❌ | ✅ |
| Hook Frameworks | ✅ | ❌ | ❌ | ✅ |
| go_router Integration | ✅ | ❌ | ❌ | ❌ |
| devMode Flag | ✅ | ❌ | ❌ | ❌ |
| Custom Blocked Screen | ✅ | ❌ | ❌ | ❌ |
| Lightweight | ✅ | ✅ | ✅ | ❌ |
| Open Source | ✅ | ✅ | ✅ | ⚠️ |

---

## Installation / التثبيت

Add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_security_detection: ^0.1.0
  go_router: ^14.0.0
```
```bash
flutter pub get
```

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
      onThreatDetected: (result) {
        print('Threats: ${result.threats}');
      },
    ),
  );

  runApp(const MyApp());
}
```

### 2. Add go_router Integration
```dart
final _router = GoRouter(
  redirect: FlutterSecurityDetection.routerRedirect,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    FlutterSecurityDetection.blockedRoute,
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
```

That is all. Your app is now protected.

<div dir="rtl">

هذا كل شيء. تطبيقك محمي الآن.

</div>

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
    blockedRoutePath: '/blocked',     // مسار شاشة الحظر — الافتراضي: '/blocked'
    blockedWidget: null,              // شاشة حظر مخصصة — الافتراضي: الشاشة المدمجة
  ),
);
```

---

## Custom Blocked Screen / شاشة حظر مخصصة
```dart
await FlutterSecurityDetection.init(
  config: ShieldConfig(
    blockedWidget: Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Text(
          'هذا الجهاز غير آمن',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    ),
  ),
);
```

---

## Manual Check / فحص يدوي
```dart
// Returns cached result from init()
final result = await FlutterSecurityDetection.check();

// Force a fresh check
final result = await FlutterSecurityDetection.recheck();

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
| `suBinaryFound` | Android | su binary detected | ملف su موجود |
| `rootAppFound` | Android | Root app installed | تطبيق روت مثبت |
| `testKeysFound` | Android | Test-signed build | بناء بمفاتيح اختبار |
| `dangerousPropsFound` | Android | Dangerous system props | خصائص نظام خطيرة |
| `emulatorBuildProps` | Android | Emulator build fingerprint | بصمة بناء المحاكي |
| `emulatorFilesFound` | Android | Emulator files on disk | ملفات المحاكي |
| `emulatorHardwareFound` | Android | Emulator hardware | عتاد المحاكي |
| `xposedFrameworkFound` | Android | Xposed framework | إطار Xposed |
| `lsposedFound` | Android | LSPosed manager | مدير LSPosed |
| `cydiaFound` | iOS | Cydia or jailbreak files | ملفات الجيلبريك |
| `suspiciousDylib` | iOS | MobileSubstrate loaded | MobileSubstrate محمل |
| `sandboxBreach` | iOS | Sandbox write succeeded | اختراق الحماية |
| `forkAllowed` | iOS | Process spawn succeeded | إنتاج العمليات |
| `debuggerAttached` | iOS | Debugger attached | مصحح أخطاء متصل |
| `debugModeEnabled` | Android | App is debuggable | التطبيق قابل للتصحيح |

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

**Simulator** — Detection is intentionally skipped on the iOS Simulator at compile time via `#if targetEnvironment(simulator)`.

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