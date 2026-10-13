import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_security_detection/flutter_security_detection.dart';

// Pass --dart-define=SHIELD_DEV_MODE=true to bypass all checks (e.g. when
// developing on a simulator), and --dart-define=SHIELD_DEBUG_DETECTION=true
// to also report debuggers / debuggable builds. See doc/DEVICE_TESTING.md.
const _devMode = bool.fromEnvironment('SHIELD_DEV_MODE');
const _debugDetection = bool.fromEnvironment('SHIELD_DEBUG_DETECTION');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterSecurityDetection.init(
    config: ShieldConfig(
      devMode: _devMode,
      enableDebugDetection: _debugDetection,
      recheckOnResume: true,
      onThreatDetected: (result) {
        debugPrint('Threats: ${result.threats}');
      },
    ),
  );

  runApp(const ExampleApp());
}

// go_router recipe: redirect while the device is blocked, and re-evaluate the
// redirect whenever a runtime re-check changes the result.
final _router = GoRouter(
  refreshListenable: FlutterSecurityDetection.resultListenable,
  redirect: (context, state) {
    final blocked = FlutterSecurityDetection.isBlocked;
    if (blocked && state.uri.path != '/blocked') return '/blocked';
    if (!blocked && state.uri.path == '/blocked') return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/blocked', builder: (context, state) => const BlockedPage()),
  ],
);

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

/// Shows exactly which threats were found, so a device test is readable.
/// A production app would use ShieldBlockedScreen or its own screen.
class BlockedPage extends StatelessWidget {
  const BlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = FlutterSecurityDetection.lastResult;
    return Scaffold(
      appBar: AppBar(title: const Text('Device Not Secure')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Threats found:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            for (final t in result?.threats ?? const <ShieldThreat>[])
              Text('• ${t.name}', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: FlutterSecurityDetection.recheck,
              child: const Text('Re-check'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ShieldResult? _result;
  bool _loading = false;

  Future<void> _runCheck() async {
    setState(() => _loading = true);
    final result = await FlutterSecurityDetection.recheck();
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Detection Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _runCheck,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Run Security Check'),
            ),
            const SizedBox(height: 24),
            if (_result != null) ...[
              _StatusRow('Passed', _result!.passed),
              _StatusRow('Jailbroken', _result!.isJailbroken),
              _StatusRow('Rooted', _result!.isRooted),
              _StatusRow('Frida Detected', _result!.isFridaDetected),
              const SizedBox(height: 16),
              const Text(
                'Threats:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_result!.threats.isEmpty)
                const Text('None — device is clean')
              else
                ..._result!.threats.map(
                  (t) => Text(
                    '• ${t.name}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool value;

  const _StatusRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
