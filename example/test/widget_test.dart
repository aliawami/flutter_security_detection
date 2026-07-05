import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_shield_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.flutter_shield/security');

  /// Mocks the native side of the plugin so the security check completes
  /// inside the widget test's fake-async zone.
  void mockNativeCheck({required bool passed, List<String> threats = const []}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'checkDevice') {
        return {
          'passed': passed,
          'isJailbroken': false,
          'isRooted': false,
          'isFridaDetected': threats.isNotEmpty,
          'threats': threats,
        };
      }
      return null;
    });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('home screen renders when the device check passes',
      (WidgetTester tester) async {
    mockNativeCheck(passed: true);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter Shield Example'), findsOneWidget);
    expect(find.text('Run Security Check'), findsOneWidget);
    expect(find.text('Device Not Secure'), findsNothing);
  });

  testWidgets('running a security check shows a clean result',
      (WidgetTester tester) async {
    mockNativeCheck(passed: true);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Run Security Check'));
    await tester.pumpAndSettle();

    expect(find.text('Passed'), findsOneWidget);
    expect(find.text('None — device is clean'), findsOneWidget);
  });
}
