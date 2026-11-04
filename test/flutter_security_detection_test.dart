import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_security_detection/flutter_security_detection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.flutter_shield/security');
  var nativeCalls = 0;
  var threats = <String>[];

  setUp(() {
    nativeCalls = 0;
    threats = [];
    FlutterSecurityDetection.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      nativeCalls++;
      return {
        'passed': threats.isEmpty,
        'isJailbroken': false,
        'isRooted': false,
        'isFridaDetected': threats.isNotEmpty,
        'threats': threats,
      };
    });
  });

  tearDown(() {
    FlutterSecurityDetection.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('init / check / recheck', () {
    test('init caches the result and check() does not hit native again',
        () async {
      await FlutterSecurityDetection.init();
      await FlutterSecurityDetection.check();
      await FlutterSecurityDetection.check();

      expect(nativeCalls, 1);
      expect(FlutterSecurityDetection.lastResult?.passed, true);
      expect(FlutterSecurityDetection.isBlocked, false);
    });

    test('recheck() runs native again and updates the result', () async {
      await FlutterSecurityDetection.init();
      threats = ['frida_port_open'];

      final result = await FlutterSecurityDetection.recheck();

      expect(nativeCalls, 2);
      expect(result.passed, false);
      expect(FlutterSecurityDetection.isBlocked, true);
    });

    test('concurrent callers share a single native check', () async {
      final results = await Future.wait([
        FlutterSecurityDetection.check(),
        FlutterSecurityDetection.recheck(),
        FlutterSecurityDetection.check(),
      ]);

      expect(nativeCalls, 1);
      expect(results.toSet().length, 1);
    });

    test('devMode never calls native and always passes', () async {
      threats = ['frida_port_open'];
      await FlutterSecurityDetection.init(
        config: const ShieldConfig(devMode: true),
      );

      expect((await FlutterSecurityDetection.check()).passed, true);
      expect((await FlutterSecurityDetection.recheck()).passed, true);
      expect(nativeCalls, 0);
      expect(FlutterSecurityDetection.isBlocked, false);
    });

    test('isBlocked is false before the first check completes', () {
      expect(FlutterSecurityDetection.lastResult, isNull);
      expect(FlutterSecurityDetection.isBlocked, false);
    });
  });

  group('onThreatDetected', () {
    test('fires from init and from a re-check that finds new threats',
        () async {
      final seen = <ShieldResult>[];
      threats = ['frida_port_open'];
      await FlutterSecurityDetection.init(
        config: ShieldConfig(onThreatDetected: seen.add),
      );
      expect(seen.length, 1);

      // Unchanged failing result: no repeat callback.
      await FlutterSecurityDetection.recheck();
      expect(seen.length, 1);

      threats = ['frida_port_open', 'cydia_found'];
      await FlutterSecurityDetection.recheck();
      expect(seen.length, 2);
    });

    test('does not fire for a passing result', () async {
      var calls = 0;
      await FlutterSecurityDetection.init(
        config: ShieldConfig(onThreatDetected: (_) => calls++),
      );
      expect(calls, 0);
    });
  });

  group('resultListenable', () {
    test('notifies when a re-check changes the outcome', () async {
      await FlutterSecurityDetection.init();
      var notified = 0;
      FlutterSecurityDetection.resultListenable.addListener(() => notified++);

      await FlutterSecurityDetection.recheck(); // unchanged → no notify
      expect(notified, 0);

      threats = ['frida_port_open'];
      await FlutterSecurityDetection.recheck();
      expect(notified, 1);
    });
  });

  group('runtime re-checks', () {
    testWidgets('recheckOnResume re-runs the check on resume', (tester) async {
      await FlutterSecurityDetection.init(
        config: const ShieldConfig(recheckOnResume: true),
      );
      expect(nativeCalls, 1);

      threats = ['frida_port_open'];
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(nativeCalls, 2);
      expect(FlutterSecurityDetection.isBlocked, true);
    });

    testWidgets('no resume re-check unless enabled', (tester) async {
      await FlutterSecurityDetection.init();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(nativeCalls, 1);
    });

    testWidgets('recheckInterval re-runs the check periodically',
        (tester) async {
      await FlutterSecurityDetection.init(
        config: const ShieldConfig(recheckInterval: Duration(seconds: 30)),
      );
      expect(nativeCalls, 1);

      await tester.pump(const Duration(seconds: 31));
      expect(nativeCalls, 2);

      FlutterSecurityDetection.reset();
      await tester.pump(const Duration(seconds: 60));
      expect(nativeCalls, 2);
    });
  });

  group('ShieldGate', () {
    Widget app() => const MaterialApp(
          home: ShieldGate(
            loading: Text('loading'),
            blocked: Text('blocked'),
            child: Text('protected'),
          ),
        );

    testWidgets('shows loading, then child when the device passes',
        (tester) async {
      await tester.pumpWidget(app());
      expect(find.text('protected'), findsNothing);
      expect(find.text('loading'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('protected'), findsOneWidget);
    });

    testWidgets('shows blocked and never the child on a failing check',
        (tester) async {
      threats = ['frida_port_open'];
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('blocked'), findsOneWidget);
      expect(find.text('protected'), findsNothing);
    });

    testWidgets('swaps to blocked when a re-check finds a threat',
        (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('protected'), findsOneWidget);

      threats = ['frida_port_open'];
      await FlutterSecurityDetection.recheck();
      await tester.pumpAndSettle();

      expect(find.text('blocked'), findsOneWidget);
      expect(find.text('protected'), findsNothing);
    });

    testWidgets('default blocked screen is used when none is given',
        (tester) async {
      threats = ['frida_port_open'];
      await tester.pumpWidget(const MaterialApp(
        home: ShieldGate(child: Text('protected')),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Device Not Secure'), findsOneWidget);
    });
  });
}
